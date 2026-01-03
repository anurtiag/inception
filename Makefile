# Variables
COMPOSE=docker-compose -f srcs/docker-compose.yml
DOMAIN=anurtiag.42.fr


all: up

build: hosts
	$(COMPOSE) build

up: hosts
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v --remove-orphans
	docker volume prune -f

fclean: clean
	sudo rm -fr /home/anurtiag/data/*

restart:
	$(COMPOSE) down
	$(COMPOSE) up -d --build

hosts:
	grep -q "$(DOMAIN)" /etc/hosts || \
		sudo sh -c 'echo "127.0.0.1 $(DOMAIN)" >> /etc/hosts'


.PHONY: all build up down clean restart hosts