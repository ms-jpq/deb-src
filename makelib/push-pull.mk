.PHONY: push pull s3

push pull: | $(VAR)
	./libexec/git-ops.sh '$@'

$(VENV)/bin/s3cmd: $(VENV)

s3: | $(S3) $(VENV)/bin/s3cmd
	./libexec/s3.sh
