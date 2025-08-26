.PHONY : all build run

.ONESHELL:
.SHELLFLAGS = -ec

SHELL = /bin/bash

.DEFAULT_GOAL := all

all: build

setup:
	pipreqs . --force

build:
	docker build --build-arg SCRIPT_NAME=go-inline-lifter.py . -t go-inline-lifter

run:
	docker run -e INPUT_FILE=file_name.json -e OUTPUT_FILE=second_name.json -v $(shell pwd):/data go-inline-lifter

