#!/bin/bash
mkdir -p nginx/configs/conf.d

ANGULAR_ROOT_PATH="$(if [ $ENV = "local" ]; then
			    echo "/var/www/html/$PATH_ANGULAR/dist"
            else
                echo "/var/www/html/$PATH_ANGULAR"
			fi;)"

cat <<EOF > nginx/configs/conf.d/$URL_ANGULAR.conf
server {
    listen 80;
    listen 443 ssl;
    ssl_certificate /etc/nginx/ssl/server.cert;
    ssl_certificate_key /etc/nginx/ssl/server.key;

    # auth_basic "Restricted";
    # auth_basic_user_file /etc/nginx/.htpasswd;

    root '${ANGULAR_ROOT_PATH}';
    server_name $URL_ANGULAR www.$URL_ANGULAR;

    if (\$scheme = http) {
       return 301 https://$URL_ANGULAR\$request_uri;
    }

    if (\$host ~* www\.(.*)) {
        return 301 https://\$server_name\$request_uri;
    }

    # SSL cache
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # prevent users from opening in an iframe
    add_header X-Frame-Options SAMEORIGIN;

    # prevent hacker scanners
    if ( \$http_user_agent ~* (nmap|nikto|wikto|sf|sqlmap|bsqlbf|w3af|acunetix|havij|appscan) ) {
        return 403;
    }

    charset utf8;

    location / {
        try_files \$uri\$args \$uri\$args/ /index.html;
    }

    location ~* ^.+\.(jpg|jpeg|gif|png|ico|svg|eot|ttf|woff|woff2|json|js|css|mp3|ogg|mpe?g|avi|zip|gz|bz2?|rar|swf|br)$ {
      root '${ANGULAR_ROOT_PATH}';
      expires max;
      log_not_found off;
    }
}
EOF

cat <<EOF > nginx/configs/conf.d/$URL_SYMFONY_APP.conf
server {
    listen 80;
    listen 443 ssl;
    ssl_certificate /etc/nginx/ssl/server.cert;
    ssl_certificate_key /etc/nginx/ssl/server.key;

    # auth_basic "Restricted";
    # auth_basic_user_file /etc/nginx/.htpasswd;

    if (\$scheme = http) {
      return 301 https://$URL_SYMFONY_APP\$request_uri;
    }

    if (\$host ~* www\.(.*)) {
        return 301 http://\$server_name\$request_uri;
    }

    server_name $URL_SYMFONY_APP www.$URL_SYMFONY_APP;
    root /var/www/html/$PATH_SYMFONY_APP/web;

    # cache files
	open_file_cache max=1000 inactive=20s;
    open_file_cache_valid 30s;
    open_file_cache_min_uses 2;
    open_file_cache_errors on;

    # SSL cache
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # prevent users from opening in an iframe
    add_header X-Frame-Options SAMEORIGIN;

    # prevent hacker scanners
    if ( \$http_user_agent ~* (nmap|nikto|wikto|sf|sqlmap|bsqlbf|w3af|acunetix|havij|appscan) ) {
        return 403;
    }

    charset utf8;

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