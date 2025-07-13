S3 := $(VAR)/s3

$(S3): | $(VAR)
	mkdir -v -p -- '$@'

V_OLLAMA := $(patsubst v%,%,$(shell $(GH_LATEST) ollama/ollama))
V_TABBY  := $(patsubst v%,%,$(shell $(GH_LATEST) TabbyML/tabby))
