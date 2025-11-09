FROM ubuntu:22.04

# Install OpenSSL and coreutils (for touch)
RUN apt-get update && apt-get install -y openssl coreutils && \
    openssl version && \
    echo "OpenSSL installed"

# Create CA directory structure
RUN mkdir -p /ca/certs /ca/private /ca/crl /ca/newcerts && \
    touch /ca/index.txt && \
    echo 1000 > /ca/serial && \
    ls -l /ca/index.txt /ca/serial && \
    echo "Directory structure created"

# Generate CA private key and self-signed cert
RUN openssl req -x509 -nodes -days 3650 -newkey rsa:4096 \
    -keyout /ca/private/ca.key \
    -out /ca/certs/ca.crt \
    -subj "/C=US/ST=State/L=City/O=MyCA/CN=MyRootCA" && \
    ls -l /ca/certs/ca.crt /ca/private/ca.key && \
    echo "CA certificate created"

# Generate server key and CSR
RUN openssl req -nodes -newkey rsa:2048 \
    -keyout /ca/private/server.key \
    -out /ca/server.csr \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=server.example.com" && \
    ls -l /ca/private/server.key /ca/server.csr && \
    openssl req -in /ca/server.csr -text -noout && \
    echo "Server CSR created"

# Create OpenSSL configuration file
RUN cat <<EOF > /tmp/openssl.cnf
[ca]
default_ca = CA_default

[CA_default]
dir = /ca
certs = \$dir/certs
crl_dir = \$dir/crl
database = \$dir/index.txt
new_certs_dir = \$dir/newcerts
certificate = \$dir/certs/ca.crt
private_key = \$dir/private/ca.key
serial = \$dir/serial
RANDFILE = \$dir/private/.rand
default_days = 365
default_md = sha256
preserve = no
policy = policy_anything

[policy_anything]
countryName = optional
stateOrProvinceName = optional
localityName = optional
organizationName = optional
organizationalUnitName = optional
commonName = supplied
emailAddress = optional
EOF

# Sign the CSR with the CA and verify output
RUN echo "Running openssl ca..." && \
    openssl ca -batch -config /tmp/openssl.cnf -in /ca/server.csr -out /ca/certs/server.crt -days 365 -verbose > /tmp/openssl_ca.log 2>&1 && \
    sync && \
    ls -l /ca/certs/ /ca/newcerts/ && \
    [ -s /ca/certs/ca.crt ] || { echo "Error: ca.crt is missing or empty"; exit 1; } && \
    [ -s /ca/certs/server.crt ] || { echo "Error: server.crt is missing or empty"; cat /tmp/openssl_ca.log /ca/index.txt /ca/serial; exit 1; } && \
    echo "Server certificate created"

# Create output directory and copy certificates at runtime
CMD ["bash", "-c", "mkdir -p /output && [ -s /ca/certs/ca.crt ] && [ -s /ca/certs/server.crt ] && cp -v /ca/certs/ca.crt /ca/certs/server.crt /output/ && chmod 644 /output/*.crt || { echo 'Error: Certificates missing or copy failed'; cat /tmp/openssl_ca.log /ca/index.txt /ca/serial; exit 1; } && ls -l /ca/certs/ /ca/newcerts/ /output/ && cat /ca/certs/ca.crt /ca/certs/server.crt"]
