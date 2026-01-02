# Variables
COMPOSE=docker-compose -f srcs/docker-compose.yml


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

fclean: clean
	sudo rm -fr /home/anurtiag/data/*

restart:
	$(COMPOSE) down
	$(COMPOSE) up -d --build


.PHONY: all build up down clean restart hosts