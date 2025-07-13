S3 := $(VAR)/s3

$(S3): | $(VAR)
	mkdir -v -p -- '$@'

