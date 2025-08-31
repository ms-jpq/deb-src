XRAY_NAME := all_$(V_XRAY)_xray-dat

$(TMP)/$(XRAY_NAME)/opt/xray: $(TMP)/amd64_$(V_XRAY)/xray | $(TMP)
	mkdir -v -p -- '$@'
	cp -v -f -- '$(<D)'/*.dat '$@'

$(TMP)/$(XRAY_NAME)/DEBIAN/control: ./DEBIAN/control | /usr/bin/envsubst
	mkdir -v -p -- '$(@D)'
	ARCH='all' VERSION='$(V_XRAY)' NAME='xray-dat' envsubst <'$<' >'$@'
	tee --append -- '$@' <<-'EOF'
	Depends: xray
	EOF

$(TMP)/$(XRAY_NAME).deb: $(TMP)/$(XRAY_NAME)/opt/xray $(TMP)/$(XRAY_NAME)/DEBIAN/control | /usr/bin/debsigs
	dpkg-deb --root-owner-group --build -- '$(dir $(<D))' '$@'
	debsigs --sign=archive -- '$@'

PKGS += $(DEB)/$(XRAY_NAME).deb
$(DEB)/$(XRAY_NAME).deb: $(TMP)/$(XRAY_NAME).deb | $(DEB)
	cp -v -f -- '$<' '$@'
