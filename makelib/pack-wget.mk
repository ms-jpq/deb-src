.PHONY: aws aws-cli aws-sam

aws: aws-cli aws-sam

V_AWS_CLI := $(shell LATEST_TAG=1 $(GH_LATEST) aws/aws-cli)
V_AWS_SAM := $(shell $(GH_LATEST) aws/aws-sam-cli)
