#!make
include .env
export $(shell sed 's/=.*//' .env)

docker-env: clone httpauth nginx-config ssl symfony-parameters up composer-install status hosts

dialog:
	@. ./bin/dialog.sh

nginx-config:
	@. ./bin/nginx-config.sh

httpauth:
	@. ./bin/httpauth.sh

ssl:
	@bash ./bin/openssl.sh

symfony-parameters:
	@. ./bin/symfony_config.sh

clone:
	@if cd src 2> /dev/null; then echo "src folder exist."; else mkdir src; fi
	@echo "\n\033[1;m Cloning App (${BRANCH_NAME} branch) \033[0m"
	@if cd src/${PATH_SYMFONY_APP} 2> /dev/null; then git pull origin ${BRANCH_NAME}; else git clone -b ${BRANCH_NAME} ${GIT_SYMFONY_APP} src/${PATH_SYMFONY_APP}; fi
	@if cd src/${PATH_ANGULAR} 2> /dev/null; then git pull origin ${BRANCH_NAME_BUILD}; else git clone -b ${BRANCH_NAME_BUILD} ${GIT_ANGULAR} src/${PATH_ANGULAR}; fi

pull:
	@$(MAKE) --no-print-directory clone
	@$(MAKE) --no-print-directory composer-install
	@$(MAKE) --no-print-directory cache-clear

rebuild: stop
	@echo "\n\033[1;m Rebuilding containers... \033[0m"
	@docker-compose build --no-cache
up:
	@echo "\n\033[1;m Spinning up containers for Local dev environment... \033[0m"
	@docker-compose up -d 
	@$(MAKE) --no-print-directory status

hosts:
	@echo "\n\033[1;m Adding record in to your local /etc/hosts file.\033[0m"
	@echo "\n\033[1;m Please use your local sudo password.\033[0m"
	@echo '127.0.0.1 localhost '${URL_SYMFONY_APP}' www.'${URL_SYMFONY_APP}' '${URL_ANGULAR}' www.'${URL_ANGULAR}''| sudo tee -a /etc/hosts

stop:
	@echo "\n\033[1;m  Halting containers... \033[0m"
	@docker-compose stop
	@$(MAKE) --no-print-directory status

restart:
	@echo "\n\033[1;m Restarting containers... \033[0m"
	@docker-compose stop
	@docker-compose up -d
	@$(MAKE) --no-print-directory status

cache-clear:
	@docker-compose exec app bash -c "cd /var/www/html/${PATH_SYMFONY_APP}/ && php ./bin/console cache:clear --env=prod"
	@docker-compose exec app bash -c "cd /var/www/html/${PATH_SYMFONY_APP}/ && php ./bin/console cache:clear"

status:
	@echo "\n\033[1;m Containers statuses \033[0m"
	@docker-compose ps

clean:
	@echo "\033[1;31m*** Removing containers and Application (./src)... ***\033[0m"
	@$(MAKE) --no-print-directory dialog
	@docker-compose down --rmi all 2> /dev/null
	@rm -rf src/
	@$(MAKE) --no-print-directory status

console-app:
	@docker-compose exec app bash

console-db:
	@docker-compose exec db bash

console-nginx:
	@docker-compose exec web-srv bash

composer-install:
	@docker-compose exec app bash -c "cd /var/www/html/${PATH_SYMFONY_APP}/ && composer install"
	@$(MAKE) --no-print-directory permissions

permissions:
	@docker-compose exec app bash -c "chmod -R 755 /var/www/html/${PATH_SYMFONY_APP}/var/cache /var/www/html/${PATH_SYMFONY_APP}/var/logs"
	@docker-compose exec app bash -c "chown -R www-data:www-data /var/www/html/${PATH_SYMFONY_APP}/var/cache /var/www/html/${PATH_SYMFONY_APP}/var/logs"

schema-update:
	@docker-compose exec app bash -c "cd /var/www/html/${PATH_SYMFONY_APP}/ && php bin/console doctrine:schema:update --force"

migration:
	@docker-compose exec app bash -c "cd /var/www/html/${PATH_SYMFONY_APP}/ && php bin/console doctrine:migrations:migrate"

logs-nginx:
	@docker-compose logs --tail=100 -f web-srv
logs-app:
	@docker-compose logs --tail=100 -f app
logs-db:
	@docker-compose logs --tail=100 -f db

help:
	@echo "clone\t\t\t- clone dev or staging repositories"
	@echo "rebuild\t\t\t- build containers w/o cache"
	@echo "up\t\t\t- start project"
	@echo "stop\t\t\t- stop project"
	@echo "restart\t\t\t- restart containers"
	@echo "status\t\t\t- show status of containers"
	@echo "nginx-config\t\t\t- generates nginx config file based on .env parameters"
	@echo "composer-install\t- install dependencies via composer"
	@echo "schema-update\t\t- update database schema"
	@echo "\033[1;31mclean\t\t\t- !!! Purge all Local application data!!!\033[0m"

	@echo "\n\033[1;mConsole section\033[0m"
	@echo "console-app\t\t- run bash console for dev application container"
	@echo "console-db\t\t- run bash console for mysql container"
	@echo "console-nginx\t\t- run bash console for web server container"

	@echo "\n\033[1;mLogs section\033[0m"
	@echo "logs-nginx\t\t- show web server logs"
	@echo "logs-db\t\t\t- show database logs"
	@echo "logs-app\t\t- show VirMuze dev logs"
	@echo "\n\033[0;33mhelp\t\t\t- show this menu\033[0m"
