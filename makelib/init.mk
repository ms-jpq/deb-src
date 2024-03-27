.PHONY: init

DPKG_ARCH := $(shell dpkg --print-architecture)
GH_LATEST := ./libexec/gh-latest.sh $(TMP)
CURL := curl --fail-with-body --location --no-progress-meter
UNPACK := $(VAR)/sh/layers/posix/home/.local/opt/initd/libexec/curl-unpack.sh

APT :=
APT += gettext-base apt-utils debsigs

init: $(TMP)/.init
$(TMP)/.init:
	sudo -- apt-get update
	sudo -- env -- DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --yes -- $(APT)
	touch -- '$@'

/usr/bin/envsubst /usr/bin/debsigs /usr/bin/apt-ftparchive /usr/bin/pip: | $(TMP)/.init

$(VAR)/sh: | $(VAR)
	if [[ -d '$@' ]]; then
		git -C '$@' pull --recurse-submodules --no-tags
	else
		git clone --recurse-submodules --shallow-submodules --depth=1 -- 'https://github.com/ms-jpq/shell_rc' '$@'
	fi
