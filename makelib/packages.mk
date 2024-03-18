PKGS :=

V_BTM     := $(shell $(GH_LATEST) ClementTsang/bottom)
V_DELTA   := $(shell $(GH_LATEST) dandavison/delta)
V_DIFFT   := $(shell $(GH_LATEST) Wilfred/difftastic)
V_DUST    := $(shell $(GH_LATEST) bootandy/dust)
V_EZA     := $(shell $(GH_LATEST) eza-community/eza)
V_FZF     := $(shell $(GH_LATEST) junegunn/fzf)
V_GITUI   := $(shell $(GH_LATEST) extrawurst/gitui)
V_GOJQ    := $(shell $(GH_LATEST) itchyny/gojq)
V_JLESS   := $(shell $(GH_LATEST) PaulJuliusMartinez/jless)
V_LAZYGIT := $(patsubst v%,%,$(shell $(GH_LATEST) jesseduffield/lazygit))
V_PASTEL  := $(patsubst v%,%,$(shell $(GH_LATEST) sharkdp/pastel))
V_POSH		:= $(shell $(GH_LATEST) JanDeDobbeleer/oh-my-posh)
V_S5CMD   := $(patsubst v%,%,$(shell $(GH_LATEST) peak/s5cmd))
V_TV      := $(shell $(GH_LATEST) alexhallam/tv)
V_WATCHEX := $(patsubst v%,%,$(shell $(GH_LATEST) watchexec/watchexec))
V_XSV     := $(shell $(GH_LATEST) BurntSushi/xsv)

# 1            htmlq                                              https://github.com/mgdm/htmlq/releases/latest/download/htmlq-x86_64-linux.tar.gz                                   %aarch64=!
# 1            jless                                              https://github.com/PaulJuliusMartinez/jless/releases/latest/download/jless-#{VERSION}-x86_64-unknown-linux-gnu.zip %aarch64=!
# tokei                                             https://github.com/XAMPPRocky/tokei/releases/latest/download/tokei-#{HOSTTYPE}-unknown-linux-gnu.tar.gz

define CURL_ARCHIVES

$(V_DIFFT)   difft                                              https://github.com/Wilfred/difftastic/releases/latest/download/difft-#{HOSTTYPE}-unknown-linux-gnu.tar.gz          %
$(V_DUST)    dust-#{VERSION}-#{HOSTTYPE}-unknown-linux-gnu/dust https://github.com/bootandy/dust/releases/latest/download/dust-#{VERSION}-#{HOSTTYPE}-unknown-linux-gnu.tar.gz     %
$(V_EZA)     eza                                                https://github.com/eza-community/eza/releases/latest/download/eza_#{HOSTTYPE}-unknown-linux-gnu.tar.gz             %
$(V_FZF)     fzf                                                https://github.com/junegunn/fzf/releases/latest/download/fzf-#{VERSION}-linux_#{GOARCH}.tar.gz                     %
$(V_GITUI)   gitui                                              https://github.com/extrawurst/gitui/releases/latest/download/gitui-linux-#{HOSTTYPE}.tar.gz                        %amd64=musl
$(V_LAZYGIT) lazygit                                            https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_#{VERSION}_Linux_#{LAZY_TYPE}.tar.gz     %
$(V_POSH)    posh-linux-#{GOARCH}                               https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-#{GOARCH}                         %
$(V_XSV)     xsv                                                https://github.com/BurntSushi/xsv/releases/latest/download/xsv-#{VERSION}-x86_64-unknown-linux-musl.tar.gz         %aarch64=!

endef


define CURL_DEBS

$(V_BTM)     https://github.com/ClementTsang/bottom/releases/latest/download/bottom_#{VERSION}_#{GOARCH}.deb                        %
$(V_DELTA)   https://github.com/dandavison/delta/releases/latest/download/git-delta_#{VERSION}_#{GOARCH}.deb                        %
$(V_PASTEL)  https://github.com/sharkdp/pastel/releases/latest/download/pastel_#{VERSION}_#{GOARCH}.deb                             %
$(V_S5CMD)   https://github.com/peak/s5cmd/releases/latest/download/s5cmd_#{VERSION}_linux_#{GOARCH}.deb                            %
$(V_SAD)     https://github.com/ms-jpq/sad/releases/latest/download/#{HOSTTYPE}-unknown-linux-gnu.deb                               %
$(V_TV)      https://github.com/alexhallam/tv/releases/latest/download/tidy-viewer_#{VERSION}_#{GOARCH}.deb                         %aarch64=!
$(V_WATCHEX) https://github.com/watchexec/watchexec/releases/latest/download/watchexec-#{VERSION}-#{HOSTTYPE}-unknown-linux-gnu.deb %
1.0          https://packages.microsoft.com/config/ubuntu/jammy/packages-microsoft-prod.deb                                         %

endef


CURL_ARCHIVES := $(shell awk 'NF { print $$1 " " $$2 "!" $$3 " " $$4 }' <<<'$(CURL_ARCHIVES)' | ./libexec/arch-tee.sh)
CURL_DEBS := $(shell ./libexec/arch-tee.sh <<<'$(CURL_DEBS)')
# $(call META_2D,CURL_ARCHIVES,ARCHIVE_TEMPLATE)
# $(call META_2D,CURL_DEBS,DEB_TEMPLATE)
