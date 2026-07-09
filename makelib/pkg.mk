.PHONY: pkg pubkey s3pkg

$(S3): | $(VAR)
	mkdir -v -p -- '$@'

$(TMP)/.promoted: $(PKGS) | $(TMP) $(S3)
	find -- '$(DEB)' -type f -name '*.deb' -size +99M -exec mv -v -f -- {} '$(S3)/' ';'
	touch -- '$@'

$(DEB)/Packages: $(TMP)/.promoted | /usr/bin/apt-ftparchive $(DEB)
	env --chdir '$(@D)' -- apt-ftparchive packages -- . | sed -E -e '/^Filename/s#: ./#: #' >'$@'

$(S3)/Packages: $(TMP)/.promoted | /usr/bin/apt-ftparchive $(S3)
	env --chdir '$(@D)' -- apt-ftparchive packages -- . | sed -E -e '/^Filename/s#: ./#: #' >'$@'

pkg: $(DEB)/Packages.gz
$(DEB)/Packages.gz: $(DEB)/Packages
	gzip --keep --no-name --force -- '$<'

s3pkg: $(S3)/Packages.gz
$(S3)/Packages.gz: $(S3)/Packages
	gzip --keep --no-name --force -- '$<'

$(DEB)/Release: $(DEB)/Packages.gz | /usr/bin/apt-ftparchive
	env --chdir '$(@D)' -- apt-ftparchive release . >'$@'

$(S3)/Release: $(S3)/Packages.gz | /usr/bin/apt-ftparchive
	env --chdir '$(@D)' -- apt-ftparchive release . >'$@'

pkg: $(DEB)/Release.gpg
$(DEB)/Release.gpg: $(DEB)/Release
	gpg --batch --sign --yes --output '$@' -- '$<'

pkg: $(S3)/Release.gpg
$(S3)/Release.gpg: $(S3)/Release
	gpg --batch --sign --yes --output '$@' -- '$<'

pkg: $(DEB)/InRelease
$(DEB)/InRelease: $(DEB)/Release
	gpg --batch --clearsign --yes --output '$@' -- '$<'

pkg: $(S3)/InRelease
s3pkg: $(S3)/InRelease
$(S3)/InRelease: $(S3)/Release
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
