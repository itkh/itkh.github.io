SHELL := /bin/bash

install: ## Install requirements
ifeq (, $(shell which gem))
	sudo apt install ruby ruby-dev build-essential patch zlib1g-dev liblzma-dev;
endif
	sudo gem install bundler jekyll
	bundle install

serve: ## Run Bundle exec jekyll serve
	@bundle exec jekyll serve

add: ## Add symbol link markdown file to _post directory
ifndef FILE
	$(error File is NOT provided. [Usage] FILE=/path/to/file make add)
endif
	ln -s -f `realpath $(FILE)` ./_posts/

clean: ## Find and delete broken symbol link
	@find ./_posts/ -xtype l -delete

help: ## Show this help menu.
	@echo "Usage: make [TARGET ...]"
	@echo
	@grep -E '^[0-9a-zA-Z_%-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
.EXPORT_ALL_VARIABLES:
.PHONY: help \
