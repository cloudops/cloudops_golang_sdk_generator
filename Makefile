.PHONY: all setup curl generate curl_core curl_aws curl_azure curl_vcd curl_acs \
        generate_core generate_aws generate_azure generate_vcd generate_acs \
        backup reset reset_spec

.ONESHELL:
.SHELLFLAGS = -ec

SHELL = /bin/bash

.DEFAULT_GOAL := all

include variables.env
CONFIG_FILE := ./go-generator-config.json

DATE := $(shell date '+%Y-%m-%d-%H-%M-%S')

all: generate

setup:
	mkdir ./api_specs; \
	mkdir ./logs; \
	mkdir ./sdk_out

curl: curl_core curl_aws curl_azure curl_vcd curl_acs
generate: generate_core generate_aws generate_azure generate_vcd generate_acs

# --- helper functions ---
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

# --- fetch specs ---
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

# --- generate SDKs ---
inline-lifter = docker run \
  -e INPUT_FILE=$(1)_openapi.json \
  -e OUTPUT_FILE=$(1)_openapi_lifted.json \
  -v $(shell pwd)/api_specs:/data \
  go-inline-lifter \
  &> ./logs/$(1)_inline-lifter.log

generate_core:
	$(call inline-lifter,core)
	$(GENERATOR_PATH)openapi-generator generate \
	  -g go \
	  -i ./api_specs/core_openapi_lifted.json \
	  -o ./sdk_out/cmc_core/ \
	  -c $(CONFIG_FILE) \
	  --git-user-id $(GITHUB_HANDLE) \
	  --git-repo-id cmc_core \
	  --additional-properties=packageName=cmc_core,goModName=github.com/$(GITHUB_HANDLE)/cmc_core \
	  --skip-validate-spec \
	  --type-mappings '*/*=interface{}' \
	  --import-mappings '*/*=encoding/json' \
	&> ./logs/core_output.log

generate_aws:
	$(call inline-lifter,aws)
	$(GENERATOR_PATH)openapi-generator generate \
	  -g go \
	  -i ./api_specs/aws_openapi_lifted.json \
	  -o ./sdk_out/cmc_aws/ \
	  -c $(CONFIG_FILE) \
	  --git-user-id $(GITHUB_HANDLE) \
	  --git-repo-id cmc_aws \
	  --additional-properties=packageName=cmc_aws,goModName=github.com/$(GITHUB_HANDLE)/cmc_aws \
	  --skip-validate-spec \
	  --type-mappings '*/*=interface{}' \
	  --import-mappings '*/*=encoding/json' \
	&> ./logs/aws_output.log

generate_azure:
	$(call inline-lifter,azure)
	$(GENERATOR_PATH)openapi-generator generate \
	  -g go \
	  -i ./api_specs/azure_openapi_lifted.json \
	  -o ./sdk_out/cmc_azure/ \
	  -c $(CONFIG_FILE) \
	  --git-user-id $(GITHUB_HANDLE) \
	  --git-repo-id cmc_azure \
	  --additional-properties=packageName=cmc_azure,goModName=github.com/$(GITHUB_HANDLE)/cmc_azure \
	  --skip-validate-spec \
	  --type-mappings '*/*=interface{}' \
	  --import-mappings '*/*=encoding/json' \
	&> ./logs/azure_output.log

generate_vcd:
	$(call inline-lifter,vcd)
	$(GENERATOR_PATH)openapi-generator generate \
	  -g go \
	  -i ./api_specs/vcd_openapi_lifted.json \
	  -o ./sdk_out/cmc_vcd/ \
	  -c $(CONFIG_FILE) \
	  --git-user-id $(GITHUB_HANDLE) \
	  --git-repo-id cmc_vcd \
	  --additional-properties=packageName=cmc_vcd,goModName=github.com/$(GITHUB_HANDLE)/cmc_vcd \
	  --skip-validate-spec \
	  --type-mappings '*/*=interface{}' \
	  --import-mappings '*/*=encoding/json' \
	&> ./logs/vcd_output.log

generate_acs:
	$(call inline-lifter,acs)
	$(GENERATOR_PATH)openapi-generator generate \
	  -g go \
	  -i ./api_specs/acs_openapi_lifted.json \
	  -o ./sdk_out/cmc_acs/ \
	  -c $(CONFIG_FILE) \
	  --git-user-id $(GITHUB_HANDLE) \
	  --git-repo-id cmc_acs \
	  --additional-properties=packageName=cmc_acs,goModName=github.com/$(GITHUB_HANDLE)/cmc_acs \
	  --skip-validate-spec \
	  --type-mappings '*/*=interface{}' \
	  --import-mappings '*/*=encoding/json' \
	&> ./logs/acs_output.log
