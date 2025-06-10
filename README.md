CloudOps SDK Generation
-----------------------

The included `Makefile` is a convenience function for generating the CloudOps Software Golang SDK via the OpenAPI specification.

## Initial Setup

First, you need to install the `openapi-generator`.  In order for this `Makefile` to work, you will need to install it with Homebrew.

```bash
$ brew install openapi-generator
```

Now that the `openapi-generator` is installed, you need to setup the variables and the folder structure.

```bash
$ cp variables.env.sample variables.env
```
> Make sure to configure the variables in `variables.env` to match your configuration.

```bash
$ make setup
```

> The folders `./api_specs`, `./logs`, and `./sdk_out` will be created.

## Generating the SDK

**NOTE:** You will need to ensure the `github_handle` and `endpoint` are set correctly in the `Makefile`.  The `github_handle` is used when generating the package import url.

In order to generate the SDK, you need to pull down the spec files.

```bash
$ make curl
```

> The folder `./api_specs` will be populated with spec files.  
> You can curl specific specs with the following commands: `curl_core`, `curl_aws`, `curl_azure`, `curl_vcd`, `curl_acs`

Now that you have the spec files, you need to generate the SDK output from the spec files.

```bash
$ make generate
```

*The default `make` command is mapped to this command*

> The folder `./sdk_out` will be populated with SDKs and the `./logs` folder will have the corresponding logs.  
> You can populate specific SDKs with the following commands: `generate_core`, `generate_aws`, `generate_azure`, `generate_vcd`, `generate_acs`

## Backup Folders

You may want to pull down a newer version of the specs and generate a new SDK.  If you have a working configuration, you might want to backup your existing configuration so you have something to rollback to if something goes wrong.

```bash
make backup
```

> Backups up the `./api_specs` and `./sdk_out` folders, and recreates the empty target folders.

## Reset Folders

You may choose to pull down newer specs or regenerate the SDK, before you do that you will want to clean up the existing directories.

> **NOTE:** The following commands will delete existing data.  You may want to use `make backup` instead if you have a working environment today.

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

In this case, I will only reference the `cmc_core` package and I will reference it as `github.com/cloudops/cmc_core`.

To change the github handle to something other than `cloudops`, be sure to set the `github_handle` variable appropriately in the `Makefile`.

In your `go.mod` file, add the following reference:

```
require (
	github.com/cloudops/cmc_core v0.0.0
)

replace github.com/cloudops/cmc_core => /path/to/sdk_out/cmc_core
```

> Establishes the import of `github.com/cloudops/cmc_core` and sets the reference to be the local directory.