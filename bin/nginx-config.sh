#!/bin/bash
HASH="$(openssl passwd -apr1 $HTTP_PASSWORD)"
echo "$APP_NAME:$HASH" > $(pwd)/nginx/configs/.htpasswd

mkdir -p nginx/configs/conf.d
#mkdir -p nginx/configs/ssl

cat <<EOF > nginx/configs/conf.d/$SERVER_NAME.conf
server {
    listen 80;
    #listen 443 ssl;
    #ssl_certificate /etc/nginx/ssl/$SERVER_NAME.cert;
    #ssl_certificate_key /etc/nginx/ssl/$SERVER_NAME.key;

    #auth_basic "Restricted";
    #auth_basic_user_file /etc/nginx/.htpasswd;

    root /var/www/html/$APP_NAME/web;

	server_name $SERVER_NAME www.$SERVER_NAME;

    #if (\$scheme = http) {
    #    return 301 https://$URL_API\$request_uri;
    #}

    if (\$host ~* www\.(.*)) {
        return 301 http://\$server_name\$request_uri;
    }

	location / {
        try_files \$uri /app.php\$is_args\$args;
    }

    location ~ ^/app\.php(/|$) {
        fastcgi_pass app:9000;
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT \$realpath_root;
    }
}
EOF