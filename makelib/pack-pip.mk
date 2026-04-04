.PHONY: pip
all: pip

ifeq ($(origin CI), environment)
PYTHON3 := /usr/bin/python3
else
PYTHON3 := python3
endif

define PIP_TEMPLATE
$(TMP)/py_$1_all/opt/python3/$1: | $(TMP) /usr/bin/pip
	$(PYTHON3) -m pip install --target '$$@' -- $(patsubst %,'%',$(subst $(CA), ,$2))

$(TMP)/py_$1_all/DEBIAN/control: $(TMP)/py_$1_all/opt/python3/$1 ./DEBIAN/control | $(TMP) /usr/bin/envsubst
	V="$$$$(PYTHONPATH='$$<' $(PYTHON3) -m pip freeze | grep -F -- '$1==' | cut -d '=' -f 3-)"
	mkdir -v -p -- '$$(@D)'
	ARCH='all' VERSION="$$$$V" NAME='py-$1' envsubst <'./DEBIAN/control' >'$$@'

$(TMP)/py_$1_all.deb: $(TMP)/py_$1_all/DEBIAN/control | /usr/bin/debsigs
	dpkg-deb --root-owner-group --build -- '$$(dir $$(<D))' '$$@'
	debsigs --sign=archive -- '$$@'

PKGS += $(DEB)/py_$1_all.deb
pip: $(DEB)/py_$1_all.deb
$(DEB)/py_$1_all.deb: $(TMP)/py_$1_all.deb | $(DEB)
	cp -v -f -- '$$<' '$$@'
endef


define PIP_PACKAGES
certbot       certbot
elasticsearch elasticsearch==8.*
gixy          gixy
you-get       you-get
endef

PIP_PACK := $(shell tr -s -- ' ' '!' <<<'$(PIP_PACKAGES)')

$(call META_2D,PIP_PACK,PIP_TEMPLATE)
