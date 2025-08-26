# CloudOps SDK Generation

The included `Makefile` is a convenience tool for generating the CloudOps Software Golang SDKs via the OpenAPI specification. It also integrates an **inline schema lifter** to fix compatibility issues with Go SDK generation.

## Initial Setup

First, install the `openapi-generator`. For this `Makefile` to work, you will need to install it with Homebrew:

```bash
brew install openapi-generator
```

Next, set up the variables and folder structure:

```bash
cp variables.env.sample variables.env
make setup
```

> Make sure to configure the variables in `variables.env` to match your environment.

This will create the following folders:

* `./api_specs` → stores downloaded OpenAPI specs
* `./logs` → stores generation logs
* `./sdk_out` → stores generated SDKs

## The Inline Schema Lifter

Many OpenAPI specs contain **inline schemas** that cause problems with Golang SDK generation (invalid names, regex errors, or missing references). To solve this, we use the **inline lifter** script before passing the specs into `openapi-generator`.

### How it Works

1. The lifter takes an input spec (JSON/YAML) and traverses it.
2. Inline schemas are **lifted** into `#/components/schemas` with auto-generated, sanitized names.
3. Invalid schema names are cleaned to meet Go’s naming restrictions.
4. Content wrapper issues are fixed so that `application/json` blocks always contain proper `schema` references.
5. The transformed spec is saved with the suffix `_openapi_lifted.json`.

This ensures that the final specs are compatible with Golang SDK generation.

### Example

```bash
make generate_core
```

This will:

* Download the `core_openapi.json` spec
* Run the **inline lifter** to produce `core_openapi_lifted.json`
* Generate the `cmc_core` SDK into `./sdk_out/cmc_core`

Logs will be available in `./logs/core_output.log`.

### Go Generator Config (`go-generator-config.json`)

This file contains additional configuration passed to the **OpenAPI Generator** when producing the Go SDKs.
It controls aspects of code layout, naming conventions, and how models and APIs are organized.

Current settings:

```json
{
  "enumClassPrefix": true,
  "withSeparateModelsAndApi": true,
  "modelPackage": "models",
  "apiPackage": "apis",
  "generateInterfaces": true
}
```

#### Explanation of fields:

* **`enumClassPrefix`**: Ensures that generated enums are prefixed with their class name, reducing naming conflicts.
* **`withSeparateModelsAndApi`**: Places models and API clients in separate packages for cleaner project organization.
* **`modelPackage`**: Directory/package name where generated models are placed (`models`).
* **`apiPackage`**: Directory/package name where generated API clients are placed (`apis`).
* **`generateInterfaces`**: Generates interfaces for the APIs, which makes mocking and testing easier in Go.

#### How it’s used

Each `generate_*` target in the **Makefile** passes the config file using:

```bash
-c ./go-generator-config.json
```

This means that all generated SDKs (core, aws, azure, vcd, acs) will follow the same structure and conventions defined here.
If you need different configurations for different SDKs, you can create multiple config files and adjust the Makefile accordingly.

## Generating the SDK

To fetch all specs:

```bash
make curl
```

To generate all SDKs:

```bash
make generate
```

> You can also target specific clouds:
>
> * `make generate_core`
> * `make generate_aws`
> * `make generate_azure`
> * `make generate_vcd`
> * `make generate_acs`

The SDKs will be available in `./sdk_out/<cloud>` and the logs in `./logs`.

## Backup Folders

Before regenerating specs/SDKs, you may want to back up your current environment:

```bash
make backup
```

This moves `./api_specs` and `./sdk_out` into timestamped backup directories.

## Reset Folders

To clean up logs and SDKs:

```bash
make reset
```

To clean up the API specs:

```bash
make reset_spec
```

> **Warning:** These commands delete data. Use `make backup` if you need a rollback point.

## Using the SDK

Since the SDK is not yet tracked as an official release, you must reference it manually in your Go project.

For example, to use the `cmc_core` SDK locally:

In your `go.mod` file:

```go
require (
    github.com/cloudops/cmc_core v0.0.0
)

replace github.com/cloudops/cmc_core => /path/to/sdk_out/cmc_core
```

This establishes the import path (`github.com/cloudops/cmc_core`) and redirects it to your local build.

To use a different GitHub handle, update the `GITHUB_HANDLE` in `variables.env` accordingly.
