-include .env
-include ~/.env

usage:
	@echo "\033[0;33mDefault commands:\033[0m"
	@echo "\033[0;36m  Code and data change:\033[0m"
	@echo "\033[0;31m    make app_init\033[0m - Start product"
	@echo "\033[0;31m    make app_update\033[0m - Update product"
	@echo "\033[0;31m    make app_reload\033[0m - Reload data"
	@echo "\033[0;31m    make app_master\033[0m - Switch to master"
	@echo "\033[0;31m    make app_switch branch=[branch_name]\033[0m - Switch to [branch_name]"
	@echo "\033[0;36m  Infrastructure:\033[0m"
	@echo "\033[0;31m    make app_open\033[0m - Open product in browser"
	@echo "\033[0;31m    make app_up\033[0m - Up docker"
	@echo "\033[0;31m    make app_down\033[0m - Down docker"
	@echo "\033[0;31m    make app_cache_clear\033[0m - Cache clear for product"
	@echo "\033[0;36m  Status:\033[0m"
	@echo "\033[0;31m    make app_branch\033[0m - Show git branch"
	@echo "\033[0;36m  Test:\033[0m"
	@echo "\033[0;31m    make app_test\033[0m - Run tests"
	@echo "\033[0;36m  Docker:\033[0m"
	@echo "\033[0;31m    make docker_flush\033[0m - Remove all docker containers and networks"

app_init:
	@$(MAKE) _product_name
	@$(MAKE) _docker_compose_up
	@$(MAKE) _composer_install
	@$(MAKE) _cache_clear
	@$(MAKE) _migration
	@$(MAKE) _console_message message="You can open project http://${DOCKER_IP}:${PROJECT_PORT_PREFIX}080"
	@$(MAKE) _notification message="Project init successfully"

app_update:
	@$(MAKE) _product_name
	@$(MAKE) _update
	@$(MAKE) _notification message="Project update successfully"

app_reload: _product_name _reload
	@$(MAKE) _notification message="Data reloaded successfully"

app_master:
	@$(MAKE) app_switch branch=master
	@$(MAKE) _notification message="Project switched to master and updated"

app_switch:
	@$(MAKE) _product_name
	@$(MAKE) _checkout
	@$(MAKE) _update
	@$(MAKE) _notification message="Project switched and updated"

app_open: _product_name _open
	@$(MAKE) _console_message message="Or you can open project http://${DOCKER_IP}:${PROJECT_PORT_PREFIX}080"

app_up: _product_name _docker_compose_up
	@$(MAKE) _notification message="Docker containers up"

app_down: _product_name _docker_compose_down
	@$(MAKE) _notification message="Docker containers down"

app_cache_clear: _product_name _cache_clear
	@$(MAKE) _notification message="Cache clear complete"

app_branch: _product_name _branch

app_test: _product_name _test
	@$(MAKE) _notification message="Test finished"

docker_flush: _docker_flush
	@$(MAKE) _notification message="Docker flush complete"


_reload: _flush _fixtures

_update:
	@$(MAKE) _pull
	@$(MAKE) _docker_compose_up
	@$(MAKE) _composer_install
	@$(MAKE) _cache_clear
	@$(MAKE) _migration

_product_name:
	@(tput bold && tput setaf 3 && echo "[${PROJECT_NAME}]" && tput sgr0)

_notification:
	@osascript -e 'display notification "Successful" with title "$(message)" subtitle ${PROJECT_NAME}'

_console_message:
	@(tput bold && tput setaf 3 && echo "[${PROJECT_NAME}]" && tput sgr0 && echo "$(message)")

_pull:
	git pull

_composer_install:
	composer install --no-interaction --no-scripts --ignore-platform-reqs

_cache_clear:
	rm -rf var/cache/*

_migration:
	@./bin/util doctrine:database:create --if-not-exists
	@./bin/util doctrine:migrations:migrate --allow-no-migration --no-interaction

_flush:
	@./bin/util doctrine:schema:drop --force --full-database
	@./bin/util doctrine:migrations:migrate --allow-no-migration --no-interaction

_fixtures:
	@echo "No fixtures"

_docker_compose_up:
	docker-compose up -d --build

_docker_compose_down:
	docker-compose down

_test:
	@echo "No test"

_branch:
	@tput bold && tput setaf 3 && git rev-parse --abbrev-ref HEAD && tput sgr0

_checkout:
	git fetch && (git checkout $(branch) 2> /dev/null || true)

_open:
	open http://${DOCKER_IP}:${PROJECT_PORT_PREFIX}080

_docker_flush:
	@docker rm -f `docker ps -aq` &> /dev/null || true
	@docker network rm common_network &> /dev/null || true