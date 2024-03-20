define META_2D
$(foreach line,$($1),$(eval $(call $2,$(firstword $(subst !, ,$(line))),$(lastword $(subst !, ,$(line))))))
endef

.PHONY: pip
all: pip

define PIP_TEMPLATE
$(TMP)/all_py_$1/opt/python3/$1: | $(TMP) /usr/bin/pip
	PYTHONUSERBASE='$$@' python3 -m pip install --user -- $(patsubst %,'%',$(subst $(CA), ,$2))

$(TMP)/all_py_$1/DEBIAN/control: $(TMP)/all_py_$1/opt/python3/$1 ./DEBIAN/control | $(TMP) /usr/bin/envsubst
	V="$$$$(PYTHONUSERBASE='$$<' python3 -m pip freeze | grep -F -- '$1==' | cut -d '=' -f 3-)"
	mkdir -v -p -- '$$(@D)'
	ARCH='all' VERSION="$$$$V" NAME='py-$1' envsubst <'./DEBIAN/control' >'$$@'

$(TMP)/all_py_$1.deb: $(TMP)/all_py_$1/DEBIAN/control | /usr/bin/debsigs
	dpkg-deb --root-owner-group --build -- '$$(dir $$(<D))' '$$@'
	debsigs --sign=archive -- '$$@'

PKGS += $(DEB)/all_py_$1.deb
pip: $(DEB)/all_py_$1.deb
$(DEB)/all_py_$1.deb: $(TMP)/all_py_$1.deb | $(DEB)
	cp -v -f -- '$$<' '$$@'
endef


define PIP_PACKAGES
certbot       certbot
elasticsearch elasticsearch==8.*
gixy          gixy
endef

PIP_PACK := $(shell tr -s -- ' ' '!' <<<'$(PIP_PACKAGES)')

$(call META_2D,PIP_PACK,PIP_TEMPLATE)
