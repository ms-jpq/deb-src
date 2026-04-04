define META_2D
$(foreach line,$($1),$(eval $(call $2,$(firstword $(subst !, ,$(line))),$(lastword $(subst !, ,$(line))))))
endef

.PHONY: nvim
all: nvim

V_NVIM := $(patsubst v%,%,$(shell $(GH_LATEST) neovim/neovim))

define NVIM_TEMPLATE
$(TMP)/$1_nvim_$(V_NVIM): | $(TMP)
	mkdir -p -- '$$@'
	$(CURL) -- 'https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$2.tar.gz' | tar --extract -z --file - --directory '$$@' --strip-components 1

$(TMP)/$1_nvim_$(V_NVIM)/DEBIAN/control: $(TMP)/$1_nvim_$(V_NVIM) ./DEBIAN/control | $(TMP) /usr/bin/envsubst
	mkdir -v -p -- '$$(@D)'
	ARCH='all' VERSION="$(V_NVIM)" NAME='py-$1' envsubst <'./DEBIAN/control' >'$$@'

$(TMP)/nvim_$1_$(V_NVIM).deb: $(TMP)/$1_nvim_$(V_NVIM)/DEBIAN/control | /usr/bin/debsigs
	dpkg-deb --root-owner-group --build -- '$$(dir $$(<D))' '$$@'
	debsigs --sign=archive -- '$$@'

PKGS += $(DEB)/nvim_$1_$(V_NVIM).deb
nvim: $(DEB)/nvim_$1_$(V_NVIM).deb
$(DEB)/nvim_$1_$(V_NVIM).deb: $(TMP)/nvim_$1_$(V_NVIM).deb | $(DEB)
	cp -v -f -- '$$<' '$$@'
endef

define NVIM_ARCH
amd64 x86_64
arm64 arm64
endef

NVIM_AR := $(shell tr -s -- ' ' '!' <<<'$(NVIM_ARCH)')

$(call META_2D,NVIM_AR,NVIM_TEMPLATE)
