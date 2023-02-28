# vim:tw=0:ts=2:sw=2:et:norl:ft=make
# Author: Landon Bouma <https://tallybark.com/>
# Project: https://github.com/DepoXy/myrepos-mredit-command#🧜
# License: MIT

# USAGE:
#   PREFIX=~/.local make install

# COPYD: This Makefile modified from a copy of git-put-wise's:
#   https://github.com/DepoXy/git-put-wise#🥨

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

PREFIX ?= /usr/local
BINPREFIX ?= "$(PREFIX)/bin"
SHELL := bash

BINS = bin/mredit bin/mropen

default: install

install:
	@mkdir -p $(DESTDIR)$(BINPREFIX)
	@echo "... installing bins to $(DESTDIR)$(BINPREFIX)"
	@$(foreach BIN, $(BINS), \
		echo "  ... symlinking $(DESTDIR)$(BINPREFIX)/$(notdir $(BIN))"; \
		ln -sfn "$$(realpath $(BIN))" "$(DESTDIR)$(BINPREFIX)/"; \
	)

uninstall:
	@$(foreach BIN, $(BINS), \
		echo "... uninstalling $(DESTDIR)$(BINPREFIX)/$(notdir $(BIN))"; \
		rm -f $(DESTDIR)$(BINPREFIX)/$(notdir $(BIN)); \
	)

.PHONY: default install uninstall

