# ca-certs

Three small, self-contained Docker examples covering the practical lifecycle of X.509
certificates: making one, signing one with your own CA, and getting a client to trust it.

| Example | Directory | What it shows |
| --- | --- | --- |
| 1. Self-signed cert on nginx | [`basic_self_signed_nginx/`](basic_self_signed_nginx) | Generate a self-signed cert and serve HTTPS with it |
| 2. Private CA-signed cert | [`create_private_ca_signed_cert/`](create_private_ca_signed_cert) | Act as your own CA and sign a server cert |
| 3. Custom CA in a client | [`custom_ca_in_client_container/`](custom_ca_in_client_container) | Install that CA into a container's trust store |

## Certificate identities

All three examples use one fictional company, **Blue Meridian Systems**, so the CA, the
server cert and the client trust store visibly line up:

| Cert | Subject |
| --- | --- |
| Self-signed (example 1) | `C=AU, ST=New South Wales, L=Sydney, O=Blue Meridian Systems, OU=Platform Engineering, CN=shop.bluemeridian.example` |
| Root CA (example 2) | `C=AU, ST=New South Wales, L=Sydney, O=Blue Meridian Systems, OU=Certificate Authority, CN=Blue Meridian Root CA` |
| Server, CA-signed (example 2) | `C=AU, ST=New South Wales, L=Sydney, O=Blue Meridian Systems, OU=Platform Engineering, CN=api.bluemeridian.example` |

The hostnames sit under the reserved `.example` TLD (RFC 2606), so they can never collide
with a real domain. Change the `-subj` strings in each Dockerfile to use your own.

## Requirements

- Docker
- [`just`](https://github.com/casey/just)
- `openssl` and `curl` on the host (for the verification recipes)

## Usage

```sh
just              # list all recipes
just all          # run all three examples end to end
just clean        # remove containers, images and generated certs
```

### Example 1 — self-signed cert on nginx

```sh
just nginx-run    # build + serve on https://localhost:8443/
just nginx-test   # curl -k against it, expect HTTP 200
just nginx-show   # print the cert nginx is presenting
just nginx-stop   # tear down
```

The cert is self-signed, so browsers and plain `curl` will warn — that is the point of
the example. Override the port if 8443 is taken:

```sh
just nginx_port=9443 nginx-run
```

### Example 2 — private CA-signed cert

```sh
just ca           # generate and export certs to create_private_ca_signed_cert/output/
just ca-force     # discard and regenerate a brand new CA and server cert
just ca-verify    # openssl verify -CAfile ca.crt server.crt
just ca-show      # full server cert details
```

`just ca` writes `ca.crt`, `server.crt` and `server.key` into
`create_private_ca_signed_cert/output/`. These are throwaway test certs — `output/` and
`*.crt` are gitignored, and the private keys must never be committed or reused anywhere
real.

### Example 3 — custom CA in a client container

```sh
just client-verify  # build the client and show the CA in its trust store
just client-run     # run the image's default `curl https://api.bluemeridian.example`
```

`client-build` depends on `ca`, so the CA certs are regenerated automatically if missing.
The image is built from the repo root because its Dockerfile reads `ca.crt` out of
example 2's output directory.

`just client-run` will fail to resolve `api.bluemeridian.example` unless you actually have a
host by that name presenting the cert from example 2 — `client-verify` is the recipe that
demonstrates the trust store change on its own.
