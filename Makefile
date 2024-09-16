SHELL = /usr/bin/zsh
nvim ?= nvim
nvim_version := '${shell $(nvim) --version}'
XDG_DATA_HOME ?= $(HOME)/.local/share
VIM_DATA_HOME = $(XDG_DATA_HOME)/nvim

default: install

install: create-dirs update-plugins

update: update-repo update-plugins

upgrade: update

create-dirs:
	@mkdir -vp "$(VIM_DATA_HOME)"/{backup,sessions,swap,undo,vsnip}

update-repo:
	git pull --ff --ff-only

update-plugins:
	$(nvim) --headless "+Lazy! sync" +qa
	@echo

uninstall:
	rm -rf "$(VIM_DATA_HOME)"

.PHONY: install create-dirs update-repo update-plugins uninstall
