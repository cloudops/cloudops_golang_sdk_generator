# Authoring Guidelines for OpenAPI Specs (to Support Go SDK Generation)

The OpenAPI specifications you write are later used to automatically generate SDKs in multiple languages.
Some patterns in OpenAPI are valid according to the spec, but cause serious issues in SDK generation, especially **Golang**.

This guide explains what *not* to do and how to structure schemas so SDK generation is clean and stable.

---

## ✅ Do: Always Use Named Schemas

Whenever you define an object type, array item, or nested schema, ensure it is a **named schema** under `#/components/schemas`.

**Good Example:**

```yaml
components:
  schemas:
    Environment:
      type: object
      properties:
        id:
          type: string
        name:
          type: string

paths:
  /environments:
    post:
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/Environment'
```

---

## ❌ Don’t: Use Inline Object Definitions

Inline schemas work in JSON/YAML, but they cause problems for Go because each inline object needs a type name.

**Bad Example:**

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
                name:
                  type: string
```

👉 In Go, this generates an **auto-named type** like `Auto_paths__environments_post_request_schema`, which is unreadable and unstable.

---

## ✅ Do: Extract Inline Schemas into Components

If you need an object, define it once in `components/schemas` and reference it.

**Fixed Example:**

```yaml
components:
  schemas:
    CreateEnvironmentRequest:
      type: object
      properties:
        id:
          type: string
        name:
          type: string

paths:
  /environments:
    post:
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateEnvironmentRequest'
```

---

## ❌ Don’t: Define Inline Arrays of Objects

Inline arrays of objects are also problematic.

**Bad Example:**

```yaml
schema:
  type: array
  items:
    type: object
    properties:
      id:
        type: string
```

---

## ✅ Do: Extract Array Item Objects into Components

**Fixed Example:**

```yaml
components:
  schemas:
    Environment:
      type: object
      properties:
        id:
          type: string

    EnvironmentList:
      type: array
      items:
        $ref: '#/components/schemas/Environment'
```

---

## ❌ Don’t: Leave Content Wrappers Without `schema`

Sometimes content definitions mistakenly contain only a `$ref`.

**Bad Example:**

```yaml
content:
  application/json:
    $ref: '#/components/schemas/Environment'
```

---

## ✅ Do: Always Wrap `$ref` in `schema`

**Fixed Example:**

```yaml
content:
  application/json:
    schema:
      $ref: '#/components/schemas/Environment'
```

---

## Summary of Rules

* ❌ No inline `type: object` or `type: array` definitions.
* ✅ Always move objects into `#/components/schemas` with a clear, stable name.
* ✅ Wrap `$ref` inside a `schema` when used under `content`.
* ✅ Reuse schemas by reference instead of redefining them inline.

---

Following these conventions ensures:

* Clean and stable **Golang SDKs** (no ugly `Auto_*` types).
* Reusable, maintainable schemas.
* Easier debugging and consistent types across all SDKs.

