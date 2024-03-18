.PHONY: lint shellcheck

lint: shellcheck
shellcheck:
	git ls-files --deduplicate -z -- '*.sh' | xargs -r -0 -- shellcheck --
