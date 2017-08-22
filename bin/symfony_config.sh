#!/bin/bash

mkdir -p configs
cat <<EOF > configs/parameters.yml
parameters:
    database_host: db
    database_port: 3306
    database_name: $MYSQL_DATABASE
    database_user: $MYSQL_USER
    database_password: $MYSQL_PASSWORD
    secret: $SYMFONY_SECRET
    mailer_transport:  smtp
    mailer_host:       127.0.0.1
    mailer_user:       ~
    mailer_password:   ~
    jwt_key_pass_phrase: $JWT_KEY_PASS_PHRASE
EOF