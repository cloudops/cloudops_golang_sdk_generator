.PHONY: all setup curl generate reset reset_spec

.ONESHELL:
.SHELLFLAGS = -ec

SHELL = /bin/bash

.DEFAULT_GOAL := all

include variables.env

DATE := $(shell date '+%Y-%m-%d-%H-%M-%S')

all: generate_all

setup:
	mkdir ./api_specs; \
	mkdir ./logs; \
	mkdir ./sdk_out

curl_all: curl_core curl_aws curl_azure curl_vcd curl_acs
generate_all: generate_core generate_aws generate_azure generate_vcd generate_acs

curl_core:
	curl -o ./api_specs/core_openapi.json $(ENDPOINT)/rest/docs/api/v3/openapi.json

curl_aws:
	curl -o ./api_specs/aws_openapi.json $(ENDPOINT)/rest/docs/aws/api/v3/openapi.json

curl_azure:
	curl -o ./api_specs/azure_openapi.json $(ENDPOINT)/rest/docs/azure/api/v3/openapi.json

curl_vcd:
	curl -o ./api_specs/vcd_openapi.json $(ENDPOINT)/rest/docs/vmware-cloud-director/api/v3/openapi.json

curl_acs:
	curl -o ./api_specs/acs_openapi.json $(ENDPOINT)/rest/docs/cloudstack/api/v3/openapi.json

generate_core:
	$(GENERATOR_PATH)openapi-generator generate --git-user-id $(GITHUB_HANDLE) --git-repo-id cmc_core --package-name cmc_core -i ./api_specs/core_openapi.json -g go -o ./sdk_out/cmc_core/ &> ./logs/core_output.log

generate_aws:
	$(GENERATOR_PATH)openapi-generator generate --git-user-id $(GITHUB_HANDLE) --git-repo-id cmc_aws --package-name cmc_aws -i ./api_specs/aws_openapi.json -g go -o ./sdk_out/cmc_aws/ &> ./logs/aws_output.log

generate_azure:
	$(GENERATOR_PATH)openapi-generator generate --git-user-id $(GITHUB_HANDLE) --git-repo-id cmc_azure --package-name cmc_azure -i ./api_specs/azure_openapi.json -g go -o ./sdk_out/cmc_azure/ &> ./logs/azure_output.log

generate_vcd:
	$(GENERATOR_PATH)openapi-generator generate --git-user-id $(GITHUB_HANDLE) --git-repo-id cmc_vcd --package-name cmc_vcd -i ./api_specs/vcd_openapi.json -g go -o ./sdk_out/cmc_vcd/ &> ./logs/vcd_output.log

generate_acs:
	$(GENERATOR_PATH)openapi-generator generate --git-user-id $(GITHUB_HANDLE) --git-repo-id cmc_acs --package-name cmc_acs -i ./api_specs/acs_openapi.json -g go -o ./sdk_out/cmc_acs/ &> ./logs/acs_output.log

backup:
	mv ./sdk_out ./sdk_out_$(DATE); \
	mv ./api_specs ./api_specs_$(DATE); \
	mkdir ./api_specs; \
	mkdir ./sdk_out

reset:
	rm -rf ./logs/*; \
	rm -rf ./sdk_out/*

reset_spec:
	rm -rf ./api_specs/*