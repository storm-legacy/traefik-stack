SHELL := /bin/bash

PWD := $(shell pwd)
DOCKER_COMPOSE_FILE := docker-compose.yml

#*
#* GENERAL OPERATIONS
#*
start:
	docker compose -f $(DOCKER_COMPOSE_FILE) up -d

start_%:
	docker compose -f $(DOCKER_COMPOSE_FILE) up -d $*

stop:
	docker compose -f $(DOCKER_COMPOSE_FILE) down --remove-orphans

stop_%:
	docker compose -f $(DOCKER_COMPOSE_FILE) stop $*
	docker compose -f $(DOCKER_COMPOSE_FILE) rm -f $*

down: stop

logs:
	docker compose -f $(DOCKER_COMPOSE_FILE) logs --tail 100

logsf:
	docker compose -f $(DOCKER_COMPOSE_FILE) logs --tail 100 -f

logs_%:
	docker compose -f $(DOCKER_COMPOSE_FILE) logs --tail 100 $*

logsf_%:
	docker compose -f $(DOCKER_COMPOSE_FILE) logs --tail 100 -f $*

status:
	docker compose -f $(DOCKER_COMPOSE_FILE) ps -a

stats:
	docker stats

restart_%:
	docker compose -f $(DOCKER_COMPOSE_FILE) stop $*
	docker compose -f $(DOCKER_COMPOSE_FILE) rm -f $*
	docker compose -f $(DOCKER_COMPOSE_FILE) up -d $*

restart: stop start

build:
	docker compose -f $(DOCKER_COMPOSE_FILE) build

buildnc:
	docker compose -f $(DOCKER_COMPOSE_FILE) build --no-cache

#*
#* CONFIGURATION
#*
create_network:
	docker network create traefik-proxy || true

delete_network:
	docker network rm traefik-proxy

#*
#* HOUSEKEEPING
#*
clean_older_images:
	docker image prune -a -f --filter "until=$(shell date -d '14 days ago' +%s)"
	
clean:
	docker compose -f $(DOCKER_COMPOSE_FILE) down -v --remove-orphans

default: restart