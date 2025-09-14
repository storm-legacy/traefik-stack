-include .env.example

DOCKER_CMD := docker
DOCKER_COMPOSE_CMD := $(DOCKER_CMD) compose -f compose.yml

-include .env

# use example compose file
ifeq ($(FULL_EXAMPLE),true)
	DOCKER_COMPOSE_CMD += -f compose.example.yml
endif


default: init

init: __init create_network start

__init:
	cp -fn .env.example .env

#*
#* DOCKER OPTIONS
#*
start up:
	$(DOCKER_COMPOSE_CMD) up -d

start_% up_%:
	$(DOCKER_COMPOSE_CMD) up -d $*

stop down:
	$(DOCKER_COMPOSE_CMD) down --remove-orphans

stop_% down_%:
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
	$(DOCKER_CMD) network create --subnet $(TRAEFIK_PROXY_NETWORK_SUBNET) $(TRAEFIK_PROXY_NETWORK_NAME) || true

delete_network:
	$(DOCKER_CMD) network rm $(TRAEFIK_PROXY_NETWORK_NAME)

remove_example:
	rm -f dynamic_conf/*.example.yml

__arm_project:
	rm -f .git

clean: __clean_compose delete_network

__clean_compose:
	$(DOCKER_COMPOSE_CMD) down -v --remove-orphans