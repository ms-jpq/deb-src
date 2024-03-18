.PHONY: pkg

/usr/bin/dpkg-scanpackages:
	sudo -- apt-get update
	sudo -- env -- DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --yes -- dpkg-dev

$(DIST)/Packages: $(PKGS) | /usr/bin/dpkg-scanpackages $(DIST)
	env --chdir '$(@D)' -- dpkg-scanpackages --multiversion -- . >'$@'

pkg: $(DIST)/Packages.gz
$(DIST)/Packages.gz: $(VAR)/dist/Packages
	gzip --keep --no-name --force --best -- '$<'

