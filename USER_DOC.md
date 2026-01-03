# User Documentation

## What is this?

WordPress site with database and HTTPS server.

## Start and Stop

**Start:**
```bash
make up
```

**Stop:**
```bash
make down
```

**Delete everything (removes data):**
```bash
make clean
```

## Access

**Website:**
```
https://anurtiag.42.fr
```

**Admin panel:**
```
https://anurtiag.42.fr/wp-login.php
```

Credentials are in `secrets/secrets.env`:
- WP_ADMIN_USER
- WP_ADMIN_PASSWORD

## Credentials

Check `secrets/secrets.env` for:
- WP_ADMIN_USER / WP_ADMIN_PASSWORD
- WP_USER / WP_USER_PASSWORD

## Check if it works

```bash
# See containers
docker ps

# Check logs
docker logs srcs_nginx_1
docker logs srcs_wordpress_1
docker logs srcs_mariadb_1

# Test connection
curl -vk https://anurtiag.42.fr
```

## Where is my data

```
/home/anurtiag/data/wordpress/   - Files and uploads
/home/anurtiag/data/mariadb/     - Database
```

Data stays here even if containers stop.

## Troubleshooting

**Can't access website:**
- Check `127.0.0.1 anurtiag.42.fr` is in `/etc/hosts`
- Check logs: `docker logs srcs_nginx_1`
- Restart: `make restart`

**Database connection error:**
- Check mariadb logs: `docker logs srcs_mariadb_1`
- Restart: `docker-compose restart mariadb`

**Forgot admin password:**
```bash
docker exec -it srcs_mariadb_1 mariadb -u wp_user -p changeme_password mariadb
UPDATE wp_users SET user_pass = MD5('newpassword') WHERE user_login = '<your_admin_username>';
FLUSH PRIVILEGES;
```

Replace `<your_admin_username>` with your WP_ADMIN_USER from secrets.env.
Then login with new password.
