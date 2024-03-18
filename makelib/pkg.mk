.PHONY: pkg

$(DIST)/Packages: $(PKGS) | /usr/bin/dpkg-scanpackages $(DIST)
	env --chdir '$(@D)' -- dpkg-scanpackages --multiversion -- . >'$@'

pkg: $(DIST)/Packages.gz
$(DIST)/Packages.gz: $(DIST)/Packages
	gzip --keep --no-name --force -- '$<'

$(DIST)/Release: $(DIST)/Packages.gz | /usr/bin/apt-ftparchive $(DIST)
	env --chdir '$(@D)' -- apt-ftparchive release . >'$@'

pkg: $(DIST)/InRelease
$(DIST)/InRelease: $(DIST)/Release
	gpg --batch --clearsign --yes --output '$@' -- '$<'
