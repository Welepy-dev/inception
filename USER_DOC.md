# User & Administrator Documentation

## What does this stack provide?

Once running, the Inception stack gives you:

- A **WordPress website** accessible over HTTPS at `https://marcsilv.42.fr`
- A **WordPress administration panel** at `https://marcsilv.42.fr/wp-admin`
- A **MariaDB database** used internally by WordPress (not exposed outside the stack)

All traffic goes through an **nginx** reverse proxy that enforces HTTPS (TLS 1.2 and 1.3 only). Plain HTTP is not available.

---

## Starting the project

From the root of the repository, run:

```bash
make
```

This single command will:
1. Create the data directories on your host machine (`~/data/wordpress/` and `~/data/mariadb/`)
2. Build all Docker images
3. Start the three containers in the background

The first startup takes longer because Docker must build the images and WordPress must be installed. Subsequent starts are much faster.

---

## Stopping the project

To stop the containers without deleting any data:

```bash
make clean
```

Your WordPress files and database will be preserved and will be available the next time you run `make`.

---

## Accessing the website

Open your browser and navigate to:

```
https://marcsilv.42.fr
```

> **Note:** The TLS certificate is self-signed, so your browser will show a security warning. This is expected. You can safely proceed by accepting the exception.

### WordPress administration panel

```
https://marcsilv.42.fr/wp-admin
```

Log in with the admin credentials defined in your secrets files (see below).

---

## Credentials and secrets

All passwords are stored as plain text files in the `secrets/` directory at the root of the repository (one level above `srcs/`). This directory is **never committed to Git**.

| File | Contains |
|------|----------|
| `secrets/db_password.txt` | MariaDB password for the WordPress database user |
| `secrets/db_root_password.txt` | MariaDB root password |
| `secrets/wp_admin_password.txt` | WordPress admin account password |
| `secrets/wp_editor_password.txt` | WordPress editor account password |

Non-sensitive configuration (usernames, site title, domain name, etc.) is stored in `srcs/.env`.

To find your WordPress admin username, check the `WP_ADMIN` variable in `srcs/.env`.  
To find your WordPress editor username, check the `WP_EDITOR` variable in `srcs/.env`.

---

## Checking that services are running

### View running containers

```bash
docker ps
```

You should see three containers listed: `nginx`, `wordpress`, and `mariadb`, all with status `Up`.

### Check container health

```bash
docker ps --format "table {{.Names}}\t{{.Status}}"
```

Both `mariadb` and `wordpress` have Docker health checks configured. Their status will show `(healthy)` when ready.

### View logs for a specific service

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

### Test HTTPS connectivity

```bash
curl -k https://localhost
```

A successful response will return the HTML of the WordPress homepage.
