GH_LATEST := ./libexec/gh-latest.sh $(TMP)
CURL := curl --fail-with-body --location --no-progress-meter

/usr/bin/debsigs /usr/bin/apt-ftparchive /usr/bin/dpkg-scanpackages:
	sudo -- apt-get update
	sudo -- env -- DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --yes -- apt-utils debsigs
