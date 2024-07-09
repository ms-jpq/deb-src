V2RAY_NAME := all_$(V_V2RAY)_v2ray-dat

$(TMP)/$(V2RAY_NAME)/opt/v2ray: $(TMP)/amd64_$(V_V2RAY)/v2ray | $(TMP)
	mkdir -v -p -- '$@'
	cp -v -f -- '$(<D)'/*.dat '$@'

$(TMP)/$(V2RAY_NAME)/DEBIAN/control: ./DEBIAN/control | /usr/bin/envsubst
	mkdir -v -p -- '$(@D)'
	ARCH='all' VERSION='$(V_V2RAY)' NAME='v2ray-dat' envsubst <'$<' >'$@'

$(TMP)/$(V2RAY_NAME).deb: $(TMP)/$(V2RAY_NAME)/opt/v2ray $(TMP)/$(V2RAY_NAME)/DEBIAN/control | /usr/bin/debsigs
	dpkg-deb --root-owner-group --build -- '$(dir $(<D))' '$@'
	debsigs --sign=archive -- '$@'

PKGS += $(DEB)/$(V2RAY_NAME).deb
$(DEB)/$(V2RAY_NAME).deb: $(TMP)/$(V2RAY_NAME).deb | $(DEB)
	cp -v -f -- '$<' '$@'
