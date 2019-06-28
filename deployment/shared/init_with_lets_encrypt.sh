#!/usr/bin/env bash

export $(grep -v '^#' settings.env | grep '^[A-Z].*\n' | xargs) rails;
rsa_key_size=4096
lets_encrypt="/etc/letsencrypt"

/usr/local/bin/docker-compose build
# Ask for new certificate only when previous was wiped.
if [ $(/usr/local/bin/docker-compose run --rm --entrypoint "/bin/sh -c \"\
        [ ! -f $lets_encrypt/live/$VIRTUAL_HOST/privkey.pem -a\
          ! -f $lets_encrypt/live/$VIRTUAL_HOST/fullchain.pem ] && echo 1\"" service-configuration) ];
then
    /usr/local/bin/docker-compose run --rm --entrypoint "mkdir -p '$lets_encrypt/live/$VIRTUAL_HOST'" service-configuration
    /usr/local/bin/docker-compose run --rm --entrypoint "\
      openssl req -x509 -nodes -newkey rsa:1024 -days 1\
        -keyout '$lets_encrypt/live/$VIRTUAL_HOST/privkey.pem' \
        -out '$lets_encrypt/live/$VIRTUAL_HOST/fullchain.pem' \
        -subj '/CN=localhost'" service-configuration

    /usr/local/bin/docker-compose up --force-recreate -d nginx-tls

    /usr/local/bin/docker-compose run --rm --entrypoint "\
      rm -Rf $lets_encrypt/live/$VIRTUAL_HOST && \
      rm -Rf $lets_encrypt/archive/$VIRTUAL_HOST && \
      rm -Rf $lets_encrypt/renewal/$VIRTUAL_HOST.conf" service-configuration

    case "$LETS_ENCRYPT_EMAIL" in
      "") email_arg="--register-unsafely-without-email" ;;
      *) email_arg="--email $LETS_ENCRYPT_EMAIL --no-eff-email" ;;
    esac
    if [ $LETS_ENCRYPT_DEBUG != "0" ]; then staging_arg="--staging"; fi

    /usr/local/bin/docker-compose run --rm --entrypoint "\
      certbot certonly --webroot -w /var/www/certbot/ \
        $staging_arg \
        $email_arg \
        -d $VIRTUAL_HOST\
        --rsa-key-size $rsa_key_size \
        --agree-tos \
        --force-renewal" service-configuration
fi;
