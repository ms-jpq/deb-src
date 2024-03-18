.PHONY: pkg pubkey

$(DEB)/Packages: $(PKGS) | /usr/bin/apt-ftparchive $(DEB)
	env --chdir '$(@D)' -- apt-ftparchive packages -- . >'$@'

pkg: $(DEB)/Packages.gz
$(DEB)/Packages.gz: $(DEB)/Packages
	gzip --keep --no-name --force -- '$<'

$(DEB)/Release: $(DEB)/Packages | /usr/bin/apt-ftparchive $(DEB)
	env --chdir '$(@D)' -- apt-ftparchive release . >'$@'

pkg: $(DEB)/Release.gpg
$(DEB)/Release.gpg: $(DEB)/Release
	gpg --batch --sign --yes --output '$@' -- '$<'

pkg: $(DEB)/InRelease
$(DEB)/InRelease: $(DEB)/Release
	gpg --batch --clearsign --yes --output '$@' -- '$<'

pkg: $(DEB)/README.md
$(DEB)/README.md: ./README.md | $(DEB)
	cp -v -f -- '$<' '$@'

pkg: $(DEB)/.gitattributes
$(DEB)/.gitattributes: ./.gitattributes | $(DEB)
	cp -v -f -- '$<' '$@'

pubkey pkg: $(DEB)/pubkey.asc
$(DEB)/pubkey.asc: | $(DEB)
	$(CURL) --output '$@' -- 'https://github.com/ms-jpq.gpg'
