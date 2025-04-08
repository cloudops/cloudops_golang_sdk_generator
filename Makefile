.PHONY: all setup curl generate reset reset_spec

.ONESHELL:
.SHELLFLAGS = -ec

SHELL = /bin/bash

.DEFAULT_GOAL := all

endpoint = https://portal.cloudmc.io
# endpoint = https://portal.dev.cloudmc.io

all: generate

setup:
	mkdir ./api_specs; \
	mkdir ./logs; \
	mkdir ./sdk_out

curl:
	curl -o ./api_specs/core_openapi.json $(endpoint)/rest/docs/api/v3/openapi.json; \
	curl -o ./api_specs/aws_openapi.json $(endpoint)/rest/docs/aws/api/v3/openapi.json; \
	curl -o ./api_specs/azure_openapi.json $(endpoint)/rest/docs/azure/api/v3/openapi.json; \
	curl -o ./api_specs/vcd_openapi.json $(endpoint)/rest/docs/vmware-cloud-director/api/v3/openapi.json

generate:
	/opt/homebrew/bin/openapi-generator generate --package-name cmc_core -i ./api_specs/core_openapi.json -g go -o ./sdk_out/cmc_core/ &> ./logs/core_output.log; \
	/opt/homebrew/bin/openapi-generator generate --package-name cmc_aws -i ./api_specs/aws_openapi.json -g go -o ./sdk_out/cmc_aws/ &> ./logs/aws_output.log; \
	/opt/homebrew/bin/openapi-generator generate --package-name cmc_azure -i ./api_specs/azure_openapi.json -g go -o ./sdk_out/cmc_azure/ &> ./logs/azure_output.log; \
	/opt/homebrew/bin/openapi-generator generate --package-name cmc_vcd -i ./api_specs/vcd_openapi.json -g go -o ./sdk_out/cmc_vcd/ &> ./logs/vcd_output.log

reset:
	rm -rf ./logs/*; \
	rm -rf ./sdk_out/*

reset_spec:
	rm -rf ./api_specs/*