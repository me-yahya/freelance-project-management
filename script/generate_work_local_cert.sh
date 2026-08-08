#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

CERT_DIR="script/certs"
CA_KEY="$CERT_DIR/work-local-ca.key"
CA_CERT="$CERT_DIR/work-local-ca.crt"
SERVER_KEY="$CERT_DIR/work-local.key"
SERVER_CSR="$CERT_DIR/work-local.csr"
SERVER_CERT="$CERT_DIR/work-local.crt"

mkdir -p "$CERT_DIR"

if [ ! -f "$CA_KEY" ] || [ ! -f "$CA_CERT" ]; then
  openssl genrsa -out "$CA_KEY" 4096
  openssl req \
    -x509 \
    -new \
    -nodes \
    -key "$CA_KEY" \
    -sha256 \
    -days 3650 \
    -out "$CA_CERT" \
    -subj "/CN=Freelance Manager Local CA" \
    -addext "basicConstraints=critical,CA:TRUE" \
    -addext "keyUsage=critical,keyCertSign,cRLSign" \
    -addext "subjectKeyIdentifier=hash"
fi

openssl genrsa -out "$SERVER_KEY" 2048
openssl req \
  -new \
  -key "$SERVER_KEY" \
  -out "$SERVER_CSR" \
  -subj "/CN=work.local" \
  -addext "subjectAltName=DNS:work.local"
openssl x509 \
  -req \
  -in "$SERVER_CSR" \
  -CA "$CA_CERT" \
  -CAkey "$CA_KEY" \
  -CAcreateserial \
  -out "$SERVER_CERT" \
  -days 825 \
  -sha256 \
  -extfile <(printf "basicConstraints=CA:FALSE\nkeyUsage=digitalSignature,keyEncipherment\nextendedKeyUsage=serverAuth\nsubjectAltName=DNS:work.local\n")
rm -f "$SERVER_CSR"

chmod 600 "$CA_KEY" "$SERVER_KEY"
echo "Generated local HTTPS certificate for work.local."
