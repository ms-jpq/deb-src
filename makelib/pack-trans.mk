.PHONY: trans
APT += automake libtool intltool libcurl4-openssl-dev libglib2.0-dev libminiupnpc-dev libssl-dev libsystemd-dev

V_TRANS := $(shell $(GH_LATEST) transmission/transmission)

$(TMP)/transmission-$(V_TRANS): | $(VAR)/sh $(TMP)
	'$(UNPACK)' 'https://github.com/transmission/transmission/releases/latest/download/transmission-$(V_TRANS).tar.xz' '$(@D)'

$(TMP)/$(DPKG_ARCH)_$(V_TRANS)_transmission/DEBIAN/control: ./DEBIAN/control | /usr/bin/envsubst
	mkdir -v -p -- '$(@D)'
	ARCH='$(DPKG_ARCH)' VERSION='$(V_TRANS)' NAME='transmission' envsubst <'$<' >'$@'

$(TMP)/$(DPKG_ARCH)_$(V_TRANS)_transmission/bin: $(TMP)/transmission-$(V_TRANS) | /usr/include/event.h
	env --chdir '$<' -- cmake -B build -DCMAKE_BUILD_TYPE=Release -DENABLE_QT=OFF -DENABLE_GTK=OFF -DWITH_SYSTEMD=ON -DWITH_INOTIFY=ON
	env --chdir '$</build' -- cmake --build .
	env --chdir '$</build' -- cmake --install . --prefix='$(abspath $(@D))'

$(TMP)/$(DPKG_ARCH)_$(V_TRANS)_transmission.deb: $(TMP)/$(DPKG_ARCH)_$(V_TRANS)_transmission/bin $(TMP)/$(DPKG_ARCH)_$(V_TRANS)_transmission/DEBIAN/control | /usr/bin/debsigs
	dpkg-deb --root-owner-group --build -- '$(<D)' '$@'
	debsigs --sign=archive -- '$@'

trans: $(DEB)/$(DPKG_ARCH)_$(V_TRANS)_transmission.deb
PKGS += $(DEB)/$(DPKG_ARCH)_$(V_TRANS)_transmission.deb
$(DEB)/$(DPKG_ARCH)_$(V_TRANS)_transmission.deb: $(TMP)/$(DPKG_ARCH)_$(V_TRANS)_transmission.deb | $(DEB)
	cp -v -f -- '$<' '$@'
