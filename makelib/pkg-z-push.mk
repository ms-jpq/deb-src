.PHONY: zpush

V_ZPUSH := $(shell $(GH_LATEST) Z-Hub/Z-Push)
Z_PUSH_ROOT := $(TMP)/$(V_ZPUSH)_zpush

$(Z_PUSH_ROOT)/opt/z-push: | $(VAR)/sh $(TMP)
	mkdir -v -p -- '$@'
	'$(UNPACK)' 'https://github.com/Z-Hub/Z-Push/archive/refs/tags/$(V_ZPUSH).tar.gz' '$@' --wildcards --strip-components 2 '*/src'

$(Z_PUSH_ROOT)/DEBIAN/control: ./DEBIAN/control | /usr/bin/envsubst
	mkdir -v -p -- '$(@D)'
	ARCH='all' VERSION='$(V_ZPUSH)' NAME='z-push' envsubst <'$<' >'$@'
	tee --append -- '$@' <<-'EOF'
	Depends: php, php-cli, php-soap, php-mbstring, php-imap
	EOF

$(TMP)/all_$(V_ZPUSH)_zpush.deb: $(Z_PUSH_ROOT)/opt/z-push $(Z_PUSH_ROOT)/DEBIAN/control | /usr/bin/debsigs
	dpkg-deb --root-owner-group --build -- '$(dir $(<D))' '$@'
	debsigs --sign=archive -- '$@'

PKGS += $(DEB)/all_$(V_ZPUSH)_zpush.deb
zpush: $(DEB)/all_$(V_ZPUSH)_zpush.deb
$(DEB)/all_$(V_ZPUSH)_zpush.deb: $(TMP)/all_$(V_ZPUSH)_zpush.deb | $(DEB)
	cp -v -f -- '$<' '$@'
