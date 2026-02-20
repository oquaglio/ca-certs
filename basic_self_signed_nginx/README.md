#

```SH
docker build -t selfsigned-nginx .
docker run -d -p 8443:443 selfsigned-nginx
```

You now have https working on nginx web server:
https://localhost:8443/
