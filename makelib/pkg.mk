.PHONY: pkg

/usr/bin/dpkg-sig /usr/bin/apt-ftparchive /usr/bin/dpkg-scanpackages:
	sudo -- apt-get update
	sudo -- env -- DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --yes -- apt-utils dpkg-sig

$(DIST)/Packages: $(PKGS) | /usr/bin/dpkg-scanpackages $(DIST)
	env --chdir '$(@D)' -- dpkg-scanpackages --multiversion -- . >'$@'

pkg: $(DIST)/Packages.gz
$(DIST)/Packages.gz: $(DIST)/Packages
	gzip --keep --no-name --force -- '$<'

$(DIST)/Release: $(DIST)/Packages | /usr/bin/apt-ftparchive $(DIST)
	env --chdir '$(@D)' -- apt-ftparchive release . >'$@'

pkg: $(DIST)/InRelease
$(DIST)/InRelease: $(DIST)/Release
	gpg --batch --clearsign --yes --output '$@' -- '$<'
