.PHONY: llama
all: llama

V_LLAMA := $(patsubst v%,%,$(shell $(GH_LATEST) ggml-org/llama.cpp))
T_LLAMA := $(shell $(CURL) -- 'https://github.com/ggml-org/llama.cpp/releases/download/v$(V_LLAMA)/nightly-tag.txt')

define LLAMA_TEMPLATE
$(TMP)/llama.cpp_$1_$(V_LLAMA)/DEBIAN/control: ./DEBIAN/control makelib/pack-llama.mk | $(TMP) /usr/bin/envsubst
	mkdir -v -p -- '$$(@D)' '$(TMP)/llama.cpp_$1_$(V_LLAMA)/opt/llama.cpp'
	$(CURL) -- 'https://github.com/ggml-org/llama.cpp/releases/download/$(T_LLAMA)/llama-$(T_LLAMA)-bin-ubuntu-$2.tar.gz' | tar --extract --gzip --file - --directory '$(TMP)/llama.cpp_$1_$(V_LLAMA)/opt/llama.cpp' --strip-components 1

	ARCH='$1' VERSION='$(V_LLAMA)' NAME='llama.cpp' envsubst <'$$<' >'$$@'
	tee --append -- '$$@' <<-'EOF'
	Depends: libc6, libgcc-s1, libgomp1, libssl3, libstdc++6
	EOF

$(TMP)/llama.cpp_$1_$(V_LLAMA).deb: $(TMP)/llama.cpp_$1_$(V_LLAMA)/DEBIAN/control | /usr/bin/debsigs
	dpkg-deb --root-owner-group --build -- '$(TMP)/llama.cpp_$1_$(V_LLAMA)' '$$@'
	debsigs --sign=archive -- '$$@'

PKGS += $(DEB)/llama.cpp_$1_$(V_LLAMA).deb
llama: $(DEB)/llama.cpp_$1_$(V_LLAMA).deb
$(DEB)/llama.cpp_$1_$(V_LLAMA).deb: $(TMP)/llama.cpp_$1_$(V_LLAMA).deb | $(DEB)
	cp -v -f -- '$$<' '$$@'
endef

$(eval $(call LLAMA_TEMPLATE,amd64,x64))
$(eval $(call LLAMA_TEMPLATE,arm64,arm64))
