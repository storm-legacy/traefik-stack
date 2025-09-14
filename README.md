The Traefik stack is a quick-start project that can be promptly deployed to the target machine with [Docker](https://www.docker.com/) installed. It uses the fantastic reverse proxy called [Traefik](https://doc.traefik.io/traefik/) and provides the bare minimum with examples that give a head start on the tedious task of setting up the web app environment. The project shows some examples of how applications can be configured and demonstrates them working in practice.

<br/>

# Dependencies
- Docker
- Docker Compose
- make (optional)
- git (optional)

Docker installation steps for your operating system can be found in the [official documentation](https://docs.docker.com/engine/install/). `make` and `git` are, in most cases, provided by your distro’s package manager, or they need to be additionally installed on Windows. Example for Debian/Ubuntu:

```bash
sudo apt-get update \
&& sudo apt-get install --no-install-recommends git make
```
Make sure Docker is working after the new installation. Your user must be in the docker group, and the Docker service must be running:
```bash
sudo systemctl status docker
# [...] Active: active (running) since Thu 1970-01-01 00:00:00 CEST; 1h 01min ago [...]

sudo docker --version
# Docker version 28.3.3, build 980b856

docker --version
# Docker version 28.3.3, build 980b856

docker ps
# CONTAINER ID  IMAGE COMMAND CREATED STATUS  PORTS
```
# Quickstart
It is highly encouraged to look into the `compose.yml`, `.env.example`, and `dynamic_conf/*` files to get familiar with the Traefik configuration and how traffic forwarding is set up.

## Clone repository
```bash
git clone https://github.com/storm-legacy/traefik-stack.git
```

## Automatic (quick)
If you have installed all dependencies and already cloned the repository, you can do everything at once with a single command. For more information, check the Makefile.
```bash
make
# or
make init
```

## Semi-manual (slower)
If you want to have a little more control over the process, you can use the steps provided below. Example commands will use the default values provided in `.env.example`.

### Copy .env.example -> .env
There are some defaults that are later used by the `Makefile` and `compose.yml`. These can be adjusted if needed.
```bash
# make __init
cp -fn .env.example .env
```

### Create proxy network
This network is used for routing traffic to and from the Traefik container.
```bash
# make create_network
docker network create --subnet 172.60.0.0/16 traefik-proxy
```

### Adjust timezone
```.env
# .env
TZ=Europe/Warsaw
```

### Specify full example run
If you want to run the entire example, make sure the `FULL_EXAMPLE` variable is set to `true`. In any other case, use a non-`true` value:
```.env
# .env
FULL_EXAMPLE=true
```

### Remove unnecessary configuration files
In the `dynamic_conf` directory, there are a few configuration files that can be safely removed if the example is not supposed to run. These can be removed with:
```bash
make remove_example
```
Although anything else in dynamic_conf can also be removed, at some point it is worth asking yourself whether you even need this project if you are going to remove the majority of it (better to start clean).

### Start the project
```bash
# docker compose -f compose.yml -f compose.example.yml up -d # (ommit -f compose.example.yml on no-example variant)
make start
```

## Certificates
The provided stack has basic automatic TLS certificate renewal, but for it to work properly, a few steps should be performed to ensure it functions correctly. Before anything else, make sure the domain is pointing to the correct IP address of the server and that Traefik is accessible from the Internet.

### Configure staging certificates
Open `compose.yml` and uncomment the line below the `command:` block:
```yml
- "--certificatesresolvers.le.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory"

```
This allows for certificate testing without the risk of being rate-limited in case of many failed iterations. It can be latter reversed for the production certificates usage.

### Provide correct email and enable TLS_CHALLENGE in `.env`;
```.env
# .env
TRAEFIK_LE_TLS_CHALLENGE=true
TRAEFIK_LE_MAIL=my.email@correctdomain.com
```

### Restart the project
```bash
# docker compose -f compose.yml down
# docker compose -f compose.yml up -d
make restart
```

# Examples
Various services are configured with different levels of priority, which enables the use of administration applications in subpaths and the main application on the root domain.

Here is a list of all example configured services:

| Service            | URL                       | User:Password                  | Traefik Config File                  |
| ------------------ | ------------------------- | ------------------------------ | ------------------------------------ |
| MySQL + phpMyAdmin | `https://localhost/pma/`  | `[none]`                       | `dynamic_conf/phpmyadmin.example.yml` |
| PostgreSQL + pgAdmin | `https://localhost/pgadmin/` | `pgadmin@example.com:password` | `dynamic_conf/pgadmin.example.yml`   |
| Frontend           | `https://localhost/`      | `[none]`                       | `dynamic_conf/app.example.yml`       |
| Backend            | `https://localhost/api/`  | `[none]`                       | `dynamic_conf/app.example.yml`       |
