# Inline Schema Lifter for OpenAPI Specs

This script automatically **lifts inline schemas** out of OpenAPI specifications and moves them into `#/components/schemas`, ensuring the spec is more compatible with SDK generators (especially **Golang**).

It also fixes certain OpenAPI content wrapper issues that otherwise break Go SDK generation.

---

## ✨ Features

* Iteratively traverses the entire OpenAPI spec (YAML or JSON).
* Detects inline object schemas (`type: object`, `properties`, `allOf`, `anyOf`, `oneOf`) that are not `$ref`-based.
* Lifts those inline schemas into **named schemas** under `#/components/schemas`.
* Auto-generates names using the path (`Auto_<sanitized_path>`).
* Ensures schema names are sanitized to satisfy **OpenAPI Generator’s regex rules**.
* Fixes invalid `content` blocks by ensuring `$ref` is wrapped in a `schema`.
* Outputs a clean, SDK-friendly OpenAPI file.

---

## 🚀 Usage

The script is designed to run inside a container (e.g., in the provided Makefile), but you can also run it directly.

### Inputs

* `INPUT_FILE` → Name of the spec file inside `/data` to process (e.g. `core_openapi.json`)
* `OUTPUT_FILE` → Name of the transformed spec file inside `/data` to write (e.g. `core_openapi_lifted.json`)

Both must be set as **environment variables**.

### Example (Docker Run)

```bash
docker run \
  -e INPUT_FILE=core_openapi.json \
  -e OUTPUT_FILE=core_openapi_lifted.json \
  -v $(pwd)/api_specs:/data \
  go-inline-lifter
```

### Example (Direct Python Run)

```bash
INPUT_FILE=./api_specs/core_openapi.json \
OUTPUT_FILE=./api_specs/core_openapi_lifted.json \
python inline_lifter.py
```

---

## 🛠 How It Works

1. Loads the input spec (`.yaml` or `.json`).
2. Walks the tree iteratively (stack-based, avoids recursion depth issues).
3. If it finds an inline schema:

   * Generates a unique name like `Auto_paths_environments_post_request_schema`.
   * Moves the inline schema into `components.schemas`.
   * Replaces the inline schema with a `$ref`.
4. If it finds invalid content:

   * Wraps `$ref` in a `schema`.
5. Writes the transformed spec back as JSON or YAML.

---

## 📂 Output Example

### Before

```yaml
paths:
  /environments:
    post:
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                id:
                  type: string
```

### After

```yaml
components:
  schemas:
    Auto_paths_environments_post_requestBody_content_application_json_schema:
      type: object
      properties:
        id:
          type: string

paths:
  /environments:
    post:
      requestBody:
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/Auto_paths_environments_post_requestBody_content_application_json_schema"
```

---

## ⚠️ Limitations

* Auto-generated names can be long and not human-friendly (`Auto_<path>`).
* Manual cleanup may be needed to rename important schemas for readability.
* This script only **fixes inline schemas and content wrappers** — it does not validate or restructure other parts of the spec.
* If two inline schemas occur at the same path, suffixes `_2`, `_3`, etc. are added.

---

## ✅ Why This Matters

Many OpenAPI specs contain inline schemas that are valid JSON/YAML but **break SDK generation** (especially Go). By lifting them:

* Go SDKs generate without ugly `Auto_*` types.
* SDKs across all languages become more stable.
* Specs are cleaner, reusable, and easier to maintain.
