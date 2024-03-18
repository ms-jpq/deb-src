GH_LATEST := ./libexec/gh-latest.sh $(TMP)
CURL := curl --fail-with-body --location --no-progress-meter

.PHONY: init

init: /usr/bin/envsubst
/usr/bin/envsubst /usr/bin/debsigs /usr/bin/apt-ftparchive /usr/bin/dpkg-scanpackages:
	sudo -- apt-get update
	sudo -- env -- DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --yes -- gettext-base apt-utils debsigs

init: $(VAR)/sh
$(VAR)/sh: | $(VAR)
	if [[ -d '$@' ]]; then
		git -C '$@' pull --recurse-submodules --no-tags '--jobs=$(NPROC)'
	else
		git clone --recurse-submodules --shallow-submodules --depth=1 -- 'https://github.com/ms-jpq/shell_rc' '$@'
	fi
