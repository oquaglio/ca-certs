#

```sh
docker builder prune --all
mkdir -p output
chmod 755 output
docker build --no-cache -t private-ca .
docker run --rm -v $(pwd)/output:/output private-ca
```

Ensure server.crt is properly signed by ca.crt:
```sh
openssl verify -CAfile output/ca.crt output/server.crt
```

View the certificate’s full details:
```sh
openssl x509 -in output/server.crt -text -noout
```

