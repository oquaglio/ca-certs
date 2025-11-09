#


```sh
cd ..
docker build --no-cache -t curl-with-ca -f create_private_ca_signed_cert/Dockerfile .
docker run --rm curl-with-ca
```
