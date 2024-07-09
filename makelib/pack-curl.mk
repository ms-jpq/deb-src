CA := ,
.PHONY: curl

define META_5D
$(foreach line,$($1),$(eval $(call $2,$(firstword $(subst !, ,$(line))),$(word 2,$(subst !, ,$(line))),$(firstword $(subst :, ,$(word 3,$(subst !, ,$(line))))),$(word 4,$(subst !, ,$(line))),$(notdir $(lastword $(subst :, ,$(word 3,$(subst !, ,$(line)))))))))
endef

define ARCHIVE_TEMPLATE
$(TMP)/$1_$2_$5/DEBIAN/control: ./DEBIAN/control | $(TMP) /usr/bin/envsubst
	mkdir -v -p -- '$$(@D)'
	ARCH='$1' VERSION='$2' NAME='$5' envsubst <'$$<' >'$$@'

$(TMP)/$1_$2/$3: | $(VAR)/sh $(TMP)
	mkdir -v -p -- '$(TMP)/$1_$2'
	'$(UNPACK)' '$4' '$(TMP)/$1_$2'

$(TMP)/$1_$2_$5/usr/bin/$5: $(TMP)/$1_$2/$3
	mkdir -v -p -- '$$(@D)'
	install -v -- '$$<' '$$@'

$(TMP)/$1_$2_$5.deb: $(TMP)/$1_$2_$5/DEBIAN/control $(TMP)/$1_$2_$5/usr/bin/$5 | $(DEB) /usr/bin/debsigs
	dpkg-deb --root-owner-group --build -- '$(TMP)/$1_$2_$5' '$$@'
	debsigs --sign=archive -- '$$@'

curl: $(DEB)/$1_$2_$5.deb
PKGS += $(DEB)/$1_$2_$5.deb
$(DEB)/$1_$2_$5.deb: $(TMP)/$1_$2_$5.deb
	cp -v -f -- '$$<' '$$@'
endef

define DEB_TEMPLATE
$(TMP)/$1_$2_$3.deb: | $(TMP) /usr/bin/debsigs
	$(CURL) --output '$$@' -- '$4'
	debsigs --sign=archive -- '$$@'

curl: $(DEB)/$1_$2_$3.deb
PKGS += $(DEB)/$1_$2_$3.deb
$(DEB)/$1_$2_$3.deb: $(TMP)/$1_$2_$3.deb | $(DEB)
	cp -v -f -- '$$<' '$$@'
endef


V_BTM        := $(shell $(GH_LATEST) ClementTsang/bottom)
V_DELTA      := $(shell $(GH_LATEST) dandavison/delta)
V_DIFFT      := $(shell $(GH_LATEST) Wilfred/difftastic)
V_DUST       := $(patsubst v%,%,$(shell $(GH_LATEST) bootandy/dust))
V_EZA        := $(patsubst v%,%,$(shell $(GH_LATEST) eza-community/eza))
V_FZF        := $(patsubst v%,%,$(shell $(GH_LATEST) junegunn/fzf))
V_GAY        := 6.9
V_GH         := $(patsubst v%,%,$(shell $(GH_LATEST) cli/cli))
V_GITUI      := $(patsubst v%,%,$(shell $(GH_LATEST) extrawurst/gitui))
V_GOJQ       := $(shell $(GH_LATEST) itchyny/gojq)
V_GORELEASER := $(patsubst v%,%,$(shell $(GH_LATEST) goreleaser/goreleaser))
V_HTMLQ      := $(patsubst v%,%,$(shell $(GH_LATEST) mgdm/htmlq))
V_JLESS      := $(patsubst v%,%,$(shell $(GH_LATEST) PaulJuliusMartinez/jless))
V_JNV        := $(patsubst v%,%,$(shell $(GH_LATEST) ynqa/jnv))
V_LAZYGIT    := $(patsubst v%,%,$(shell $(GH_LATEST) jesseduffield/lazygit))
V_PASTEL     := $(patsubst v%,%,$(shell $(GH_LATEST) sharkdp/pastel))
V_POSH       := $(patsubst v%,%,$(shell $(GH_LATEST) JanDeDobbeleer/oh-my-posh))
V_RCLONE     := $(patsubst v%,%,$(shell $(GH_LATEST) rclone/rclone))
V_S3PROXY    := $(patsubst s3proxy-%,%,$(shell $(GH_LATEST) gaul/s3proxy))
V_S5CMD      := $(patsubst v%,%,$(shell $(GH_LATEST) peak/s5cmd))
V_SAD        := $(patsubst v%,%,$(shell $(GH_LATEST) ms-jpq/sad))
V_SPOTIFYD   := $(patsubst v%,%,$(shell $(GH_LATEST) Spotifyd/spotifyd))
V_TOKEI      := $(shell $(GH_LATEST) XAMPPRocky/tokei)
V_TV         := $(shell $(GH_LATEST) alexhallam/tv)
V_V2RAY      := $(patsubst v%,%,$(shell $(GH_LATEST) v2fly/v2ray-core))
V_WATCHEX    := $(patsubst v%,%,$(shell $(GH_LATEST) watchexec/watchexec))
V_XSV        := $(shell $(GH_LATEST) BurntSushi/xsv)
V_YT_DLP     := $(shell $(GH_LATEST) yt-dlp/yt-dlp)


define CURL_ARCHIVES

$(V_DIFFT)    difft                                               https://github.com/Wilfred/difftastic/releases/latest/download/difft-#{HOSTTYPE}-unknown-linux-gnu.tar.gz           %
$(V_DUST)     dust-v#{VERSION}-#{HOSTTYPE}-unknown-linux-gnu/dust https://github.com/bootandy/dust/releases/latest/download/dust-v#{VERSION}-#{HOSTTYPE}-unknown-linux-gnu.tar.gz     %
$(V_EZA)      eza                                                 https://github.com/eza-community/eza/releases/latest/download/eza_#{HOSTTYPE}-unknown-linux-gnu.tar.gz              %
$(V_FZF)      fzf                                                 https://github.com/junegunn/fzf/releases/latest/download/fzf-#{VERSION}-linux_#{GOARCH}.tar.gz                      %
$(V_GAY)      gay                                                 https://raw.githubusercontent.com/ms-jpq/gay/%3C3/gay                                                               %aarch64=all,x86_64=all
$(V_GITUI)    gitui                                               https://github.com/extrawurst/gitui/releases/latest/download/gitui-linux-#{HOSTTYPE}.tar.gz                         %
$(V_HTMLQ)    htmlq                                               https://github.com/mgdm/htmlq/releases/latest/download/htmlq-#{HOSTTYPE}-linux.tar.gz                               %aarch64=!
$(V_JLESS)    jless                                               https://github.com/PaulJuliusMartinez/jless/releases/latest/download/jless-v#{VERSION}-x86_64-unknown-linux-gnu.zip %aarch64=!
$(V_JNV)      jnv-x86_64-unknown-linux-gnu/jnv                    https://github.com/ynqa/jnv/releases/latest/download/jnv-x86_64-unknown-linux-gnu.tar.xz                            %aarch64=!
$(V_LAZYGIT)  lazygit                                             https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_#{VERSION}_Linux_#{HOSTTYPE}.tar.gz       %aarch64=arm64
$(V_POSH)     posh-linux-#{GOARCH}:oh-my-posh                     https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-#{GOARCH}                          %
$(V_S3PROXY)  s3proxy                                             https://github.com/gaul/s3proxy/releases/latest/download/s3proxy                                                    %aarch64=all,x86_64=all
$(V_SPOTIFYD) spotifyd                                            https://github.com/Spotifyd/spotifyd/releases/latest/download/spotifyd-linux-full.tar.gz                            %aarch64=!
$(V_V2RAY)    v2ray                                               https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-#{HOSTTYPE}.zip                            %aarch64=arm64-v8a,x86_64=64
$(V_XSV)      xsv                                                 https://github.com/BurntSushi/xsv/releases/latest/download/xsv-#{VERSION}-x86_64-unknown-linux-musl.tar.gz          %aarch64=!
$(V_YT_DLP)   yt-dlp_linux${HOSTTYPE}:yt-dlp                      https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux${HOSTTYPE}                                   %aarch64=_aarch64,x86_64=

endef

# $(V_TOKEI)   tokei                                               https://github.com/XAMPPRocky/tokei/releases/latest/download/tokei-#{HOSTTYPE}-unknown-linux-gnu.tar.gz             %

define CURL_DEBS

$(V_BTM)        btm                     https://github.com/ClementTsang/bottom/releases/latest/download/bottom_#{VERSION}_#{GOARCH}.deb                        %
$(V_DELTA)      git-delta               https://github.com/dandavison/delta/releases/latest/download/git-delta_#{VERSION}_#{GOARCH}.deb                        %
$(V_GH)         gh                      https://github.com/cli/cli/releases/download/v#{VERSION}/gh_#{VERSION}_linux_#{GOARCH}.deb                             %
$(V_GORELEASER) goreleaser              https://github.com/goreleaser/goreleaser/releases/latest/download/goreleaser_#{VERSION}_#{GOARCH}.deb                  %
$(V_PASTEL)     pastel                  https://github.com/sharkdp/pastel/releases/latest/download/pastel_#{VERSION}_#{GOARCH}.deb                             %
$(V_RCLONE)     rclone                  https://github.com/rclone/rclone/releases/latest/download/rclone-v#{VERSION}-linux-#{GOARCH}.deb                       %
$(V_S5CMD)      s5cmd                   https://github.com/peak/s5cmd/releases/latest/download/s5cmd_#{VERSION}_linux_#{GOARCH}.deb                            %
$(V_SAD)        sad                     https://github.com/ms-jpq/sad/releases/latest/download/#{HOSTTYPE}-unknown-linux-gnu.deb                               %
$(V_TV)         tidy-viewer             https://github.com/alexhallam/tv/releases/latest/download/tidy-viewer_#{VERSION}_#{GOARCH}.deb                         %aarch64=!
$(V_WATCHEX)    watchexec               https://github.com/watchexec/watchexec/releases/latest/download/watchexec-#{VERSION}-#{HOSTTYPE}-unknown-linux-gnu.deb %
22.04           packages-microsoft-prod https://packages.microsoft.com/config/ubuntu/#{VERSION}/packages-microsoft-prod.deb                                    %aarch64=all,x86_64=all

endef


CURL_ARCHIVES := $(shell ./libexec/arch-tee.sh <<<'$(CURL_ARCHIVES)')
CURL_DEBS := $(shell ./libexec/arch-tee.sh <<<'$(CURL_DEBS)')

$(DEB): | $(VAR)
	./libexec/s3.sh pull

$(call META_5D,CURL_ARCHIVES,ARCHIVE_TEMPLATE)
$(call META_5D,CURL_DEBS,DEB_TEMPLATE)
