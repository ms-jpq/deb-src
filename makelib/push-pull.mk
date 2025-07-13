.PHONY: push pull s3

push pull: | $(VAR)
	./libexec/git-ops.sh '$@'

define PYDEPS
from itertools import chain
from os import execl
from sys import executable

from tomli import load

toml = load(open("pyproject.toml", "rb"))

project = toml["project"]
execl(
  executable,
  executable,
  "-m",
  "pip",
  "install",
  "--upgrade",
  "--",
  *project.get("dependencies", ()),
  *chain.from_iterable(project["optional-dependencies"].values()),
)
endef
export -- PYDEPS

./.venv/bin:
	python3 -m venv -- './.venv'
	'$@/python3' -m pip install --upgrade -- tomli
	'$@/python3' <<< '$(PYDEPS)'

./.venv/bin/s3cmd: ./.venv/bin

s3: ./.venv/bin/s3cmd
