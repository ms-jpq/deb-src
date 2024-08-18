.PHONY: librespeed

V_LIBRESPEED := $(shell $(GH_LATEST) librespeed/speedtest)
LIBRESPEED_NAME := all_$(V_LIBRESPEED)_librespeed

$(TMP)/$(LIBRESPEED_NAME)/usr/share/librespeed: | $(VAR)/sh $(TMP)
	mkdir -v -p -- '$@'
	'$(UNPACK)' 'https://github.com/librespeed/speedtest/archive/refs/tags/$(V_LIBRESPEED).tar.gz' '$@' --strip-components 1

$(TMP)/$(LIBRESPEED_NAME)/DEBIAN/control: ./DEBIAN/control | /usr/bin/envsubst
	mkdir -v -p -- '$(@D)'
	ARCH='all' VERSION='$(V_LIBRESPEED)' NAME='librespeed' envsubst <'$<' >'$@'
	tee --append -- '$@' <<-'EOF'
	Depends: php
	EOF

$(TMP)/$(LIBRESPEED_NAME).deb: $(TMP)/$(LIBRESPEED_NAME)/usr/share/librespeed $(TMP)/$(LIBRESPEED_NAME)/DEBIAN/control | /usr/bin/debsigs
	DIR='$(dir $(<D))'
	dpkg-deb --root-owner-group --build -- "$${DIR%/*/*}" '$@'
	debsigs --sign=archive -- '$@'

PKGS += $(DEB)/$(LIBRESPEED_NAME).deb
librespeed: $(DEB)/$(LIBRESPEED_NAME).deb
$(DEB)/$(LIBRESPEED_NAME).deb: $(TMP)/$(LIBRESPEED_NAME).deb | $(DEB)
	cp -v -f -- '$<' '$@'
