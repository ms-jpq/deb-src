.PHONY: push pull

push pull: | $(VAR)
	./libexec/s3.sh '$@'
