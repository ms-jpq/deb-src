.PHONY: s3pkg ollama tabby

$(S3): | $(VAR)
	mkdir -v -p -- '$@'

V_OLLAMA := $(patsubst v%,%,$(shell $(GH_LATEST) ollama/ollama))
V_TABBY  := $(patsubst v%,%,$(shell $(GH_LATEST) TabbyML/tabby))

OLLAMA_URL := https://github.com/ollama/ollama/releases/latest/download/ollama-linux-amd64.tgz
TABBY_URL  := https://github.com/TabbyML/tabby/releases/latest/download/tabby_x86_64-manylinux_2_28-cuda123.tar.gz

OLLAMA_SHORT := amd64_$(V_OLLAMA)
TABBY_SHORT  := amd64_$(V_TABBY)
OLLAMA_LONG  := $(OLLAMA_SHORT)_ollama
TABBY_LONG   := $(TABBY_SHORT)_tabby

$(TMP)/$(OLLAMA_SHORT): | $(VAR)/sh $(TMP)
	mkdir -v -p -- '$@'
	'$(UNPACK)' '$(OLLAMA_URL)' '$@'

$(TMP)/$(TABBY_SHORT): | $(VAR)/sh $(TMP)
	mkdir -v -p -- '$@'
	'$(UNPACK)' '$(TABBY_URL)' '$@' --strip-components 1

$(TMP)/$(OLLAMA_LONG): $(TMP)/$(OLLAMA_SHORT) | /usr/bin/envsubst
	set -x
	mkdir -v -p -- '$@/DEBIAN'
	ARCH='$(DPKG_ARCH)' VERSION='$(V_OLLAMA)' NAME='ollama' envsubst <'./DEBIAN/control' >'$@/DEBIAN/control'
	cp -v -fr -- '$</'* '$@/'

$(TMP)/$(TABBY_LONG): $(TMP)/$(TABBY_SHORT) | /usr/bin/envsubst
	DST='$@/opt/tabby'
	mkdir -v -p -- '$@/DEBIAN' "$$DST"
	ARCH='$(DPKG_ARCH)' VERSION='$(V_TABBY)' NAME='tabby-ml' envsubst <'./DEBIAN/control' >'$@/DEBIAN/control'
	cp -v -fr -- '$</'* "$$DST/"

ollama: $(S3)/$(OLLAMA_LONG).deb
$(S3)/$(OLLAMA_LONG).deb: $(TMP)/$(OLLAMA_LONG) | /usr/bin/debsigs $(S3)
	dpkg-deb --root-owner-group --build -- '$<' '$@'
	debsigs --sign=archive -- '$@'

tabby:  $(S3)/$(TABBY_LONG).deb
$(S3)/$(TABBY_LONG).deb: $(TMP)/$(TABBY_LONG) | /usr/bin/debsigs $(S3)
	dpkg-deb --root-owner-group --build -- '$<' '$@'
	debsigs --sign=archive -- '$@'

S3_PKGS += $(S3)/$(OLLAMA_LONG).deb $(S3)/$(TABBY_LONG).deb

$(S3)/Packages: $(S3_PKGS) | /usr/bin/apt-ftparchive $(S3)
	env --chdir '$(@D)' -- apt-ftparchive packages -- . >'$@'

s3pkg: $(S3)/Packages.gz
$(S3)/Packages.gz: $(S3)/Packages
	gzip --keep --no-name --force -- '$<'
