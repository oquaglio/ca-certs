# Private CA-signed cert

Acts as your own certificate authority. At image build time this generates:

- a private CA key and self-signed CA certificate (`ca.crt`),
- a server key and CSR,
- a server certificate signed by that CA (`server.crt`).

```sh
just ca           # build, then export ca.crt, server.crt, server.key to ./output/
just ca-force     # discard and regenerate a brand new CA and server cert
just ca-verify    # confirm server.crt chains to ca.crt
just ca-show      # full server cert details
```

Run from the repo root. `just ca` runs the container with `./output` bind-mounted and
copies the three files out of it — the image's default `CMD` only prints them to stdout.

These are throwaway test certs. `output/` and `*.crt` are gitignored; don't commit the
private keys or reuse them anywhere that matters.

Raw equivalent:

```sh
mkdir -p output
docker build --no-cache -t private-ca .
docker run --rm -v $(pwd)/output:/output private-ca \
  bash -c 'cp /ca/certs/ca.crt /ca/certs/server.crt /ca/private/server.key /output/'
openssl verify -CAfile output/ca.crt output/server.crt
openssl x509 -in output/server.crt -text -noout
```
