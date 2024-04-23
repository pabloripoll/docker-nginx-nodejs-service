# This Makefile requires GNU Make.
MAKEFLAGS += --silent

# Settings
C_BLU='\033[0;34m'
C_GRN='\033[0;32m'
C_RED='\033[0;31m'
C_YEL='\033[0;33m'
C_END='\033[0m'

include .env

DOCKER_TITLE=$(PROJECT_TITLE)

CURRENT_DIR=$(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
DIR_BASENAME=$(shell basename $(CURRENT_DIR))
ROOT_DIR=$(CURRENT_DIR)

help: ## shows this Makefile help message
	echo 'usage: make [target]'
	echo
	echo 'targets:'
	egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

# -------------------------------------------------------------------------------------------------
#  System
# -------------------------------------------------------------------------------------------------
.PHONY: hostname fix-permission host-check

hostname: ## shows local machine ip
	echo $(word 1,$(shell hostname -I))
	echo $(ip addr show | grep "\binet\b.*\bdocker0\b" | awk '{print $2}' | cut -d '/' -f 1)

fix-permission: ## sets Frontend directory permission
	$(DOCKER_USER) chown -R ${USER}: $(ROOT_DIR)/

host-check: ## shows this Frontend ports availability on local machine
	cd docker/front && $(MAKE) port-check

# -------------------------------------------------------------------------------------------------
#  Frontend Service
# -------------------------------------------------------------------------------------------------
.PHONY: front-ssh front-set front-create front-start front-stop front-destroy front-install front-update

front-ssh: ## enters the Frontend container shell
	cd docker/front && $(MAKE) ssh

front-set: ## sets the Frontend enviroment file to build the container
	cd docker/front && $(MAKE) env-set

front-create: ## creates the Frontend container from Docker image
	cd docker/front && $(MAKE) build up
	echo $(PROJECT_HOST):$(PROJECT_PORT)

front-start: ## starts the Frontend container running
	cd docker/front && $(MAKE) start

front-dev: ## creates the Frontend container from Docker image
	cd docker/front && $(MAKE) dev

front-stop: ## stops the Frontend container but data will not be destroyed
	cd docker/front && $(MAKE) stop

front-destroy: ## removes the Frontend from Docker network destroying its data and Docker image
	cd docker/front && $(MAKE) clear destroy

front-install: ## installs set version of Frontend into container
	cd docker/front && $(MAKE) app-install

front-update: ## updates set version of Frontend into container
	cd docker/front && $(MAKE) app-update

# -------------------------------------------------------------------------------------------------
#  Repository Helper
# -------------------------------------------------------------------------------------------------
repo-flush: ## clears local git repository cache specially to update .gitignore
	git rm -rf --cached .
	git add .
	git commit -m "fix: cache cleared for untracked files"

repo-commit:
	echo "git add . && git commit -m \"maint: ... \" && git push -u origin main"