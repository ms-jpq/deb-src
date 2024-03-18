.PHONY: pkg

$(DEB)/Packages: $(PKGS) | /usr/bin/dpkg-scanpackages $(DEB)
	env --chdir '$(@D)' -- dpkg-scanpackages --multiversion -- . >'$@'

pkg: $(DEB)/Packages.gz
$(DEB)/Packages.gz: $(DEB)/Packages
	gzip --keep --no-name --force -- '$<'

$(DEB)/Release: $(DEB)/Packages.gz | /usr/bin/apt-ftparchive $(DEB)
	env --chdir '$(@D)' -- apt-ftparchive release . >'$@'

pkg: $(DEB)/InRelease
$(DEB)/InRelease: $(DEB)/Release
	gpg --batch --clearsign --yes --output '$@' -- '$<'

pkg: $(DEB)/README.md
$(DEB)/README.md: ./README.md | $(DEB)
	cp -v -f -- '$<' '$@'

pkg: $(DEB)/.gitattributes
$(DEB)/.gitattributes: ./.gitattributes | $(DEB)
	cp -v -f -- '$<' '$@'
