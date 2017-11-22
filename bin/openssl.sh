#!/bin/bash
if [ -f ./nginx/ssl/server.cert ];
	then
  echo "SSL Certificates already exist. Skipping.." && exit 0;
else

COMMON_NAME1=${2:-*.$URL_REACT_APP}
#COMMON_NAME2=${2:-*.$ASSETS_DOMAIN}
SUBJECT1="/C=US/ST=NY/L=NewYork/O=DockerSymfonyRest/OU=DockerSymfonyRest/CN=$COMMON_NAME1"
#SUBJECT2="/C=US/ST=NY/L=NewYork/O=Goodsearch/OU=GodblessDevOps/CN=$COMMON_NAME2"

mkdir -p ./nginx/ssl
# echo "Generating ROOT key files"
# openssl genrsa -out rootCA.key 2048;

echo "Generating ROOT pem files"
openssl req -x509 -new -nodes -newkey rsa:2048 \
	-keyout nginx/ssl/server_rootCA.key -sha256 -days 1024 \
	-out nginx/ssl/server_rootCA.pem -subj "$SUBJECT1";
#openssl req -x509 -new -nodes -newkey rsa:2048 \
#	-keyout nginx/ssl/assets_rootCA.key -sha256 -days 1024 \
#	-out nginx/ssl/assets_rootCA.pem -subj "$SUBJECT2";

echo "Generating v3.ext file"
cat <<EOF > ./nginx/ssl/v3.ext
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = $URL_SYMFONY_APP
DNS.2 = $URL_FRONTEND
EOF
# DNS.2 = $ASSETS_DOMAIN

echo "Generating csr files"
#openssl req -new -newkey rsa:2048 -sha256 -nodes \
#	-newkey rsa:2048 -keyout nginx/ssl/assets.key \
#	-subj "$SUBJECT1" \
#	-out nginx/ssl/assets.csr;

openssl req -new -newkey rsa:2048 -sha256 -nodes \
	-newkey rsa:2048 -keyout nginx/ssl/server.key \
	-subj "$SUBJECT1" \
	-out nginx/ssl/server.csr;


echo "Generating certificate file"
#openssl x509 -req -in nginx/ssl/assets.csr \
#	-CA nginx/ssl/assets_rootCA.pem \
#	-CAkey nginx/ssl/assets_rootCA.key \
#	-CAcreateserial \
#	-out nginx/ssl/assets.cert \
#	-days 3650 -sha256 -extfile ./nginx/ssl/v3.ext;

openssl x509 -req -in nginx/ssl/server.csr \
	-CA nginx/ssl/server_rootCA.pem \
	-CAkey nginx/ssl/server_rootCA.key \
	-CAcreateserial \
	-out nginx/ssl/server.cert \
	-days 3650 -sha256 -extfile ./nginx/ssl/v3.ext;

#Make browsers trust to newly generated certificates"
sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" nginx/ssl/server_rootCA.pem; 2> /dev/null
#sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" nginx/ssl/assets_rootCA.pem 2> /dev/null
fi