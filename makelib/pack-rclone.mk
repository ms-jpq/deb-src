RCLONE_NAME := all_$(V_RCLONE)_rclone-mnt

$(TMP)/$(RCLONE_NAME)/sbin/mount.rclone: | $(TMP)
	mkdir -v -p -- '$(@D)'
	ln -v -s -- '/usr/bin/rclone' '$@'

$(TMP)/$(RCLONE_NAME)/DEBIAN/control: ./DEBIAN/control | /usr/bin/envsubst
	mkdir -v -p -- '$(@D)'
	ARCH='all' VERSION='$(V_RCLONE)' NAME='rclone-mnt' envsubst <'$<' >'$@'
	tee --append -- '$@' <<-'EOF'
	Depends: rclone
	EOF

$(TMP)/$(RCLONE_NAME).deb: $(TMP)/$(RCLONE_NAME)/sbin/mount.rclone $(TMP)/$(RCLONE_NAME)/DEBIAN/control | /usr/bin/debsigs
	dpkg-deb --root-owner-group --build -- '$(dir $(<D))' '$@'
	debsigs --sign=archive -- '$@'

PKGS += $(DEB)/$(RCLONE_NAME).deb
$(DEB)/$(RCLONE_NAME).deb: $(TMP)/$(RCLONE_NAME).deb | $(DEB)
	cp -v -f -- '$<' '$@'
