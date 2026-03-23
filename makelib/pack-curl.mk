CA := ,
.PHONY: curl

define META_5D
$(foreach line,$($1),$(eval $(call $2,$(firstword $(subst !, ,$(line))),$(word 2,$(subst !, ,$(line))),$(firstword $(subst :, ,$(word 3,$(subst !, ,$(line))))),$(word 4,$(subst !, ,$(line))),$(word 5,$(subst !, ,$(line))),$(notdir $(lastword $(subst :, ,$(word 3,$(subst !, ,$(line)))))))))
endef

define ARCHIVE_TEMPLATE
$(TMP)/$6_$1_$2/DEBIAN/control: ./DEBIAN/control | $(TMP) /usr/bin/envsubst
	mkdir -v -p -- '$$(@D)'
	ARCH='$1' VERSION='$2' NAME='$6' envsubst <'$$<' >'$$@'

$(TMP)/$1_$6_$2/$3: | $(VAR)/sh $(TMP)
	mkdir -v -p -- '$(TMP)/$1_$6_$2'
	'$(UNPACK)' '$4' '$(TMP)/$1_$6_$2'

ifeq ($5,*)
vv_$6 := $(TMP)/$6_$1_$2/usr/bin/$6
$$(vv_$6): $(TMP)/$1_$6_$2/$3
	mkdir -v -p -- '$$(@D)'
	if [[ -d 'overlay/$6' ]]; then
	  cp -v -r --no-dereference -- 'overlay/$6'/* '$(TMP)/$6_$1_$2'
	fi
	install -v -- '$$<' '$$@'
else
vv_$6 := $(TMP)/$6_$1_$2/$5
$$(vv_$6): $(TMP)/$1_$6_$2/$3
	mkdir -v -p -- '$$(@D)'
	cp -v -r --no-dereference -- '$$<' '$$@'
endif

$(TMP)/$6_$1_$2.deb: $(TMP)/$6_$1_$2/DEBIAN/control $$(vv_$6) | $(DEB) /usr/bin/debsigs
	dpkg-deb --root-owner-group --build -- '$(TMP)/$6_$1_$2' '$$@'
	debsigs --sign=archive -- '$$@'

curl: $(DEB)/$6_$1_$2.deb
PKGS += $(DEB)/$6_$1_$2.deb
$(DEB)/$6_$1_$2.deb: $(TMP)/$6_$1_$2.deb
	cp -v -f -- '$$<' '$$@'
endef

define DEB_TEMPLATE
$(TMP)/$3_$1_$2.deb: | $(TMP) /usr/bin/debsigs
	$(CURL) --output '$$@' -- '$4'
	debsigs --sign=archive -- '$$@'

curl: $(DEB)/$3_$1_$2.deb
PKGS += $(DEB)/$3_$1_$2.deb
$(DEB)/$3_$1_$2.deb: $(TMP)/$3_$1_$2.deb | $(DEB)
	cp -v -f -- '$$<' '$$@'
endef

V_DATE       := $(shell date -- '+%Y.W%V')
CLOUD_IMG_AT := https://cloud-images.ubuntu.com/releases/$(VERSION_ID)/release/unpacked
IMG_PREFIX   := ubuntu-$(VERSION_ID)-server-cloudimg-

V_AD_HOME    := $(patsubst v%,%,$(shell $(GH_LATEST) AdguardTeam/AdGuardHome))
V_ASDF       := $(patsubst v%,%,$(shell $(GH_LATEST) asdf-vm/asdf))
V_BTM        := $(shell $(GH_LATEST) ClementTsang/bottom)
V_CTAGS      := $(subst /,,$(dir $(subst +,/,$(shell $(GH_LATEST) universal-ctags/ctags-nightly-build))))
V_DELTA      := $(shell $(GH_LATEST) dandavison/delta)
V_DIFF_NAV   := $(patsubst v%,%,$(shell $(GH_LATEST) dlvhdr/diffnav))
V_DIFFT      := $(shell $(GH_LATEST) Wilfred/difftastic)
V_DUST       := $(patsubst v%,%,$(shell $(GH_LATEST) bootandy/dust))
V_EZA        := $(patsubst v%,%,$(shell $(GH_LATEST) eza-community/eza))
V_FZF        := $(patsubst v%,%,$(shell $(GH_LATEST) junegunn/fzf))
V_GH         := $(patsubst v%,%,$(shell $(GH_LATEST) cli/cli))
V_GITUI      := $(patsubst v%,%,$(shell $(GH_LATEST) extrawurst/gitui))
V_GOJQ       := $(shell $(GH_LATEST) itchyny/gojq)
V_GORELEASER := $(patsubst v%,%,$(shell $(GH_LATEST) goreleaser/goreleaser))
V_HELIX      := $(shell $(GH_LATEST) helix-editor/helix)
V_HTMLQ      := $(patsubst v%,%,$(shell $(GH_LATEST) mgdm/htmlq))
V_JAEGER     := $(shell $(CURL) -- 'https://api.github.com/repos/jaegertracing/jaeger/releases/latest' | jq --exit-status --raw-output '.name' | sed -E -e 's#.*([0-9]+\.[0-9]+\.[0-9]+)$$#\1#')
V_JLESS      := $(patsubst v%,%,$(shell $(GH_LATEST) PaulJuliusMartinez/jless))
V_JNV        := $(patsubst v%,%,$(shell $(GH_LATEST) ynqa/jnv))
V_K3S        := $(patsubst v%,%,$(shell $(GH_LATEST) k3s-io/k3s))
V_K8S        := $(patsubst v%,%,$(shell $(GH_LATEST) kubernetes/kubernetes))
V_K9S        := $(patsubst v%,%,$(shell $(GH_LATEST) derailed/k9s))
V_KATANA     := $(patsubst v%,%,$(shell $(GH_LATEST) projectdiscovery/katana))
V_LAZYGIT    := $(patsubst v%,%,$(shell $(GH_LATEST) jesseduffield/lazygit))
V_LF         := $(patsubst r%,%,$(shell $(GH_LATEST) gokcehan/lf))
V_OTEL_COLL  := $(patsubst v%,%,$(shell $(GH_LATEST) open-telemetry/opentelemetry-collector-releases))
V_PASTEL     := $(patsubst v%,%,$(shell $(GH_LATEST) sharkdp/pastel))
V_POSH       := $(patsubst v%,%,$(shell $(GH_LATEST) JanDeDobbeleer/oh-my-posh))
V_PTERM      := $(patsubst v%,%,$(shell $(GH_LATEST) mfontanini/presenterm))
V_RCLONE     := $(patsubst v%,%,$(shell $(GH_LATEST) rclone/rclone))
V_REGI       := $(patsubst v%,%,$(shell $(GH_LATEST) distribution/distribution))
V_S3PROXY    := $(patsubst s3proxy-%,%,$(shell $(GH_LATEST) gaul/s3proxy))
V_S5CMD      := $(patsubst v%,%,$(shell $(GH_LATEST) peak/s5cmd))
V_SAD        := $(patsubst v%,%,$(shell $(GH_LATEST) ms-jpq/sad))
V_SMART_DNS  := $(patsubst Release%,%,$(shell $(GH_LATEST) pymumu/smartdns))
V_SPOTIFYD   := $(patsubst v%,%,$(shell $(GH_LATEST) Spotifyd/spotifyd))
V_TOKEI      := $(shell $(GH_LATEST) XAMPPRocky/tokei)
V_TV         := $(shell $(GH_LATEST) alexhallam/tv)
V_WATCHEX    := $(patsubst v%,%,$(shell $(GH_LATEST) watchexec/watchexec))
V_XRAY       := $(patsubst v%,%,$(shell $(GH_LATEST) XTLS/Xray-core))
V_XSV        := $(shell $(GH_LATEST) BurntSushi/xsv)
V_YAZI       := $(patsubst v%,%,$(shell $(GH_LATEST) sxyazi/yazi))
V_YQ         := $(patsubst v%,%,$(shell $(GH_LATEST) mikefarah/yq))
V_YT_DLP     := $(shell $(GH_LATEST) yt-dlp/yt-dlp)
V_ZELLIJ     := $(patsubst v%,%,$(shell $(GH_LATEST) zellij-org/zellij))

# V_JAEGER     := $(patsubst v%,%,$(shell $(GH_LATEST) jaegertracing/jaeger))
V_TV         := 1.5.2
V_HELIX_DEB  := $(subst .0,.,$(V_HELIX))-1

V_TOKEI := 12.1.2

define CURL_ARCHIVES

$(V_AD_HOME)   AdGuardHome/AdGuardHome                             *                                     https://github.com/AdguardTeam/AdGuardHome/releases/latest/download/AdGuardHome_linux_#{GOARCH}.tar.gz                       %
$(V_ASDF)      asdf                                                *                                     https://github.com/asdf-vm/asdf/releases/latest/download/asdf-v#{VERSION}-linux-#{GOARCH}.tar.gz                             %
$(V_DATE)      $(IMG_PREFIX)#{GOARCH}-initrd-generic               opt/img/initrd-generic-$(VERSION_ID)  $(CLOUD_IMG_AT)/$(IMG_PREFIX)#{GOARCH}-initrd-generic                                                                        %
$(V_DATE)      $(IMG_PREFIX)#{GOARCH}-vmlinuz-generic              opt/img/vmlinuz-generic-$(VERSION_ID) $(CLOUD_IMG_AT)/$(IMG_PREFIX)#{GOARCH}-vmlinuz-generic                                                                       %
$(V_DATE)      gay                                                 *                                     https://raw.githubusercontent.com/ms-jpq/gay/%3C3/gay                                                                        %aarch64=all,x86_64=all
$(V_DIFF_NAV)  diffnav                                             *                                     https://github.com/dlvhdr/diffnav/releases/latest/download/diffnav_Linux_#{HOSTTYPE}.tar.gz                                  %aarch64=arm64
$(V_DIFFT)     difft                                               *                                     https://github.com/Wilfred/difftastic/releases/latest/download/difft-#{HOSTTYPE}-unknown-linux-gnu.tar.gz                    %
$(V_DUST)      dust-v#{VERSION}-#{HOSTTYPE}-unknown-linux-gnu/dust *                                     https://github.com/bootandy/dust/releases/latest/download/dust-v#{VERSION}-#{HOSTTYPE}-unknown-linux-gnu.tar.gz              %
$(V_EZA)       eza                                                 *                                     https://github.com/eza-community/eza/releases/latest/download/eza_#{HOSTTYPE}-unknown-linux-gnu.tar.gz                       %
$(V_FZF)       fzf                                                 *                                     https://github.com/junegunn/fzf/releases/latest/download/fzf-#{VERSION}-linux_#{GOARCH}.tar.gz                               %
$(V_GITUI)     gitui                                               *                                     https://github.com/extrawurst/gitui/releases/latest/download/gitui-linux-#{HOSTTYPE}.tar.gz                                  %
$(V_HTMLQ)     htmlq                                               *                                     https://github.com/mgdm/htmlq/releases/latest/download/htmlq-#{HOSTTYPE}-linux.tar.gz                                        %aarch64=!
$(V_JAEGER)    jaeger-#{VERSION}-linux-#{GOARCH}/jaeger            *                                     https://github.com/jaegertracing/jaeger/releases/latest/download/jaeger-#{VERSION}-linux-#{GOARCH}.tar.gz                    %
$(V_JLESS)     jless                                               *                                     https://github.com/PaulJuliusMartinez/jless/releases/latest/download/jless-v#{VERSION}-x86_64-unknown-linux-gnu.zip          %aarch64=!
$(V_JNV)       jnv-x86_64-unknown-linux-gnu/jnv                    *                                     https://github.com/ynqa/jnv/releases/latest/download/jnv-x86_64-unknown-linux-gnu.tar.xz                                     %aarch64=!
$(V_K3S)       #{HOSTTYPE}:k3s                                     *                                     https://github.com/k3s-io/k3s/releases/latest/download/#{HOSTTYPE}                                                           %aarch64=k3s-arm64,x86_64=k3s
$(V_K8S)       kubectl                                             *                                     https://dl.k8s.io/release/v#{VERSION}/bin/linux/#{GOARCH}/kubectl                                                            %
$(V_KATANA)    katana                                              *                                     https://github.com/projectdiscovery/katana/releases/latest/download/katana_#{VERSION}_linux_#{GOARCH}.zip                    %
$(V_LAZYGIT)   lazygit                                             *                                     https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_#{VERSION}_Linux_#{HOSTTYPE}.tar.gz                %aarch64=arm64
$(V_LF)        lf                                                  *                                     https://github.com/gokcehan/lf/releases/latest/download/lf-linux-#{GOARCH}.tar.gz                                            %
$(V_POSH)      posh-linux-#{GOARCH}:oh-my-posh                     *                                     https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-#{GOARCH}                                   %
$(V_PTERM)     presenterm-#{VERSION}/presenterm                    *                                     https://github.com/mfontanini/presenterm/releases/latest/download/presenterm-#{VERSION}-#{HOSTTYPE}-unknown-linux-gnu.tar.gz %
$(V_RCLONE)    rclone-v#{VERSION}-linux-#{GOARCH}/rclone           *                                     https://github.com/rclone/rclone/releases/latest/download/rclone-v#{VERSION}-linux-#{GOARCH}.zip                             %
$(V_REGI)      registry                                            *                                     https://github.com/distribution/distribution/releases/latest/download/registry_#{VERSION}_linux_#{GOARCH}.tar.gz             %
$(V_SMART_DNS) smartdns-#{HOSTTYPE}:smartdns                       *                                     https://github.com/pymumu/smartdns/releases/latest/download/smartdns-#{HOSTTYPE}                                             %
$(V_SPOTIFYD)  spotifyd                                            *                                     https://github.com/Spotifyd/spotifyd/releases/latest/download/spotifyd-linux-#{HOSTTYPE}-full.tar.gz                         %
$(V_TOKEI)     tokei                                               *                                     https://github.com/XAMPPRocky/tokei/releases/download/v#{VERSION}/tokei-#{HOSTTYPE}-unknown-linux-gnu.tar.gz                 %
$(V_ZELLIJ)    zellij                                              *                                     https://github.com/zellij-org/zellij/releases/download/v#{VERSION}/zellij-#{HOSTTYPE}-unknown-linux-musl.tar.gz              %
$(V_XRAY)      xray                                                *                                     https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-#{HOSTTYPE}.zip                                        %aarch64=arm64-v8a,x86_64=64
$(V_XSV)       xsv                                                 *                                     https://github.com/BurntSushi/xsv/releases/latest/download/xsv-#{VERSION}-x86_64-unknown-linux-musl.tar.gz                   %aarch64=!
$(V_YAZI)      yazi-#{HOSTTYPE}-unknown-linux-gnu/yazi             *                                     https://github.com/sxyazi/yazi/releases/latest/download/yazi-#{HOSTTYPE}-unknown-linux-gnu.zip                               %
$(V_YQ)        yq_linux_#{GOARCH}:yq                               *                                     https://github.com/mikefarah/yq/releases/latest/download/yq_linux_#{GOARCH}.tar.gz                                           %
$(V_YT_DLP)    yt-dlp_linux${HOSTTYPE}:yt-dlp                      *                                     https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux${HOSTTYPE}                                            %aarch64=_aarch64,x86_64=

endef

# $(V_S3PROXY)   s3proxy                                             *                                     https://github.com/gaul/s3proxy/releases/latest/download/s3proxy                                                             %aarch64=all,x86_64=all

define CURL_DEBS

$(V_BTM)        btm                     *  https://github.com/ClementTsang/bottom/releases/latest/download/bottom_#{VERSION}-1_#{GOARCH}.deb                                               %
$(V_CTAGS)      uctags                  *  https://github.com/universal-ctags/ctags-nightly-build/releases/latest/download/uctags-#{VERSION}-linux-#{HOSTTYPE}.deb                         %
$(V_DATE)       packages-microsoft-prod *  https://packages.microsoft.com/config/ubuntu/$(VERSION_ID)/packages-microsoft-prod.deb                                                          %aarch64=all,x86_64=all
$(V_DELTA)      git-delta               *  https://github.com/dandavison/delta/releases/latest/download/git-delta_#{VERSION}_#{GOARCH}.deb                                                 %
$(V_GH)         gh                      *  https://github.com/cli/cli/releases/download/v#{VERSION}/gh_#{VERSION}_linux_#{GOARCH}.deb                                                      %
$(V_GORELEASER) goreleaser              *  https://github.com/goreleaser/goreleaser/releases/latest/download/goreleaser_#{VERSION}_#{GOARCH}.deb                                           %
$(V_HELIX)      helix                   *  https://github.com/helix-editor/helix/releases/latest/download/helix_$(V_HELIX_DEB)_#{GOARCH}.deb                                               %aarch64=!
$(V_K9S)        k9s                     *  https://github.com/derailed/k9s/releases/latest/download/k9s_linux_#{GOARCH}.deb                                                                %
$(V_OTEL_COLL)  otelcol-contrib         *  https://github.com/open-telemetry/opentelemetry-collector-releases/releases/latest/download/otelcol-contrib_#{VERSION}_linux_#{GOARCH}.deb      %
$(V_PASTEL)     pastel                  *  https://github.com/sharkdp/pastel/releases/latest/download/pastel_#{VERSION}_#{GOARCH}.deb                                                      %
$(V_S5CMD)      s5cmd                   *  https://github.com/peak/s5cmd/releases/latest/download/s5cmd_#{VERSION}_linux_#{GOARCH}.deb                                                     %
$(V_SAD)        sad                     *  https://github.com/ms-jpq/sad/releases/latest/download/#{HOSTTYPE}-unknown-linux-gnu.deb                                                        %
$(V_TV)         tidy-viewer             *  https://github.com/alexhallam/tv/releases/download/#{VERSION}/tidy-viewer_#{VERSION}_#{GOARCH}.deb                                              %aarch64=!
$(V_WATCHEX)    watchexec               *  https://github.com/watchexec/watchexec/releases/latest/download/watchexec-#{VERSION}-#{HOSTTYPE}-unknown-linux-gnu.deb                          %

endef


CURL_ARCHIVES := $(shell ./libexec/arch-tee.sh <<<'$(CURL_ARCHIVES)')
CURL_DEBS := $(shell ./libexec/arch-tee.sh <<<'$(CURL_DEBS)')

$(DEB): | $(VAR)
	./libexec/git-ops.sh pull

$(call META_5D,CURL_ARCHIVES,ARCHIVE_TEMPLATE)
$(call META_5D,CURL_DEBS,DEB_TEMPLATE)
