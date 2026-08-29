"""Generate the Dart API client from openapi.json (ADR-0005).

    python tools/gen_dart_client.py

Deliberately strict: any schema shape this does not understand raises
UnsupportedSchema rather than emitting `dynamic`. A generator that silently
produces the wrong type is worse than no generator -- the error surfaces at
generation time, where it is cheap, instead of as a runtime cast failure on a
phone in a village.
"""

from __future__ import annotations

import hashlib
import json
import re
from collections.abc import Callable
from dataclasses import dataclass
from pathlib import Path
from typing import Any

REPO = Path(__file__).resolve().parents[1]
SCHEMA_PATH = REPO / "packages" / "api_client_dart" / "openapi.json"
OUT_PATH = REPO / "packages" / "api_client_dart" / "lib" / "shilpsetu_api.dart"

# Pydantic v2 renders Decimal as a pattern-constrained string. Money must not
# become a double, so we detect that shape and map it to package:decimal.
_DECIMAL_PATTERN_HINT = r"\d*\.?\d*"


class UnsupportedSchema(Exception):
    """Raised when the schema contains a shape the generator cannot map."""


@dataclass(frozen=True)
class DartType:
    name: str
    decode: Callable[[str], str]
    encode: Callable[[str], str]

    def nullable(self) -> DartType:
        inner = self
        encodes_identity = inner.encode("__x") == "__x"
        return DartType(
            name=f"{inner.name}?",
            decode=lambda e: f"{e} == null ? null : {inner.decode(e)}",
            encode=(lambda e: e)
            if encodes_identity
            else (lambda e: f"{e} == null ? null : {inner.encode(f'{e}!')}"),
        )


def _identity(name: str, cast: str | None = None) -> DartType:
    return DartType(
        name=name,
        decode=(lambda e: f"{e} as {cast}") if cast else (lambda e: e),
        encode=lambda e: e,
    )


_PRIMITIVES: dict[str, DartType] = {
    "string": _identity("String", "String"),
    "integer": _identity("int", "int"),
    "boolean": _identity("bool", "bool"),
}
_DOUBLE = DartType(
    name="double",
    decode=lambda e: f"({e} as num).toDouble()",
    encode=lambda e: e,
)
_DECIMAL = DartType(
    name="Decimal",
    decode=lambda e: f"Decimal.parse({e} as String)",
    encode=lambda e: f"{e}.toString()",
)
_DYNAMIC = _identity("dynamic")
_MAP = _identity("Map<String, dynamic>", "Map<String, dynamic>")


def _is_decimal(node: dict[str, Any]) -> bool:
    return node.get("type") == "string" and _DECIMAL_PATTERN_HINT in node.get("pattern", "")


def _ref_name(ref: str) -> str:
    return ref.rsplit("/", 1)[-1]


def resolve(node: dict[str, Any], *, where: str) -> DartType:
    """Map one JSON-Schema node to a Dart type."""
    if "$ref" in node:
        cls = _ref_name(node["$ref"])
        return DartType(
            name=cls,
            decode=lambda e: f"{cls}.fromJson({e} as Map<String, dynamic>)",
            encode=lambda e: f"{e}.toJson()",
        )

    if "anyOf" in node:
        options = node["anyOf"]
        non_null = [o for o in options if o.get("type") != "null"]
        is_optional = len(non_null) < len(options)

        # Decimal input shape: anyOf[number, pattern-string].
        if len(non_null) == 2 and any(_is_decimal(o) for o in non_null):
            base = _DECIMAL
        elif len(non_null) == 1:
            base = resolve(non_null[0], where=where)
        elif all(o.get("type") in _PRIMITIVES or o.get("type") == "number"
                 for o in non_null):
            # A heterogeneous union of primitives -- e.g. FastAPI's
            # ValidationError.loc, whose entries are field names or list
            # indices. `dynamic` is the honest Dart mapping here, not a
            # fallback: there is no narrower type that is correct.
            base = _DYNAMIC
        else:
            # Anything involving refs, arrays or objects. We will not guess.
            raise UnsupportedSchema(
                f"{where}: unsupported anyOf {json.dumps(options)}. "
                "Give the field a single concrete type, or extend the generator."
            )
        return base.nullable() if is_optional else base

    if _is_decimal(node):
        return _DECIMAL

    node_type = node.get("type")
    if node_type is None:
        # Untyped (e.g. pydantic's ValidationError.input). Legitimately dynamic.
        return _DYNAMIC
    if node_type == "number":
        return _DOUBLE
    if node_type == "object":
        if node.get("properties"):
            raise UnsupportedSchema(
                f"{where}: inline object with properties. Give it a named model."
            )
        return _MAP
    if node_type == "array":
        items = node.get("items")
        if items is None:
            raise UnsupportedSchema(f"{where}: array without items")
        inner = resolve(items, where=f"{where}[]")
        return DartType(
            name=f"List<{inner.name}>",
            decode=lambda e: (
                f"({e} as List<dynamic>).map((e) => {inner.decode('e')}).toList()"
            ),
            encode=(lambda e: e)
            if inner.encode("__x") == "__x"
            else (lambda e: f"{e}.map((e) => {inner.encode('e')}).toList()"),
        )
    if node_type in _PRIMITIVES:
        return _PRIMITIVES[node_type]

    raise UnsupportedSchema(f"{where}: unhandled type {node_type!r}")


def dart_default(value: Any, dart_type: str) -> str:
    if isinstance(value, list):
        if value:
            raise UnsupportedSchema(f"non-empty list default {value!r}")
        return "const []"
    if isinstance(value, str):
        return "'" + value.replace("'", r"\'") + "'"
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, (int, float)):
        return f"{value}" if dart_type != "double" or "." in str(value) else f"{value}.0"
    raise UnsupportedSchema(f"unhandled default {value!r}")


def lower_first(s: str) -> str:
    return s[:1].lower() + s[1:]


def camel(s: str) -> str:
    head, *rest = s.split("_")
    return head + "".join(p.title() for p in rest)


@dataclass
class Field:
    json_name: str
    dart_name: str
    type: DartType
    required: bool
    default: str | None


def build_model(name: str, schema: dict[str, Any]) -> str:
    required = set(schema.get("required", []))
    fields: list[Field] = []
    for prop, node in schema.get("properties", {}).items():
        t = resolve(node, where=f"{name}.{prop}")
        has_default = "default" in node
        is_required = prop in required
        if not is_required and not has_default and not t.name.endswith("?") and t.name != "dynamic":
            t = t.nullable()
        fields.append(
            Field(
                json_name=prop,
                dart_name=camel(prop),
                type=t,
                required=is_required,
                default=dart_default(node["default"], t.name) if has_default else None,
            )
        )
    # Required first, then alphabetical: stable output, readable constructors.
    fields.sort(key=lambda f: (not f.required, f.dart_name))

    params = []
    for f in fields:
        if f.required:
            params.append(f"    required this.{f.dart_name},")
        elif f.default is not None:
            params.append(f"    this.{f.dart_name} = {f.default},")
        else:
            params.append(f"    this.{f.dart_name},")

    decodes = []
    for f in fields:
        expr = f.type.decode(f"json['{f.json_name}']")
        decodes.append(f"        {f.dart_name}: {expr},")

    declarations = [f"  final {f.type.name} {f.dart_name};" for f in fields]

    encodes = []
    for f in fields:
        encodes.append(f"        '{f.json_name}': {f.type.encode(f.dart_name)},")

    body = "\n".join(
        [
            f"class {name} {{",
            f"  const {name}({{",
            *params,
            "  });",
            "",
            f"  factory {name}.fromJson(Map<String, dynamic> json) => {name}(",
            *decodes,
            "      );",
            "",
            *declarations,
            "",
            "  Map<String, dynamic> toJson() => <String, dynamic>{",
            *encodes,
            "      };",
            "}",
        ]
    )
    return body


def build_client(spec: dict[str, Any]) -> str:
    methods: list[str] = []
    for path, ops in sorted(spec["paths"].items()):
        for verb, op in sorted(ops.items()):
            op_id = op.get("operationId")
            if not op_id:
                raise UnsupportedSchema(
                    f"{verb.upper()} {path} has no operationId. Add "
                    'operation_id="..." to the route so the generated method '
                    "has a stable, readable name."
                )
            name = lower_first(camel(op_id))

            body_type: DartType | None = None
            rb = op.get("requestBody")
            if rb:
                content = rb["content"]["application/json"]["schema"]
                body_type = resolve(content, where=f"{op_id}.body")

            ok = op["responses"].get("200", {}).get("content", {})
            if ok:
                ret = resolve(
                    ok["application/json"]["schema"], where=f"{op_id}.response"
                )
                ret_name, decode = ret.name, ret.decode("data")
            else:
                ret_name, decode = "void", ""

            args = f"{body_type.name} body" if body_type else ""
            send = (
                f"      data: {body_type.encode('body')},\n" if body_type else ""
            )
            lines = [
                f"  /// `{verb.upper()} {path}`",
                f"  Future<{ret_name}> {name}({args}) async {{",
                f"    final response = await _dio.request<dynamic>(",
                f"      '{path}',",
                f"      options: Options(method: '{verb.upper()}'),",
                send + "    );",
            ]
            if ret_name == "void":
                lines.append("    return;")
            else:
                lines += [
                    "    final data = response.data;",
                    f"    return {decode};",
                ]
            lines.append("  }")
            methods.append("\n".join(lines))

    return "\n".join(
        [
            "/// Typed client for the Shilpsetu API.",
            "///",
            "/// Construct with a configured [Dio] so callers control the base URL,",
            "/// timeouts and interceptors:",
            "///",
            "/// ```dart",
            "/// final api = ShilpsetuApi(Dio(BaseOptions(",
            "///   baseUrl: 'http://10.0.2.2:8000',",
            "/// )));",
            "/// ```",
            "class ShilpsetuApi {",
            "  const ShilpsetuApi(this._dio);",
            "",
            "  final Dio _dio;",
            "",
            *[m + "\n" for m in methods],
            "}",
        ]
    )


def main() -> int:
    spec = json.loads(SCHEMA_PATH.read_text(encoding="utf-8"))
    digest = hashlib.sha256(SCHEMA_PATH.read_bytes()).hexdigest()[:16]

    schemas = spec.get("components", {}).get("schemas", {})
    models = [build_model(n, s) for n, s in sorted(schemas.items())]

    out = "\n".join(
        [
            "// GENERATED FILE — DO NOT EDIT.",
            "//",
            "// Source: packages/api_client_dart/openapi.json",
            f"// Schema sha256: {digest}",
            "// Regenerate: python tools/gen_dart_client.py",
            "",
            "// ignore_for_file: type=lint",
            "",
            "import 'package:decimal/decimal.dart';",
            "import 'package:dio/dio.dart';",
            "",
            *[m + "\n" for m in models],
            build_client(spec),
            "",
        ]
    )
    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUT_PATH.write_text(out, encoding="utf-8")
    print(f"wrote {OUT_PATH.relative_to(REPO)} ({len(models)} models, schema {digest})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
