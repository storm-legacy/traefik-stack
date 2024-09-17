-include .env.example
-include .env

COMPOSE_FILE := compose.yml

DOCKER_CMD := docker
DOCKER_COMPOSE_CMD := $(DOCKER_CMD) compose

default: init

init: __init start

__init:
	cp -fn .env.example .env

#*
#* GENERAL OPERATIONS
#*
start:
	$(DOCKER_COMPOSE_CMD) up -d

start_%:
	$(DOCKER_COMPOSE_CMD) up -d $*

stop:
	$(DOCKER_COMPOSE_CMD) down --remove-orphans

stop_%:
	$(DOCKER_COMPOSE_CMD) stop $*
	$(DOCKER_COMPOSE_CMD) rm -f $*

down: stop

logs:
	$(DOCKER_COMPOSE_CMD) logs --tail 100

logsf:
	$(DOCKER_COMPOSE_CMD) logs --tail 100 -f

logs_%:
	$(DOCKER_COMPOSE_CMD) logs --tail 100 $*

logsf_%:
	$(DOCKER_COMPOSE_CMD) logs --tail 100 -f $*

status:
	$(DOCKER_COMPOSE_CMD) ps -a

stats:
	docker stats

restart_%:
	$(DOCKER_COMPOSE_CMD) stop $*
	$(DOCKER_COMPOSE_CMD) rm -f $*
	$(DOCKER_COMPOSE_CMD) up -d $*

restart: stop start

build:
	$(DOCKER_COMPOSE_CMD) build

buildnc:
	$(DOCKER_COMPOSE_CMD) build --no-cache

#*
#* CONFIGURATION
#*
create_network:
	$(DOCKER_CMD) network create $(TRAEFIK_PROXY_NETWORK_NAME) || true

delete_network:
	$(DOCKER_CMD) docker network rm $(TRAEFIK_PROXY_NETWORK_NAME)

#*
#* HOUSEKEEPING
#*
clean_older_images:
	$(DOCKER_CMD) image prune -a -f --filter "until=$(shell date -d '14 days ago' +%s)"

clean:
	$(DOCKER_COMPOSE_CMD) down -v --remove-orphans

default: restart