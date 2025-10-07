#!/bin/bash

# Source the .env file
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

if ! [ -x "$(command -v docker compose)" ]; then
    echo 'Error: docker compose is not installed.' >&2
    exit 1
fi

domains=(${APP_DOMAIN:-example.com})
nginx_config="${CONFIG_DIR:-./config}/nginx"
certbot_config="${CONFIG_DIR:-./config}/certbot"
letsencrypt_config="${CONFIG_DIR:-./config}/letsencrypt"
rsa_key_size=${RSA_KEY_SIZE:-4096}

if [ -d "$CONFIG_DIR" ]; then
    read -p "Existing data found for $domains. Continue and replace existing certificate? (y/N) " decision
    if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
        exit
    fi
fi

nginx_options="$nginx_config/ssl"
if [ ! -e "$nginx_options/options-ssl-nginx.conf" ] || [ ! -e "$nginx_options/ssl-dhparams.pem" ]; then
    echo "### Downloading recommended TLS parameters ..."
    mkdir -p "$certbot_config"
    curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf >"$nginx_options/options-ssl-nginx.conf"
    curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem >"$nginx_config/options/ssl-dhparams.pem"
fi

printf "\n### Creating dummy certificate for %s ...\n" $domains
mkdir -p "$letsencrypt_config/live/$domains"
certs_dir="/etc/letsencrypt/live/$domains"

docker compose -f "docker-compose.yml" run --rm --entrypoint "\
  openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1\
    -config '/etc/ssl/openssl.cnf' \
    -keyout '$certs_dir/privkey.pem' \
    -out '$certs_dir/fullchain.pem' \
    -subj '/CN=$domains'" certbot

printf "\n### Starting nginx ...\n"
docker compose  -f "docker-compose.yml" up --force-recreate -d nginx

printf "\n### Deleting dummy certificate for %s ...\n" $domains
docker compose  -f "docker-compose.yml" run --rm --entrypoint "\
  rm -Rf $letsencrypt_config/live/$domains && \
  rm -Rf $letsencrypt_config/archive/$domains && \
  rm -Rf $letsencrypt_config/renewal/$domains.conf" certbot

printf "\n### Requesting Let's Encrypt certificate for %s ...\n" $domains
#Join $domains to -d args
domain_args=""
for domain in "${domains[@]}"; do
    domain_args="$domain_args -d $domain"
done

# Select appropriate email arg
case "$SSL_EMAIL" in
"") email_arg="--register-unsafely-without-email" ;;
*) email_arg="--email $SSL_EMAIL" ;;
esac

# Enable staging mode if needed
if [ $CERTBOT_STAGING = "true" ]; then staging_arg="--staging"; fi

docker compose -f "docker-compose.yml" run --rm --entrypoint "\
  echo 'nginx $domains' | sudo tee -a /etc/hosts >/dev/null && \
  certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    $email_arg \
    $domain_args \
    --rsa-key-size $RSA_KEY_SIZE \
    --agree-tos \
    --force-renewal" certbot

printf "\n### Reloading nginx ...\n"
docker compose -f "docker-compose.yml" exec nginx nginx -s reload
