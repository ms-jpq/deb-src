define OS_DETECT
case "$$OSTYPE" in
darwin*)
	printf -- '%s' darwin
	;;
linux*)
	printf -- '%s' linux
	;;
msys)
	printf -- '%s' nt
	;;
*)
	exit 1
	;;
esac
endef

HOSTTYPE := $(shell printf -- '%s' "$$HOSTTYPE")
OS := $(shell $(OS_DETECT))


ifeq ($(HOSTTYPE), aarch64)
GOARCH := arm64
else
GOARCH := amd64
endif

NPROC := $(shell nproc)

VERSION_ID := $(shell perl -CASD -wne '/^VERSION_ID="(.+)"$$/ && print $$1' </etc/os-release)
VERSION_CODENAME := $(shell perl -CASD -wne '/^VERSION_CODENAME=(.+)$$/ && print $$1' </etc/os-release)
