# Custom CA in a client container

Copies the `ca.crt` produced by [`create_private_ca_signed_cert`](../create_private_ca_signed_cert)
into the container, adds it to the system trust store with `update-ca-certificates`, and
uses `curl` to reach an HTTPS server that relies on that CA.

After `update-ca-certificates`, the container trusts `CN=Blue Meridian Root CA`, which is
what makes the `CN=api.bluemeridian.example` server cert from example 2 verify.

```sh
just client-verify   # build and show the CA installed in the trust store
just client-run      # run the image's default `curl https://api.bluemeridian.example`
```

Run from the repo root. `client-build` depends on the `ca` recipe, so the CA certs are
generated first if they're missing. The build context is the repo root, because the
Dockerfile reads `create_private_ca_signed_cert/output/ca.crt`.

`client-run` only succeeds if `api.bluemeridian.example` actually resolves to a host presenting
the cert from example 2. `client-verify` demonstrates the trust store change without
needing that server.

Raw equivalent (from the repo root):

```sh
docker build --no-cache -t curl-with-ca -f custom_ca_in_client_container/Dockerfile .
docker run --rm curl-with-ca
```
