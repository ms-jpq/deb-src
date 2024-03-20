.PHONY: zpush

V_ZPUSH := $(shell $(GH_LATEST) Z-Hub/Z-Push)
Z_PUSH_NAME := all_$(V_ZPUSH)_z-push

$(TMP)/$(Z_PUSH_NAME)/usr/share/z-push: | $(VAR)/sh $(TMP)
	mkdir -v -p -- '$@'
	'$(UNPACK)' 'https://github.com/Z-Hub/Z-Push/archive/refs/tags/$(V_ZPUSH).tar.gz' '$@' --wildcards --strip-components 2 '*/src' '*/config'

$(TMP)/$(Z_PUSH_NAME)/DEBIAN/control: ./DEBIAN/control | /usr/bin/envsubst
	mkdir -v -p -- '$(@D)'
	ARCH='all' VERSION='$(V_ZPUSH)' NAME='z-push' envsubst <'$<' >'$@'
	tee --append -- '$@' <<-'EOF'
	Depends: php, php-cli, php-soap, php-mbstring, php-imap, php-fpm
	EOF

$(TMP)/$(Z_PUSH_NAME).deb: $(TMP)/$(Z_PUSH_NAME)/usr/share/z-push $(TMP)/$(Z_PUSH_NAME)/DEBIAN/control | /usr/bin/debsigs
	dpkg-deb --root-owner-group --build -- '$(dir $(<D))' '$@'
	debsigs --sign=archive -- '$@'

PKGS += $(DEB)/$(Z_PUSH_NAME).deb
zpush: $(DEB)/$(Z_PUSH_NAME).deb
$(DEB)/$(Z_PUSH_NAME).deb: $(TMP)/$(Z_PUSH_NAME).deb | $(DEB)
	cp -v -f -- '$<' '$@'
