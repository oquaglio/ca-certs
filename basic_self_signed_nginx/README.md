#

```SH
docker build -t selfsigned-nginx .
docker run -d -p 8443:443 selfsigned-nginx
```

https://localhost:8443/
