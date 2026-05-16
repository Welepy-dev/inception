*This project has been created as part of the 42 curriculum by marcsilv.*

# Inception

## Description

Inception is a system administration project that builds a small, self-contained web infrastructure using **Docker** and **Docker Compose**. The goal is to set up a working WordPress website served over HTTPS, using only custom-built containers — no pre-made images from Docker Hub (except the base OS image).

### Services

The stack is composed of three containers, all running on an isolated Docker bridge network:

| Container | Role |
|-----------|------|
| **nginx** | Reverse proxy, TLS termination (HTTPS only, TLS 1.2/1.3) |
| **wordpress** | PHP-FPM application server running WordPress |
| **mariadb** | Relational database backend |

Each container is built from a custom `Dockerfile` based on `debian:bookworm`. No pre-made application images are used.

### Design Choices

#### Virtual Machines vs Docker

Virtual Machines emulate full hardware and run a complete OS kernel, making them heavy but strongly isolated. Docker containers share the host kernel and package only the application and its dependencies, making them lightweight, fast to start, and efficient with resources. For a self-contained web stack like this one, containers are the right tool: reproducible, portable, and easy to orchestrate.

#### Secrets vs Environment Variables

Environment variables are convenient but are visible to any process inside the container and can leak through `docker inspect` or log files. Docker Secrets are mounted as in-memory files at `/run/secrets/` and are only accessible to the specific container that needs them. All passwords in this project (database password, root password, WordPress admin/editor passwords) are managed as Docker Secrets, while non-sensitive configuration (usernames, hostnames, site title) is passed through an `.env` file.

#### Docker Network vs Host Network

With `network_mode: host`, a container shares the host's network stack directly — there is no isolation and port conflicts become a real concern. This project uses a named **bridge network** (`inception`), which gives each container its own virtual network interface and lets them communicate by service name (e.g. `wordpress:9000`, `mariadb:3306`) while remaining isolated from the host. Only port 443 is exposed to the outside world via the nginx container.

#### Docker Volumes vs Bind Mounts

Docker-managed volumes store data in an opaque location under `/var/lib/docker/volumes/` and are handled entirely by the Docker daemon. **Bind mounts** map a specific path on the host filesystem into the container. This project uses bind mounts so that data is stored at predictable, human-readable locations (`~/data/wordpress/` and `~/data/mariadb/`), making backups and inspection straightforward. The Makefile creates those directories automatically before starting the stack.

---

## Instructions

### Prerequisites

- Docker and Docker Compose v2 installed
- `make` available
- A `secrets/` directory at the root of the repository containing four files (see [DEV_DOC.md](DEV_DOC.md))
- A `.env` file inside `srcs/` (see [DEV_DOC.md](DEV_DOC.md))

### Build and run

```bash
make
```

This will create the data directories, build the images, and start the stack in detached mode.

### Stop

```bash
make clean
```

### Full teardown (removes containers, images, volumes, and data)

```bash
make fclean
```

### Rebuild from scratch

```bash
make re
```

Once running, the site is available at `https://marcsilv.42.fr` (or `https://localhost` if running locally).

---

## Resources

### Documentation

- [Docker official documentation](https://docs.docker.com/)
- [Docker Compose reference](https://docs.docker.com/compose/)
- [Docker Secrets](https://docs.docker.com/engine/swarm/secrets/)
- [nginx documentation](https://nginx.org/en/docs/)
- [WordPress CLI (WP-CLI)](https://wp-cli.org/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [PHP-FPM configuration](https://www.php.net/manual/en/install.fpm.configuration.php)
- [OpenSSL self-signed certificates](https://www.openssl.org/docs/)

### Articles and tutorials

- [Understanding Docker networking](https://docs.docker.com/network/)
- [Best practices for Docker secrets](https://docs.docker.com/engine/swarm/secrets/#about-secrets)
- [Difference between VMs and containers — Docker blog](https://www.docker.com/resources/what-container/)
- [FastCGI and PHP-FPM explained](https://www.nginx.com/resources/glossary/php-fpm/)

### AI usage

Claude (Anthropic) was used to assist with the writing of this documentation (README.md, USER_DOC.md, DEV_DOC.md). The actual project code — Dockerfiles, shell scripts, nginx and PHP-FPM configuration, SQL init script, and Docker Compose file — was written manually without AI generation.
