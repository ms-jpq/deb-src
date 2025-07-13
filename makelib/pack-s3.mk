.PHONY: ollama tabby

S3 := $(VAR)/s3

$(S3): | $(VAR)
	mkdir -v -p -- '$@'

V_OLLAMA := $(patsubst v%,%,$(shell $(GH_LATEST) ollama/ollama))
V_TABBY  := $(patsubst v%,%,$(shell $(GH_LATEST) TabbyML/tabby))

OLLAMA_URL := https://github.com/ollama/ollama/releases/latest/download/ollama-linux-amd64.tgz
TABBY_URL  := https://github.com/TabbyML/tabby/releases/latest/download/tabby_x86_64-manylinux_2_28-cuda123.tar.gz

OLLAMA_SHORT := amd64_$(V_OLLAMA)
TABBY_SHORT  := amd64_$(V_TABBY)
OLLAMA_LONG  := all_$(V_OLLAMA)_ollama
TABBY_LONG   := all_$(V_TABBY)_tabby

$(TMP)/$(OLLAMA_SHORT): | $(VAR)/sh $(TMP)
	'$(UNPACK)' '$(OLLAMA_URL)' '$@'

$(TMP)/$(TABBY_SHORT): | $(VAR)/sh $(TMP)
	'$(UNPACK)' '$(TABBY_URL)' '$@' --strip-components 1

ollama: $(TMP)/$(OLLAMA_NAME)
