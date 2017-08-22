#!/bin/bash
cat <<EOF > openssl.cnf
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req

[req_distinguished_name]
countryName = RU
countryName_default = RU
stateOrProvinceName = Rostov
stateOrProvinceName_default = Rostov
localityName = Taganrog
localityName_default = Taganrog
organizationalUnitName  = DevOps
organizationalUnitName_default  = DevOps
commonName = *.${SERVER_NAME}
commonName_max  = 64

[ v3_req ]
# Extensions to add to a certificate request
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
EOF