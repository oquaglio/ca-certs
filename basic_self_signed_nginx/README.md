# Self-signed cert on nginx

Generates a self-signed certificate at image build time and configures nginx to serve
HTTPS with it.

```sh
just nginx-run     # build and serve on https://localhost:8443/
just nginx-test    # curl -k against it, expect HTTP 200
just nginx-show    # print the cert nginx is presenting
just nginx-stop    # tear down
```

Run from the repo root. Override the port if 8443 is in use:

```sh
just nginx_port=9443 nginx-run
```

Nothing trusts this certificate, so browsers show a warning and `curl` needs `-k`. That
is exactly what example 2 and 3 exist to fix.

Raw equivalent:

```sh
docker build -t selfsigned-nginx .
docker run -d -p 8443:443 selfsigned-nginx
```
