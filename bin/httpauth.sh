#!/bin/bash
mkdir -p nginx/configs/conf.d
HASH="$(openssl passwd -apr1 $HTTP_PASSWORD)"
echo "$APP_NAME:$HASH" > $(pwd)/nginx/configs/.htpasswd
