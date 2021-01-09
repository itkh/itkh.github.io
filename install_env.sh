#!/bin/bash
if ! [ -x "$(command -v gem)" ]; then
	echo "Install ruby and ruby-dev";
	sudo apt install ruby ruby-dev build-essential patch zlib1g-dev liblzma-dev;
fi

gem install bundler jekyll
bundle install
