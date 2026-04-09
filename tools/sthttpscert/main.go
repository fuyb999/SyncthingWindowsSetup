package main

import (
	"crypto/rand"
	"crypto/rsa"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/pem"
	"errors"
	"flag"
	"fmt"
	"math/big"
	"net"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"time"
)

const (
	defaultValidityDays = 825
	certFileName        = "https-cert.pem"
	keyFileName         = "https-key.pem"
)

func main() {
	configDir := flag.String("config-dir", "", "Syncthing config directory")
	listenAddress := flag.String("listen-address", "", "Syncthing GUI listen address")
	caCertPath := flag.String("ca-cert", "", "CA certificate in PEM format")
	caKeyPath := flag.String("ca-key", "", "CA private key in PEM format")
	validityDays := flag.Int("validity-days", defaultValidityDays, "Leaf certificate validity in days")
	flag.Parse()

	if err := run(*configDir, *listenAddress, *caCertPath, *caKeyPath, *validityDays); err != nil {
		fmt.Fprintln(os.Stderr, "sthttpscert:", err)
		os.Exit(1)
	}
}

func run(configDir, listenAddress, caCertPath, caKeyPath string, validityDays int) error {
	if strings.TrimSpace(configDir) == "" {
		return errors.New("config directory is required")
	}
	if strings.TrimSpace(caCertPath) == "" {
		return errors.New("CA certificate path is required")
	}
	if strings.TrimSpace(caKeyPath) == "" {
		return errors.New("CA private key path is required")
	}
	if validityDays <= 0 {
		return errors.New("validity days must be greater than zero")
	}

	caCert, err := loadCertificate(caCertPath)
	if err != nil {
		return err
	}
	caKey, err := loadPrivateKey(caKeyPath)
	if err != nil {
		return err
	}

	dnsNames, ipAddresses := sanValues(listenAddress)
	leafCertPEM, leafKeyPEM, err := issueLeafCertificate(caCert, caKey, dnsNames, ipAddresses, validityDays)
	if err != nil {
		return err
	}

	if err := os.MkdirAll(configDir, 0o755); err != nil {
		return fmt.Errorf("create config directory: %w", err)
	}

	certPath := filepath.Join(configDir, certFileName)
	keyPath := filepath.Join(configDir, keyFileName)
	if err := writePEMFile(certPath, leafCertPEM, 0o644); err != nil {
		return err
	}
	if err := writePEMFile(keyPath, leafKeyPEM, 0o600); err != nil {
		return err
	}

	fmt.Printf("wrote %s\n", certPath)
	fmt.Printf("wrote %s\n", keyPath)
	return nil
}

func loadCertificate(path string) (*x509.Certificate, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("read CA certificate: %w", err)
	}
	block, _ := pem.Decode(data)
	if block == nil || block.Type != "CERTIFICATE" {
		return nil, errors.New("parse CA certificate PEM")
	}
	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return nil, fmt.Errorf("parse CA certificate: %w", err)
	}
	if !cert.IsCA {
		return nil, errors.New("CA certificate is not marked as a CA")
	}
	return cert, nil
}

func loadPrivateKey(path string) (any, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("read CA private key: %w", err)
	}
	block, _ := pem.Decode(data)
	if block == nil {
		return nil, errors.New("parse CA private key PEM")
	}

	switch block.Type {
	case "RSA PRIVATE KEY":
		key, err := x509.ParsePKCS1PrivateKey(block.Bytes)
		if err != nil {
			return nil, fmt.Errorf("parse PKCS#1 CA private key: %w", err)
		}
		return key, nil
	case "PRIVATE KEY":
		key, err := x509.ParsePKCS8PrivateKey(block.Bytes)
		if err != nil {
			return nil, fmt.Errorf("parse PKCS#8 CA private key: %w", err)
		}
		return key, nil
	case "EC PRIVATE KEY":
		key, err := x509.ParseECPrivateKey(block.Bytes)
		if err != nil {
			return nil, fmt.Errorf("parse EC CA private key: %w", err)
		}
		return key, nil
	default:
		return nil, fmt.Errorf("unsupported CA private key PEM block: %s", block.Type)
	}
}

func sanValues(listenAddress string) ([]string, []net.IP) {
	dnsNames := map[string]struct{}{
		"localhost": {},
	}
	ipAddresses := map[string]struct{}{
		net.IPv4(127, 0, 0, 1).String(): {},
		net.IPv6loopback.String():       {},
	}

	address := strings.TrimSpace(strings.Trim(listenAddress, "[]"))
	if address != "" && address != "0.0.0.0" && address != "::" {
		if ip := net.ParseIP(address); ip != nil {
			ipAddresses[ip.String()] = struct{}{}
		} else {
			dnsNames[address] = struct{}{}
		}
	}

	dnsList := make([]string, 0, len(dnsNames))
	for name := range dnsNames {
		dnsList = append(dnsList, name)
	}
	sort.Strings(dnsList)

	ipList := make([]net.IP, 0, len(ipAddresses))
	for addr := range ipAddresses {
		ipList = append(ipList, net.ParseIP(addr))
	}
	sort.Slice(ipList, func(i, j int) bool {
		return bytesCompare(ipList[i], ipList[j]) < 0
	})

	return dnsList, ipList
}

func issueLeafCertificate(caCert *x509.Certificate, caKey any, dnsNames []string, ipAddresses []net.IP, validityDays int) ([]byte, []byte, error) {
	leafKey, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		return nil, nil, fmt.Errorf("generate leaf private key: %w", err)
	}

	serialLimit := new(big.Int).Lsh(big.NewInt(1), 128)
	serialNumber, err := rand.Int(rand.Reader, serialLimit)
	if err != nil {
		return nil, nil, fmt.Errorf("generate serial number: %w", err)
	}

	commonName := "localhost"
	if len(dnsNames) > 0 {
		commonName = dnsNames[0]
	} else if len(ipAddresses) > 0 {
		commonName = ipAddresses[0].String()
	}

	template := &x509.Certificate{
		SerialNumber: serialNumber,
		Subject: pkix.Name{
			Organization:       []string{"SyncthingWindowsSetup"},
			OrganizationalUnit: []string{"Syncthing GUI HTTPS"},
			CommonName:         commonName,
		},
		NotBefore:             time.Now().Add(-5 * time.Minute),
		NotAfter:              time.Now().Add(time.Duration(validityDays) * 24 * time.Hour),
		KeyUsage:              x509.KeyUsageDigitalSignature | x509.KeyUsageKeyEncipherment,
		ExtKeyUsage:           []x509.ExtKeyUsage{x509.ExtKeyUsageServerAuth},
		BasicConstraintsValid: true,
		DNSNames:              dnsNames,
		IPAddresses:           ipAddresses,
		AuthorityKeyId:        caCert.SubjectKeyId,
	}

	leafDER, err := x509.CreateCertificate(rand.Reader, template, caCert, &leafKey.PublicKey, caKey)
	if err != nil {
		return nil, nil, fmt.Errorf("create leaf certificate: %w", err)
	}
	leafKeyDER, err := x509.MarshalPKCS8PrivateKey(leafKey)
	if err != nil {
		return nil, nil, fmt.Errorf("marshal leaf private key: %w", err)
	}

	leafCertPEM := pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: leafDER})
	leafKeyPEM := pem.EncodeToMemory(&pem.Block{Type: "PRIVATE KEY", Bytes: leafKeyDER})
	return leafCertPEM, leafKeyPEM, nil
}

func writePEMFile(path string, data []byte, perm os.FileMode) error {
	file, err := os.OpenFile(path, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, perm)
	if err != nil {
		return fmt.Errorf("open %s: %w", path, err)
	}
	if _, err := file.Write(data); err != nil {
		file.Close()
		return fmt.Errorf("write %s: %w", path, err)
	}
	if err := file.Close(); err != nil {
		return fmt.Errorf("close %s: %w", path, err)
	}
	return nil
}

func bytesCompare(a, b []byte) int {
	limit := len(a)
	if len(b) < limit {
		limit = len(b)
	}
	for i := 0; i < limit; i++ {
		if a[i] < b[i] {
			return -1
		}
		if a[i] > b[i] {
			return 1
		}
	}
	switch {
	case len(a) < len(b):
		return -1
	case len(a) > len(b):
		return 1
	default:
		return 0
	}
}
