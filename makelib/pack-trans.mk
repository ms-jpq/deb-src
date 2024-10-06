.PHONY: trans
APT += automake libtool intltool libcurl4-openssl-dev libglib2.0-dev libminiupnpc-dev libssl-dev libsystemd-dev

V_TRANS := $(shell $(GH_LATEST) transmission/transmission)

$(TMP)/transmission-$(V_TRANS): | $(VAR)/sh $(TMP)
	'$(UNPACK)' 'https://github.com/transmission/transmission/releases/latest/download/transmission-$(V_TRANS).tar.xz' '$(@D)'

$(TMP)/$(DPKG_ARCH)_$(V_TRANS)_transmission/DEBIAN/control: ./DEBIAN/control | /usr/bin/envsubst
	mkdir -v -p -- '$(@D)'
	ARCH='$(DPKG_ARCH)' VERSION='$(V_TRANS)' NAME='transmission-$(VERSION_ID)' envsubst <'$<' >'$@'
	tee --append -- '$@' <<-'EOF'
	Depends: libevent-2.1-7t64 libminiupnpc17 libnatpmp1t64
	EOF

$(TMP)/$(DPKG_ARCH)_$(V_TRANS)_transmission/usr/bin: $(TMP)/transmission-$(V_TRANS) | /usr/include/event.h
	env --chdir '$<' -- cmake -B build -DCMAKE_BUILD_TYPE=Release -DENABLE_QT=OFF -DENABLE_GTK=OFF -DWITH_SYSTEMD=ON -DWITH_INOTIFY=ON -DPACKAGE_DATA_DIR=/usr/share
	env --chdir '$</build' -- cmake --build .
	env --chdir '$</build' -- cmake --install . --prefix='$(abspath $(@D))'

$(TMP)/$(DPKG_ARCH)_$(V_TRANS)_transmission.deb: $(TMP)/$(DPKG_ARCH)_$(V_TRANS)_transmission/usr/bin $(TMP)/$(DPKG_ARCH)_$(V_TRANS)_transmission/DEBIAN/control | /usr/bin/debsigs
	dpkg-deb --root-owner-group --build -- '$(dir $(<D))' '$@'
	debsigs --sign=archive -- '$@'

trans: $(DEB)/$(DPKG_ARCH)_$(V_TRANS)_transmission.deb
PKGS += $(DEB)/$(DPKG_ARCH)_$(V_TRANS)_transmission-$(VERSION_ID).deb
$(DEB)/$(DPKG_ARCH)_$(V_TRANS)_transmission-$(VERSION_ID).deb: $(TMP)/$(DPKG_ARCH)_$(V_TRANS)_transmission.deb | $(DEB)
	cp -v -f -- '$<' '$@'
