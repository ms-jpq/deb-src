.PHONY: s3pkg

$(S3): | $(VAR)
	mkdir -v -p -- '$@'

$(TMP)/.promoted: $(PKGS) | $(TMP) $(S3)
	find -- '$(DEB)' -type f -name '*.deb' -size +99M -exec mv -v -f -- {} '$(S3)/' ';'
	touch -- '$@'

$(S3)/Packages: $(TMP)/.promoted | /usr/bin/apt-ftparchive $(S3)
	env --chdir '$(@D)' -- apt-ftparchive packages -- . | sed -E -e '/^Filename/s#: ./#: #' >'$@'

$(S3)/Packages.gz: $(S3)/Packages
	gzip --keep --no-name --force -- '$<'

$(S3)/Release: $(S3)/Packages.gz | /usr/bin/apt-ftparchive
	env --chdir '$(@D)' -- apt-ftparchive release . >'$@'

pkg: $(S3)/Release.gpg
$(S3)/Release.gpg: $(S3)/Release
	gpg --batch --sign --yes --output '$@' -- '$<'

pkg: $(S3)/InRelease
s3pkg: $(S3)/InRelease
$(S3)/InRelease: $(S3)/Release
	gpg --batch --clearsign --yes --output '$@' -- '$<'
