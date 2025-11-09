FROM ubuntu:22.04

# Install OpenSSL and coreutils (for touch)
RUN apt-get update && apt-get install -y openssl coreutils

# Create CA directory structure
RUN mkdir -p /ca/certs /ca/private /ca/crl /ca/newcerts && \
    touch /ca/index.txt && \
    echo 1000 > /ca/serial

# Generate CA private key and self-signed cert
RUN openssl req -x509 -nodes -days 3650 -newkey rsa:4096 \
    -keyout /ca/private/ca.key \
    -out /ca/certs/ca.crt \
    -subj "/C=US/ST=State/L=City/O=MyCA/CN=MyRootCA"

# Generate server key and CSR
RUN openssl req -nodes -newkey rsa:2048 \
    -keyout /ca/private/server.key \
    -out /ca/server.csr \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=server.example.com"

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

# Sign the CSR with the CA
RUN openssl ca -batch -config /tmp/openssl.cnf \
    -in /ca/server.csr -out /ca/certs/server.crt -days 365

# Copy certificates to the local directory
COPY /ca/certs/ca.crt /ca/certs/server.crt ./

# Output the certs for inspection (optional, kept for verification)
CMD ["bash", "-c", "cat /ca/certs/ca.crt /ca/certs/server.crt"]
