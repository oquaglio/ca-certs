FROM ubuntu:22.04

# Install curl and ca-certificates
RUN apt-get update && apt-get install -y curl ca-certificates

# Copy custom CA cert from ../dir/output relative to the build context
COPY create_private_ca_signed_cert/output/ca.crt /usr/local/share/ca-certificates/custom-ca.crt

# Update CA trust store
RUN update-ca-certificates

# Test curl against a server using the custom CA (replace URL with your test server)
CMD ["curl", "https://server.example.com"]
