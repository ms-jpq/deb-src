.PHONY: zpush

V_ZPUSH := $(shell $(GH_LATEST) Z-Hub/Z-Push)
ZPUSH_NAME := all_$(V_ZPUSH)_z-push

$(TMP)/$(ZPUSH_NAME)/usr/share/z-push: | $(VAR)/sh $(TMP)
	mkdir -v -p -- '$@'
	'$(UNPACK)' 'https://github.com/Z-Hub/Z-Push/archive/refs/tags/$(V_ZPUSH).tar.gz' '$@' --wildcards --strip-components 2 '*/src' '*/config'

$(TMP)/$(ZPUSH_NAME)/DEBIAN/control: ./DEBIAN/control | /usr/bin/envsubst
	mkdir -v -p -- '$(@D)'
	ARCH='all' VERSION='$(V_ZPUSH)' NAME='z-push' envsubst <'$<' >'$@'
	tee --append -- '$@' <<-'EOF'
	Depends: php, php-cli, php-soap, php-mbstring, php-imap
	EOF

$(TMP)/$(ZPUSH_NAME).deb: $(TMP)/$(ZPUSH_NAME)/usr/share/z-push $(TMP)/$(ZPUSH_NAME)/DEBIAN/control | /usr/bin/debsigs
	DIR='$(dir $(<D))'
	dpkg-deb --root-owner-group --build -- "$${DIR%/*/*}" '$@'
	debsigs --sign=archive -- '$@'

PKGS += $(DEB)/$(ZPUSH_NAME).deb
zpush: $(DEB)/$(ZPUSH_NAME).deb
$(DEB)/$(ZPUSH_NAME).deb: $(TMP)/$(ZPUSH_NAME).deb | $(DEB)
	cp -v -f -- '$<' '$@'
