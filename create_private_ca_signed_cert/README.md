#

```sh
docker builder prune --all
mkdir -p output
chmod 755 output
docker build --no-cache -t private-ca .
docker run --rm -v $(pwd)/output:/output private-ca
```
