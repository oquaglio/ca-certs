FROM ubuntu:22.04

# Install necessary packages
RUN apt-get update && apt-get install -y openssl nginx

# Generate self-signed certificate
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/selfsigned.key \
    -out /etc/ssl/certs/selfsigned.crt \
    -subj "/C=AU/ST=New South Wales/L=Sydney/O=Blue Meridian Systems/OU=Platform Engineering/CN=shop.bluemeridian.example"

# Configure Nginx for HTTPS
RUN echo 'server { \
    listen 443 ssl; \
    server_name shop.bluemeridian.example; \
    ssl_certificate /etc/ssl/certs/selfsigned.crt; \
    ssl_certificate_key /etc/ssl/private/selfsigned.key; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html; \
    } \
}' > /etc/nginx/sites-available/default && \
    rm /etc/nginx/sites-enabled/default && \
    ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/

# Expose port
EXPOSE 443

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
