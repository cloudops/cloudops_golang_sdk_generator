import json
import copy
import os
import re
from pathlib import Path
from ruamel.yaml import YAML

yaml = YAML()

input_file = os.getenv('INPUT_FILE')
output_file = os.getenv('OUTPUT_FILE')

if not input_file or not output_file:
    raise ValueError("Both INPUT_FILE and OUTPUT_FILE environment variables must be set.")

spec_path = Path("/data/" + input_file)
if spec_path.suffix in (".yaml", ".yml"):
    spec = yaml.load(spec_path.read_text())
else:
    spec = json.loads(spec_path.read_text())

components = spec.setdefault("components", {}).setdefault("schemas", {})

# --- debug counters ---
lifted_count = 0
visited_count = 0

def sanitize_schema_name(name: str) -> str:
    """Sanitize schema name to satisfy OpenAPI Generator's regex rules."""
    # Replace illegal characters with underscores
    name = re.sub(r"[^a-zA-Z0-9\.\-_]", "_", name)
    # Collapse multiple underscores
    name = re.sub(r"_+", "_", name)
    # Remove leading/trailing underscores
    return name.strip("_")

def process_node_iterative(root):
    """Iterative traversal to lift inline schemas and fix content wrappers."""
    global lifted_count, visited_count
    stack = [(root, "")]
    visited = set()

    schema_related = {
        "schema", "schemas", "items", "allOf", "anyOf", "oneOf",
        "properties", "additionalProperties", "content",
        "requestBody", "responses"
    }

    while stack:
        node, path = stack.pop()
        obj_id = id(node)
        if obj_id in visited:
            continue
        visited.add(obj_id)
        visited_count += 1

        if isinstance(node, dict):
            # --- Handle inline schema lifting ---
            if path.endswith(".schema") or path.startswith("components.schemas"):
                if ("type" in node or "properties" in node or
                    "allOf" in node or "anyOf" in node or "oneOf" in node):
                    if "$ref" not in node:
                        lifted_count += 1
                        if lifted_count % 100 == 0:
                            print(f"[INFO] Lifted {lifted_count} schemas so far (visited {visited_count} nodes)...")

                        raw_name = path.replace(".", "_").replace("/", "_") or "Root"
                        schema_name = "Auto_" + sanitize_schema_name(raw_name)

                        i = 1
                        while schema_name in components:
                            i += 1
                            schema_name = f"{schema_name}_{i}"

                        components[schema_name] = copy.deepcopy(node)
                        node.clear()
                        node["$ref"] = f"#/components/schemas/{schema_name}"
                        continue  # don’t recurse further into this replaced node

            # --- Fix content mediaType wrappers ---
            if path.endswith(".content") or ".content." in path:
                for mt, mt_val in list(node.items()):
                    if isinstance(mt_val, dict) and "$ref" in mt_val:
                        node[mt] = {"schema": mt_val}

            # --- Push children ---
            for k, v in node.items():
                if isinstance(v, (dict, list)):
                    # always follow schema-related keys
                    if k in schema_related:
                        stack.append((v, f"{path}.{k}" if path else k))
                    # otherwise follow at shallow paths (paths, components, etc.)
                    elif path.count(".") < 4:
                        stack.append((v, f"{path}.{k}" if path else k))

        elif isinstance(node, list):
            for i, v in enumerate(node):
                if isinstance(v, (dict, list)):
                    stack.append((v, f"{path}[{i}]"))

# --- run transform ---
print(f"[INFO] Starting inline lifter on {input_file} → {output_file}")
process_node_iterative(spec)
print(f"[INFO] Finished traversal: visited {visited_count} nodes, lifted {lifted_count} schemas")

# --- write output ---
output_path = Path("/data/" + output_file)
if output_path.suffix in (".yaml", ".yml"):
    yaml.dump(spec, output_path.open("w"))
else:
    output_path.write_text(json.dumps(spec, indent=2))
print(f"[INFO] Wrote lifted spec to {output_path}")
