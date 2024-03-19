MAKEFLAGS += --check-symlink-times
MAKEFLAGS += --jobs
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables
MAKEFLAGS += --shuffle
MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.DELETE_ON_ERROR:
.ONESHELL:
.SHELLFLAGS := --norc --noprofile -Eeuo pipefail -O dotglob -O nullglob -O extglob -O failglob -O globstar -c

.DEFAULT_GOAL := pkg

.PHONY: clean clobber

VAR := ./var
TMP := $(VAR)/tmp
DEB := $(VAR)/deb
PKGS :=

clean:
	shopt -u failglob
	rm -v -rf -- $(DEB) $(TMP)

clobber: clean
	shopt -u failglob
	rm -v -rf -- $(VAR)

$(VAR):
	mkdir -v -p -- '$@'

$(TMP): | $(VAR)
	mkdir -v -p -- '$@'

include makelib/*.mk
