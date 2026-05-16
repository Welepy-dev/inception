# Developer Documentation

## Prerequisites

Make sure the following tools are installed on your machine before proceeding:

- **Docker** (Engine 20.10+)
- **Docker Compose** v2 (`docker compose`, not `docker-compose`)
- **make**
- **envsubst** (part of `gettext`, usually pre-installed on Linux)

---

## Repository structure

```
.
├── Makefile
├── secrets/
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   └── wp_editor_password.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/init.sql
        │   └── tools/run.sh
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/www.conf
        │   └── tools/run.sh
        └── nginx/
            ├── Dockerfile
            └── conf/nginx.conf
```

---

## Step 1 — Create the secrets

Create a `secrets/` directory at the **root** of the repository (sibling of `srcs/`, not inside it) and populate it with four files. Each file must contain only the password, with no trailing newline.

```bash
mkdir -p secrets
printf 'your_db_password'       > secrets/db_password.txt
printf 'your_db_root_password'  > secrets/db_root_password.txt
printf 'your_wp_admin_password' > secrets/wp_admin_password.txt
printf 'your_wp_editor_password'> secrets/wp_editor_password.txt
```

These files are consumed by Docker Secrets and mounted read-only at `/run/secrets/<name>` inside each container that needs them.

---

## Step 2 — Create the `.env` file

Create `srcs/.env` with the following variables (adjust values to your setup):

```env
# Database
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser

# WordPress
WP_TITLE=My Inception Site
WP_ADMIN=admin
WP_ADMIN_EMAIL=admin@marcsilv.42.fr
WP_EDITOR=editor
WP_EDITOR_EMAIL=editor@marcsilv.42.fr
DOMAIN_NAME=marcsilv.42.fr
DB_HOST=mariadb
```

> **Do not put passwords here.** Passwords belong in the `secrets/` files.

---

## Step 3 — Build and launch

```bash
make
```

This runs the following under the hood:

```bash
mkdir -p /home/$USER/data/mariadb
mkdir -p /home/$USER/data/wordpress
docker compose -f srcs/docker-compose.yml up --build -d
```

The `--build` flag forces Docker to rebuild all images on every `make` call, ensuring you always run the latest version of your Dockerfiles.

---

## Makefile targets

| Target | Effect |
|--------|--------|
| `make` / `make all` | Create data dirs, build images, start containers in background |
| `make clean` | Stop and remove containers (data is preserved) |
| `make fclean` | Stop containers, remove images, delete volumes and host data dirs |
| `make re` | Full teardown followed by a fresh build and start |

---

## Useful Docker Compose commands

All commands below must be run from the repository root and target the correct compose file.

```bash
# Follow live logs for all services
docker compose -f srcs/docker-compose.yml logs -f

# Follow logs for a single service
docker compose -f srcs/docker-compose.yml logs -f wordpress

# Restart a single service without rebuilding
docker compose -f srcs/docker-compose.yml restart wordpress

# Rebuild and restart a single service
docker compose -f srcs/docker-compose.yml up --build -d wordpress

# Open a shell in a running container
docker exec -it wordpress bash
docker exec -it mariadb bash
docker exec -it nginx bash

# Check health status of all containers
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

---

## Container startup order and health checks

Docker Compose enforces a strict startup sequence using `depends_on` with `condition: service_healthy`:

1. **mariadb** starts first. Its health check runs `mariadb-admin ping` every 5 seconds. WordPress will not start until MariaDB is healthy.
2. **wordpress** starts after MariaDB is healthy. Its health check runs `php-fpm8.2 -t` to validate the FPM configuration. nginx will not start until WordPress is healthy.
3. **nginx** starts last, once WordPress is confirmed healthy.

---

## How data persists

WordPress files and the MariaDB database are stored on the **host machine** using bind mounts:

| Volume name | Host path | Container path |
|-------------|-----------|----------------|
| `wordpress_data` | `~/data/wordpress/` | `/var/www/html` |
| `mariadb_data` | `~/data/mariadb/` | `/var/lib/mysql` |

Both `nginx` and `wordpress` mount `wordpress_data` so that nginx can serve static assets directly without going through PHP-FPM.

The `make fclean` target will **delete these directories** along with all their contents. Use it only when you want a completely clean slate.

---

## How WordPress is initialized

The WordPress `run.sh` script checks whether `wp-includes/version.php` exists in `/var/www/html`. If it does not, it performs a first-time setup:

1. Downloads WordPress core via WP-CLI
2. Creates `wp-config.php` with the database credentials (read from secrets and env vars)
3. Runs `wp core install` to set up the site, title, admin user, and admin email
4. Creates an editor user with the role `editor`

On subsequent starts, the file already exists and these steps are skipped — only `php-fpm8.2 -F` is executed.

---

## MariaDB initialization

The MariaDB `run.sh` script:

1. Reads the two database passwords from `/run/secrets/`
2. Expands environment variables inside `init.sql` using `envsubst`
3. Starts `mariadbd` with `--init_file=/init.sql`, which creates the database, user, grants privileges, and sets the root password on first boot

---

## TLS / HTTPS

The nginx container generates a **self-signed certificate** at build time using OpenSSL:

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx.key \
    -out /etc/ssl/certs/nginx.crt \
    -subj "/CN=login.42.fr"
```

Only **TLS 1.2 and TLS 1.3** are permitted by the nginx configuration (`ssl_protocols TLSv1.2 TLSv1.3`). Older protocol versions are rejected.

PHP requests (files ending in `.php`) are forwarded to the wordpress container via FastCGI on port `9000`. Static files are served directly by nginx from the shared `wordpress_data` volume.
