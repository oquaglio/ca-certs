
## Crete and install a self-signed Cert

And deploy it to nginx for https

./basic_self_signed_nginx



## Create and Install a Private CA-signed Cert

Generate a server cert from a CA cert:

./create_private_ca_signed_cert

Copy it into a Ubuntu container and install it:

./custom_ca_in_client_container
