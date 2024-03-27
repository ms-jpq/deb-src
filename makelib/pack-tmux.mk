.PHONY: tmux
APT += libevent-dev ncurses-dev build-essential bison pkg-config libutempter0 libutf8proc-dev autoconf autotools-dev

V_TMUX := $(shell $(GH_LATEST) tmux/tmux)

/usr/include/event.h: | $(TMP)/.init

$(TMP)/tmux-$(V_TMUX): | $(VAR)/sh $(TMP)
	'$(UNPACK)' 'https://github.com/tmux/tmux/releases/latest/download/tmux-$(V_TMUX).tar.gz' '$(@D)'

$(TMP)/$(DPKG_ARCH)_$(V_TMUX)_tmux/DEBIAN/control: ./DEBIAN/control | /usr/bin/envsubst
	mkdir -v -p -- '$(@D)'
	ARCH='$(DPKG_ARCH)' VERSION='$(V_TMUX)' NAME='tmux' envsubst <'$<' >'$@'

$(TMP)/$(DPKG_ARCH)_$(V_TMUX)_tmux/bin/tmux: $(TMP)/tmux-$(V_TMUX) | /usr/include/event.h
	env --chdir '$<' -- './configure' --prefix='$(abspath $(dir $(@D)))' --enable-static --enable-utf8proc --enable-sixel
	'$(MAKE)' --directory='$<'
	'$(MAKE)' --directory='$<' install

$(TMP)/$(DPKG_ARCH)_$(V_TMUX)_tmux.deb: $(TMP)/$(DPKG_ARCH)_$(V_TMUX)_tmux/bin/tmux $(TMP)/$(DPKG_ARCH)_$(V_TMUX)_tmux/DEBIAN/control | /usr/bin/debsigs
	dpkg-deb --root-owner-group --build -- '$(dir $(<D))' '$@'
	debsigs --sign=archive -- '$@'

tmux: $(DEB)/$(DPKG_ARCH)_$(V_TMUX)_tmux.deb
PKGS += $(DEB)/$(DPKG_ARCH)_$(V_TMUX)_tmux.deb
$(DEB)/$(DPKG_ARCH)_$(V_TMUX)_tmux.deb: $(TMP)/$(DPKG_ARCH)_$(V_TMUX)_tmux.deb | $(DEB)
	cp -v -f -- '$<' '$@'
