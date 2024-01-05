# TRAEFIK STACK
Traefik stack used for fast deployment with preconfigured settings.

## Quickstart
### Dependencies
- Docker Engine
- Docker Compose
- GNU Make

Clone repository:
```bash
$ git clone https://github.com/storm-legacy/traefik-stack.git
```

Generate AuthDigest credentials via
```bash
$ docker run -it --rm --name httpd httpd:2.4-alpine sh
[$] htdigest -c digest_file traefik USERNAME
[$] cat digest_file
[$] exit
```

Modify auth label in `docker-compose.yml` configuration file:
```yaml
    labels:
        ...
      - "traefik.http.middlewares.dashboard-auth.digestauth.users=username:traefik:912e9580b71cd9ea70096bb9aac678ee"
```

Create docker network
```bash
$ make create_network
```

Start project
```bash
$ make start
```

Stop project
```bash
$ make down
```