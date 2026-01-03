# Developer Documentation

## Initial Setup

1. **Install Docker and docker-compose**
   ```bash
   sudo apt install docker.io docker-compose
   ```

2. **Clone and enter repo:**
   ```bash
   git clone <url> && cd inception
   ```

3. **Configure variables:**
   - `srcs/.env` - paths and config
   - `secrets/secrets.env` - passwords

4. **Create data directories:**
   ```bash
   mkdir -p /home/anurtiag/data/{wordpress,mariadb}
   ```

5. **Add local domain:**
   ```bash
   make hosts
   ```

## Build and Start

```bash
make build   # Build images only
make up      # Build and start
```

## Useful Commands

```bash
# View logs
docker-compose logs -f

# View containers
docker ps

# Enter container
docker exec -it srcs_wordpress_1 /bin/bash

# Access MariaDB
docker exec -it srcs_mariadb_1 mariadb -u wp_user -p changeme_password

# Restart service
docker-compose restart nginx

# Check ports
docker ps | grep -E "PORTS|nginx"
```

## Data Locations

**WordPress:** `/home/anurtiag/data/wordpress/`
**MariaDB:** `/home/anurtiag/data/mariadb/`

Persists even when stack is stopped.

## Change Ports

**NGINX in `srcs/docker-compose.yml`:**
```yaml
nginx:
  ports:
    - "8443:443"
```
Then access via `https://anurtiag.42.fr:8443`

**MariaDB in `srcs/.env`:**
```dotenv
MARIADB_PORT=3307
```
Automatically passed to WordPress.

## Important Files

- `srcs/docker-compose.yml` - Orchestration
- `srcs/requirements/nginx/conf/default.conf` - NGINX config
- `srcs/requirements/wordpress/tools/entrypoint.sh` - WordPress init
- `srcs/requirements/mariadb/tools/entrypoint.sh` - MariaDB init

## Debugging

```bash
# Watch what's happening
docker logs srcs_nginx_1 -f

# Check PHP errors
docker logs srcs_wordpress_1 | grep -i error

# Check DB errors
docker logs srcs_mariadb_1 | grep -i error

# Test connectivity
docker exec srcs_wordpress_1 mysql -h mariadb -u wp_user -p changeme_password -e "SELECT 1;"

# Check ports in use
sudo ss -tln | grep LISTEN
```

## Make Targets

```bash
make up       # Build + start
make down     # Stop (data persists)
make restart  # Restart all
make clean    # Remove everything (deletes data)
make build    # Build images only
make hosts    # Add domain to /etc/hosts
```
