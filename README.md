# Traefik Stack Project
This is a quick-start project with a base configuration that allows for fast deployment on the target server when needed. It is meant to be cloned, initialized, tweaked to the need, and started. It does on purpose skip configuration of additional networks, services, and OS-level things like firewalls, server configuration, etc.

## Quickstart
There are some defaults that will just work, but in case of further changes you might want to just remove directory `.git` and just configure settings to your liking.

### Important
- Remember to adjust your configuration for Let's Encrypt. Try to avoid being [rate limited](https://letsencrypt.org/docs/rate-limits/). If you're not sure that your configuration is correct, uncomment line. It will point to [staging environment](https://letsencrypt.org/docs/staging-environment/) for Let's Encrypt certificates generation:
  ```
  - "--certificatesresolvers.le.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory"
  ```

### Requirements
- Docker Engine
- Docker Compose Plugin
- GNU Makefile *(optionaly)*
- Python *(optionaly)*

Clone repository:
```bash
git clone https://github.com/storm-legacy/traefik-stack.git
```

### Quick (via Makefile)
Initialize project via command below. You will be asked for username and password, but that should be it.
```bash
make init
```

### Manual
Copy `.env.example` configuration file to `.env` (**-f**orce, **--n**o-clobber - skip existing, don't ask questions)
```bash
cp -fn .env.example .env
```

Generate credentials for DigestAuth plugin, there is neat python script that can make that quickly.
```bash
python3 ./script.py gen:digest --save [USERNAME] [PASSWORD]
```

Or Alternatively with some Docker magic (run line by line):
```bash
docker run -it --rm --name httpd httpd:2.4-alpine sh

  htdigest -c digest_file traefik USERNAME
  cat digest_file
  exit
```

Modify `TRAEFIK_DIGESTAUTH_USERS` in `.env` to the generated value (it does not default to `admin:admin`, trust me bro). Adjust other settings if needed:
```bash
TRAEFIK_DIGESTAUTH_USERS=admin:traefik:817374111f31cc282162486425ee5e9e
```

Create docker network for services to connect to (`traefik-proxy` can changed based on your `.env` configuration):
```bash
docker network create traefik-proxy
```

Start project:
```bash
docker compose up -d
```
