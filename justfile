# ca-certs — docker examples of certificate usage
# Run `just --list` to see all recipes.

set shell := ["bash", "-uc"]

root := justfile_directory()
ca_dir := root / "create_private_ca_signed_cert"
ca_out := ca_dir / "output"
nginx_dir := root / "basic_self_signed_nginx"

nginx_image := "selfsigned-nginx"
nginx_name := "selfsigned-nginx"
nginx_port := "8443"
ca_image := "private-ca"
client_image := "curl-with-ca"

# Show available recipes
default:
    @just --list

# --- Example 1: self-signed cert served by nginx ---------------------------

# Build the nginx image with a self-signed cert baked in
nginx-build:
    docker build -t {{ nginx_image }} {{ nginx_dir }}

# Run nginx on https://localhost:8443/ (detached)
nginx-run: nginx-build
    docker rm -f {{ nginx_name }} 2>/dev/null || true
    docker run -d --name {{ nginx_name }} -p {{ nginx_port }}:443 {{ nginx_image }}
    @echo "Serving https://localhost:{{ nginx_port }}/ (self-signed — expect a trust warning)"

# Hit the nginx endpoint with curl, ignoring the untrusted self-signed cert
nginx-test: nginx-run
    @sleep 1
    curl -ksS -o /dev/null -w 'HTTP %{http_code}\n' https://localhost:{{ nginx_port }}/

# Print the cert nginx is presenting
nginx-show:
    openssl s_client -connect localhost:{{ nginx_port }} -servername example.com </dev/null 2>/dev/null \
      | openssl x509 -noout -subject -issuer -dates

# Stop and remove the nginx container
nginx-stop:
    docker rm -f {{ nginx_name }} 2>/dev/null || true

# --- Example 2: private CA-signed server cert ------------------------------

# Build the CA image (generates CA + server cert at build time)
ca-build:
    docker build -t {{ ca_image }} {{ ca_dir }}

# Generate certs and export ca.crt, server.crt, server.key to create_private_ca_signed_cert/output/
ca: ca-build
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ -f "{{ ca_out }}/ca.crt" && -f "{{ ca_out }}/server.crt" && -f "{{ ca_out }}/server.key" ]]; then
        echo "certs already present in {{ ca_out }} (use \`just ca-force\` to regenerate)"
        exit 0
    fi
    mkdir -p "{{ ca_out }}"
    docker run --rm -v "{{ ca_out }}":/output {{ ca_image }} \
      bash -c 'cp /ca/certs/ca.crt /ca/certs/server.crt /ca/private/server.key /output/ && chmod 644 /output/*'
    ls -l "{{ ca_out }}"

# Discard existing certs and generate a brand new CA and server cert
ca-force:
    rm -rf {{ ca_out }}
    docker build --no-cache -t {{ ca_image }} {{ ca_dir }}
    @just ca

# Verify server.crt chains to ca.crt
ca-verify: ca
    openssl verify -CAfile {{ ca_out }}/ca.crt {{ ca_out }}/server.crt

# Dump the full server certificate details
ca-show: ca
    openssl x509 -in {{ ca_out }}/server.crt -text -noout

# --- Example 3: trusting the custom CA inside a client container -----------

# Build a client image that installs ca.crt into the system trust store
client-build: ca
    docker build -t {{ client_image }} -f custom_ca_in_client_container/Dockerfile {{ root }}

# Show that the custom CA is present in the container's trust store
client-verify: client-build
    docker run --rm {{ client_image }} \
      bash -c 'ls -l /etc/ssl/certs | grep -i custom-ca && openssl x509 -in /usr/local/share/ca-certificates/custom-ca.crt -noout -subject -issuer'

# Run the client's default curl against https://server.example.com (fails without such a host)
client-run: client-build
    docker run --rm {{ client_image }}

# --- Everything / cleanup --------------------------------------------------

# Run all three examples end to end
all: nginx-test ca-verify client-verify

# Remove containers, images and generated certs
clean: nginx-stop
    docker rmi -f {{ nginx_image }} {{ ca_image }} {{ client_image }} 2>/dev/null || true
    rm -rf {{ ca_out }}
