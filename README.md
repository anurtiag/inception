# Inception

*This project has been created as part of the 42 curriculum by anurtiag.*

## Description

This project sets up a complete WordPress infrastructure using Docker containers. The goal is to learn containerization, network management, and how modern web applications are deployed.

The stack consists of three services:
- **NGINX** - Web server and reverse proxy (HTTPS)
- **WordPress** - Content management system with PHP-FPM
- **MariaDB** - Relational database

Each service runs in its own Docker container with custom configuration, communicating through an isolated Docker network. Data persists using bind mounts.

## Instructions

### Installation

1. **Install Docker and docker-compose:**
   ```bash
   sudo apt install docker.io docker-compose
   ```

2. **Clone the repository:**
   ```bash
   git clone <url>
   cd inception
   ```

3. **Configure environment variables:**
   - `srcs/.env` - paths and site config
   - `secrets/secrets.env` - database and admin passwords

4. **Create data directories:**
   ```bash
   mkdir -p /home/anurtiag/data/{wordpress,mariadb}
   ```

### Execution

1. **Add domain to /etc/hosts:**
   ```bash
   make hosts
   ```

2. **Build and start services:**
   ```bash
   make up
   ```

3. **Access the website:**
   - Website: `https://anurtiag.42.fr`
   - Admin panel: `https://anurtiag.42.fr/wp-login.php`
   - Credentials: Check `secrets/secrets.env` for your admin user and password

### Compilation/Build

```bash
make build      # Build Docker images only
make up         # Build and start everything
make restart    # Restart all services
make down       # Stop containers (data persists)
make clean      # Delete everything (removes data)
```

## Resources

### Documentation

- [Docker Official Docs](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Developer Docs](https://developer.wordpress.org/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [Linux Networking Guide](https://linux.die.net/man/8/ip)

### AI Usage

**GitHub Copilot** was used for:
- **Debugging Docker configuration** - Helped identify networking issues between NGINX and WordPress
- **Entrypoint script development** - Assisted in writing shell scripts for container initialization (MariaDB setup, WordPress installation)
- **Documentation** - Helped structure and write the README, USER_DOC, and DEV_DOC files
- **Command reference** - Quick lookup for Docker, docker-compose, and Linux commands
- **Learning** - Explaining Docker concepts like networks, volumes, and container lifecycle

**Core decisions** (port configuration, service architecture, data persistence strategy) were made independently. AI was primarily a reference tool and assistant for implementation details.

## Project Description

### Docker and Infrastructure Architecture

This project uses **Docker** to containerize a WordPress application with three core services:

1. **NGINX Container** - Reverse proxy and web server
   - Listens on HTTPS (port 443)
   - Generates self-signed SSL certificates automatically
   - Forwards PHP requests to WordPress container

2. **WordPress Container** - PHP-FPM application server
   - Runs PHP-FPM (FastCGI Process Manager)
   - Executes WordPress code
   - Connects to MariaDB for data

3. **MariaDB Container** - SQL database
   - Stores all WordPress data (posts, users, settings, etc.)
   - Configurable port
   - User-based access control

### Sources and Files

```
inception/
├── Makefile                          # Build automation
├── README.md                         # This file
├── USER_DOC.md                      # User documentation
├── DEV_DOC.md                       # Developer documentation
├── secrets/
│   └── secrets.env                  # Database and admin passwords
├── srcs/
│   ├── docker-compose.yml           # Service orchestration definition
│   ├── .env                         # Environment variables
│   └── requirements/
│       ├── nginx/
│       │   ├── Dockerfile           # NGINX image definition
│       │   ├── conf/
│       │   │   ├── default.conf     # NGINX configuration
│       │   │   └── snippets/
│       │   │       └── fastcgi-php.conf  # PHP-FPM passthrough
│       │   └── tools/
│       │       └── entrypoint.sh    # Certificate generation and startup
│       ├── wordpress/
│       │   ├── Dockerfile           # WordPress + PHP-FPM image
│       │   ├── conf/
│       │   │   └── www.conf         # PHP-FPM pool configuration
│       │   └── tools/
│       │       └── entrypoint.sh    # WordPress installation and setup
│       └── mariadb/
│           ├── Dockerfile           # MariaDB image definition
│           ├── conf/
│           │   └── my.cnf           # MariaDB configuration
│           └── tools/
│               └── entrypoint.sh    # Database initialization
```

### Design Choices

#### Network Architecture
- **Custom Docker Bridge Network** (`inception`) instead of default bridge
- Services communicate by hostname (e.g., `wordpress` talks to `mariadb:3306`)
- Internal network isolated from other Docker containers on the host

#### Data Persistence
- **Bind Mounts** instead of named volumes
- Explicit paths: `/home/anurtiag/data/wordpress/` and `/home/anurtiag/data/mariadb/`
- Data survives container restarts and is easily accessible from host

#### Security
- Services run as non-root users (www-data for WordPress, mysql for MariaDB)
- Passwords stored in separate `secrets/secrets.env` file
- SSL/TLS encryption for all external connections
- Database user has limited privileges (not root)

#### Portability
- Configuration via environment variables
- Port numbers configurable
- Domain name configurable
- Easy to migrate to different machines

## Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker |
|--------|------------------|--------|
| **What it is** | Full operating system with kernel | Lightweight container sharing host kernel |
| **Size** | GBs (1-10 GB per VM) | MBs (50-500 MB per image) |
| **Startup time** | Minutes (boot entire OS) | Seconds (start process) |
| **Overhead** | High (each VM wastes resources) | Low (share OS kernel) |
| **Isolation** | Complete OS isolation | Process-level isolation |
| **Performance** | Slower due to full OS | Native performance |

**Why Docker for this project:** Faster, lighter, easier to manage multiple services, industry standard for web applications.

## Secrets vs Environment Variables

| Aspect | Secrets (`secrets.env`) | Environment Variables (`.env`) |
|--------|------------------------|--------------------------------|
| **Content** | Passwords, API keys, tokens | Configuration, paths, settings |
| **Security** | Should be encrypted/protected | Can be plain text |
| **Visibility** | Should never be in git | Can be in .gitignore safely |
| **Access** | Limited to who needs it | Available to all processes |

**In this project:**
- `secrets/secrets.env` - Contains DB password, WordPress admin credentials (excluded from git)
- `srcs/.env` - Contains paths, domain, port settings (excluded from git)

## Docker Network vs Host Network

| Mode | How it works | Isolation | Use case |
|------|------------|-----------|----------|
| **Bridge (custom)** | Containers on private network, communicate by name | High - services isolated | Multi-container apps (our use) |
| **Host** | Container uses host's network directly | None - container sees all host ports | Single service that needs all ports |
| **None** | No network access | Complete - isolated | Batch jobs, testing |

**Why custom bridge (`inception`):**
- Services talk to each other without exposing to host
- NGINX on port 443 only exposed port to outside world
- WordPress and MariaDB communicate internally, no need to expose
- Can run multiple similar stacks without port conflicts

## Docker Volumes vs Bind Mounts

| Type | Storage location | Management | Portability | Use case |
|------|------------------|------------|-------------|----------|
| **Named Volumes** | `/var/lib/docker/volumes/` (Docker-managed) | Docker controls | High | Production data |
| **Bind Mounts** | User-specified host path | User controls | Lower | Development, explicit paths |
| **tmpfs** | RAM | Temporary | N/A | Sensitive temp data |

**Why Bind Mounts here:**
- Data location is explicit and predictable
- Easy to backup/restore (just copy directories)
- Easy to edit files directly from host if needed
- Works well for development and single-server deployments

**Trade-off:** Less portable (paths hardcoded), but acceptable for this learning project.

## Features

- ✅ Full WordPress installation with admin panel
- ✅ HTTPS with self-signed certificates
- ✅ Isolated Docker network
- ✅ Persistent data storage
- ✅ Configurable ports
- ✅ Automatic WordPress initialization
- ✅ Database user management
- ✅ Non-root service users
- ✅ Easy start/stop/restart

## Troubleshooting Quick Reference

**Can't access website?**
```bash
make hosts              # Add domain to /etc/hosts
docker ps              # Check if containers running
docker logs srcs_nginx_1   # Check for errors
```

**Database connection issues?**
```bash
docker logs srcs_mariadb_1
docker-compose restart mariadb
```

**Forgot password?**
```bash
docker exec -it srcs_mariadb_1 mariadb -u wp_user -p changeme_password mariadb
UPDATE wp_users SET user_pass = MD5('newpass') WHERE user_login = '<your_admin_username>';
FLUSH PRIVILEGES;
```

Replace `<your_admin_username>` with your WP_ADMIN_USER from secrets.env.

See `USER_DOC.md` for more user-level help and `DEV_DOC.md` for developer details.
