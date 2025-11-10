.PHONY: tmux
APT += libevent-dev ncurses-dev build-essential bison pkg-config libutempter0 libutf8proc-dev autoconf autotools-dev

V_TMUX := $(shell $(GH_LATEST) tmux/tmux)

/usr/include/event.h: | $(TMP)/.init

$(TMP)/tmux-$(V_TMUX): | $(VAR)/sh $(TMP)
	'$(UNPACK)' 'https://github.com/tmux/tmux/releases/latest/download/tmux-$(V_TMUX).tar.gz' '$(@D)'

$(TMP)/tmux_$(DPKG_ARCH)_$(V_TMUX)/DEBIAN/control: ./DEBIAN/control | /usr/bin/envsubst
	mkdir -v -p -- '$(@D)'
	ARCH='$(DPKG_ARCH)' VERSION='$(V_TMUX)' NAME='tmux' envsubst <'$<' >'$@'

$(TMP)/tmux_$(DPKG_ARCH)_$(V_TMUX)/bin/tmux: $(TMP)/tmux-$(V_TMUX) | /usr/include/event.h
	env --chdir '$<' -- './configure' --prefix='$(abspath $(dir $(@D)))' --enable-static --enable-utf8proc --enable-sixel
	'$(MAKE)' --directory='$<'
	'$(MAKE)' --directory='$<' install
	touch -- '$@'

$(TMP)/tmux_$(DPKG_ARCH)_$(V_TMUX).deb: $(TMP)/tmux_$(DPKG_ARCH)_$(V_TMUX)/bin/tmux $(TMP)/tmux_$(DPKG_ARCH)_$(V_TMUX)/DEBIAN/control | /usr/bin/debsigs
	dpkg-deb --root-owner-group --build -- '$(dir $(<D))' '$@'
	debsigs --sign=archive -- '$@'

tmux: $(DEB)/tmux_$(DPKG_ARCH)_$(V_TMUX).deb
PKGS += $(DEB)/tmux_$(DPKG_ARCH)_$(V_TMUX).deb
$(DEB)/tmux_$(DPKG_ARCH)_$(V_TMUX).deb: $(TMP)/tmux_$(DPKG_ARCH)_$(V_TMUX).deb | $(DEB)
	cp -v -f -- '$<' '$@'
