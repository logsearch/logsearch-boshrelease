#!/bin/bash

set -e

# empty
rm *.conf *.crt *.key *.csr ca.serial 2> /dev/null || true

cat > ca.conf <<EOF
[req]
encrypt_key = no
distinguished_name = req_distinguished_name
prompt = no

[req_distinguished_name]
O = logsearch.io
OU = TEST
OU = Certificate Authority
CN = ingestor
emailAddress = nobody@example.com
EOF

cat > signed.conf <<EOF
[req]
encrypt_key = no
distinguished_name = req_distinguished_name
prompt = no

[req_distinguished_name]
O = logsearch.io
OU = TEST
CN = ingestor
emailAddress = nobody@example.com

[v3_ca]
subjectAltName = IP:10.244.2.14
EOF

openssl genrsa -out ca.key 1024
openssl req -x509 -new -key ca.key -out ca.crt -days 3650 -config ca.conf

openssl genrsa -out signed.key 1024
openssl req -new -out signed.csr -key signed.key -config signed.conf
openssl x509 -extensions v3_ca -req -in signed.csr -out signed.crt -extfile signed.conf -CAkey ca.key -CA ca.crt -days 3650 -CAcreateserial -CAserial ca.serial

# cleanup
rm *.conf *.csr ca.serial
