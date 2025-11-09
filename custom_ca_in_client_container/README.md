#

Copy a custom CA certificate (ca.crt) from ../dir/output/ into the container, add it to the system’s trusted CA store, and use curl to test an HTTPS connection to a server (e.g., https://server.example.com) that relies on this CA for trust verification.

```sh
cd ..
docker build --no-cache -t curl-with-ca -f custom_ca_in_client_container/Dockerfile .
docker run --rm curl-with-ca
```

```sh
docker run --rm -v $(pwd)/../dir/output/ca.crt:/mnt/ca.crt curl-with-ca
```
