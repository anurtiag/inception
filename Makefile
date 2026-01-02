# Variables
COMPOSE=docker-compose -f srcs/docker-compose.yml

.PHONY: all build up down clean restart hosts

all: up

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down -v

clean:
	$(COMPOSE) down -v --remove-orphans
	docker volume prune -f

restart:
	$(COMPOSE) down
	$(COMPOSE) up -d --build

# Añade la entrada de hosts local si falta
hosts:
	grep -q "anurtiag.42.fr" /etc/hosts || \
		sudo sh -c 'echo "127.0.0.1 anurtiag.42.fr" >> /etc/hosts'
