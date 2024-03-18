PKGS :=
CA := ,

define META_2D
$(foreach line,$($1),$(eval $(call $2,$(firstword $(subst !, ,$(line))),$(word 2,$(subst !, ,$(line))),$(word 3,$(subst !, ,$(line))),$(word 4,$(subst !, ,$(line))))))
endef

define ARCHIVE_TEMPLATE
$(TMP)/$1_$2/$3: | $(VAR)/sh $(TMP)
	mkdir -v -p -- '$(TMP)/$1_$2'
	'$(VAR)/sh/layers/posix/home/.local/opt/initd/libexec/curl-unpack.sh' '$4' '$(TMP)/$1_$2'

$(TMP)/$1_$2_$3/DEBIAN/control: ./DEBIAN/control | /usr/bin/envsubst
	mkdir -v -p -- '$$(@D)'
	ARCH='$1' VERSION='$2' NAME='$(notdir $3)' envsubst <'$$<' >'$$@'

$(TMP)/$1_$2_$3/usr/local/bin/$(notdir $3): $(TMP)/$1_$2/$3
	mkdir -v -p -- '$$(@D)'
	install -v -- '$$<' '$$@'

PKGS += $(DEB)/$1_$2_$(notdir $3).deb
$(DEB)/$1_$2_$(notdir $3).deb: $(TMP)/$1_$2_$3/DEBIAN/control $(TMP)/$1_$2_$3/usr/local/bin/$(notdir $3) | $(DEB) /usr/bin/debsigs
	dpkg-deb --root-owner-group --build -- '$(TMP)/$1_$2_$3' '$$@'
	debsigs --sign=archive -- '$$@'
endef

define DEB_TEMPLATE
$(TMP)/$1_$2_$3.deb: | /usr/bin/debsigs
	$(CURL) --output '$$@' -- '$4'
	debsigs --sign=archive -- '$$@'

PKGS += $(DEB)/$1_$2_$3.deb
$(DEB)/$1_$2_$3.deb: $(TMP)/$1_$2_$3.deb | $(DEB)
	cp -v -f -- '$$<' '$$@'
endef


V_BTM     := $(shell $(GH_LATEST) ClementTsang/bottom)
V_DELTA   := $(shell $(GH_LATEST) dandavison/delta)
V_DIFFT   := $(shell $(GH_LATEST) Wilfred/difftastic)
V_DUST    := $(patsubst v%,%,$(shell $(GH_LATEST) bootandy/dust))
V_EZA     := $(patsubst v%,%,$(shell $(GH_LATEST) eza-community/eza))
V_FZF     := $(shell $(GH_LATEST) junegunn/fzf)
V_GITUI   := $(patsubst v%,%,$(shell $(GH_LATEST) extrawurst/gitui))
V_GOJQ    := $(shell $(GH_LATEST) itchyny/gojq)
V_HTMLQ   := $(patsubst v%,%,$(shell $(GH_LATEST) mgdm/htmlq))
V_JLESS   := $(patsubst v%,%,$(shell $(GH_LATEST) PaulJuliusMartinez/jless))
V_LAZYGIT := $(patsubst v%,%,$(shell $(GH_LATEST) jesseduffield/lazygit))
V_PASTEL  := $(patsubst v%,%,$(shell $(GH_LATEST) sharkdp/pastel))
V_POSH    := $(patsubst v%,%,$(shell $(GH_LATEST) JanDeDobbeleer/oh-my-posh))
V_S5CMD   := $(patsubst v%,%,$(shell $(GH_LATEST) peak/s5cmd))
V_SAD     := $(shell $(GH_LATEST) ms-jpq/sad)
V_TOKEI   := $(shell $(GH_LATEST) XAMPPRocky/tokei)
V_TV      := $(shell $(GH_LATEST) alexhallam/tv)
V_WATCHEX := $(patsubst v%,%,$(shell $(GH_LATEST) watchexec/watchexec))
V_XSV     := $(shell $(GH_LATEST) BurntSushi/xsv)

define CURL_ARCHIVES

$(V_DIFFT)   difft                                               https://github.com/Wilfred/difftastic/releases/latest/download/difft-#{HOSTTYPE}-unknown-linux-gnu.tar.gz           %
$(V_DUST)    dust-v#{VERSION}-#{HOSTTYPE}-unknown-linux-gnu/dust https://github.com/bootandy/dust/releases/latest/download/dust-v#{VERSION}-#{HOSTTYPE}-unknown-linux-gnu.tar.gz     %
$(V_EZA)     eza                                                 https://github.com/eza-community/eza/releases/latest/download/eza_#{HOSTTYPE}-unknown-linux-gnu.tar.gz              %
$(V_FZF)     fzf                                                 https://github.com/junegunn/fzf/releases/latest/download/fzf-#{VERSION}-linux_#{GOARCH}.tar.gz                      %
$(V_GITUI)   gitui                                               https://github.com/extrawurst/gitui/releases/latest/download/gitui-linux-#{HOSTTYPE}.tar.gz                         %x86_64=musl
$(V_HTMLQ)   htmlq                                               https://github.com/mgdm/htmlq/releases/latest/download/htmlq-#{HOSTTYPE}-linux.tar.gz                               %aarch64=!
$(V_JLESS)   jless                                               https://github.com/PaulJuliusMartinez/jless/releases/latest/download/jless-v#{VERSION}-x86_64-unknown-linux-gnu.zip %aarch64=!
$(V_LAZYGIT) lazygit                                             https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_#{VERSION}_Linux_#{HOSTTYPE}.tar.gz       %aarch64=arm64
$(V_POSH)    posh-linux-#{GOARCH}                                https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-#{GOARCH}                          %
$(V_XSV)     xsv                                                 https://github.com/BurntSushi/xsv/releases/latest/download/xsv-#{VERSION}-x86_64-unknown-linux-musl.tar.gz          %aarch64=!

endef

# $(V_TOKEI)   tokei                                               https://github.com/XAMPPRocky/tokei/releases/latest/download/tokei-#{HOSTTYPE}-unknown-linux-gnu.tar.gz             %

define CURL_DEBS

$(V_BTM)     btm            https://github.com/ClementTsang/bottom/releases/latest/download/bottom_#{VERSION}_#{GOARCH}.deb                        %
$(V_DELTA)   git-delta      https://github.com/dandavison/delta/releases/latest/download/git-delta_#{VERSION}_#{GOARCH}.deb                        %
$(V_PASTEL)  pastel         https://github.com/sharkdp/pastel/releases/latest/download/pastel_#{VERSION}_#{GOARCH}.deb                             %
$(V_S5CMD)   s5cmd          https://github.com/peak/s5cmd/releases/latest/download/s5cmd_#{VERSION}_linux_#{GOARCH}.deb                            %
$(V_SAD)     sad            https://github.com/ms-jpq/sad/releases/latest/download/#{HOSTTYPE}-unknown-linux-gnu.deb                               %
$(V_TV)      tidy-viewer    https://github.com/alexhallam/tv/releases/latest/download/tidy-viewer_#{VERSION}_#{GOARCH}.deb                         %aarch64=!
$(V_WATCHEX) watchexec      https://github.com/watchexec/watchexec/releases/latest/download/watchexec-#{VERSION}-#{HOSTTYPE}-unknown-linux-gnu.deb %
22.04        microsoft-list https://packages.microsoft.com/config/ubuntu/#{VERSION}/packages-microsoft-prod.deb                                    %

endef


CURL_ARCHIVES := $(shell ./libexec/arch-tee.sh <<<'$(CURL_ARCHIVES)')
CURL_DEBS := $(shell ./libexec/arch-tee.sh <<<'$(CURL_DEBS)')

$(DEB): | $(VAR)
	./libexec/s3.sh pull

$(call META_2D,CURL_ARCHIVES,ARCHIVE_TEMPLATE)
$(call META_2D,CURL_DEBS,DEB_TEMPLATE)
