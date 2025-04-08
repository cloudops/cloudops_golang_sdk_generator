CloudMC SDK Generation
----------------------

The included `Makefile` is a convenience function for generating the CloudMC Golang SDK via the OpenAPI specification.

## Initial Setup

First, you need to install the `openapi-generator`.  In order for this `Makefile` to work, you will need to install it with Homebrew.

```bash
$ brew install openapi-generator
```

Now that the `openapi-generator` is installed, you need to setup the folder structure.

```bash
$ make setup
```

> The folders `./api_specs`, `./logs`, and `./sdk_out` will be created.

## Generating the SDK

In order to generate the SDK, you need to pull down the spec files.

```bash
$ make curl
```

> The folder `./api_specs` will be populated with spec files.

Now that you have the spec files, you need to generate the SDK output from the spec files.

```bash
$ make
```

> The folder `./sdk_out` will be populated with SDKs and the `./logs` folder will have the corresponding logs.

## Reset & Regenerate

You may choose to pull down newer specs or regenerate the SDK, before you do that you will want to clean up the existing directories.

To cleanup the `./logs` and `./sdk_out` folders.

```bash
$ make reset
```

To cleanup the `./api_spec` folder.

```bash
$ make reset_spec
```

At this point, you can now run the `make curl` and `make` commands again as documented above.

## Using the SDK

The SDK is not tracked as an official release (yet), so you will need to reference the SDK manually in your code.

You will need to establish both a package location as well as the path reference to it (assuming you don't track the SDK in github publicly).

In this case, I will only reference the `cmc_core` package and I will reference it as `github.com/swill/cmc_core`.

In your `go.mod` file, add the following reference:

```
require (
	github.com/swill/cmc_core v0.0.0
)

replace github.com/swill/cmc_core => /path/to/sdk_out/cmc_core
```

> Establishes the import of `github.com/swill/cmc_core` and sets the reference to be the local directory.