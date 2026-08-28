"""Tests for the client generator.

The generator's whole value is that it fails loudly instead of emitting the
wrong Dart, so most of these assert on the failure modes.

    uv run pytest ../../tools/test_gen_dart_client.py      # from apps/backend
"""

from __future__ import annotations

import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))

from gen_dart_client import (  # noqa: E402
    UnsupportedSchema,
    build_model,
    dart_default,
    resolve,
)


def _t(node: dict[str, object]) -> str:
    return resolve(node, where="test").name


class TestTypeMapping:
    def test_primitives(self) -> None:
        assert _t({"type": "string"}) == "String"
        assert _t({"type": "integer"}) == "int"
        assert _t({"type": "boolean"}) == "bool"
        assert _t({"type": "number"}) == "double"

    def test_money_is_decimal_never_double(self) -> None:
        """Rupees in a float is the bug we refuse to ship."""
        money = {"type": "string", "pattern": r"^[+-]?0*\d*\.?\d*$"}
        assert _t(money) == "Decimal"

    def test_money_input_union_is_decimal(self) -> None:
        node = {
            "anyOf": [
                {"type": "number"},
                {"type": "string", "pattern": r"^[+-]?0*\d*\.?\d*$"},
            ]
        }
        assert _t(node) == "Decimal"

    def test_nullable(self) -> None:
        assert _t({"anyOf": [{"type": "string"}, {"type": "null"}]}) == "String?"

    def test_array_of_ref(self) -> None:
        node = {"type": "array", "items": {"$ref": "#/components/schemas/CraftOut"}}
        assert _t(node) == "List<CraftOut>"

    def test_heterogeneous_primitive_union_is_dynamic(self) -> None:
        # FastAPI's ValidationError.loc: field names or list indices.
        assert _t({"anyOf": [{"type": "string"}, {"type": "integer"}]}) == "dynamic"


class TestStrictness:
    """A generator that guesses is worse than no generator."""

    def test_union_of_models_is_rejected(self) -> None:
        node = {
            "anyOf": [
                {"$ref": "#/components/schemas/A"},
                {"$ref": "#/components/schemas/B"},
            ]
        }
        with pytest.raises(UnsupportedSchema, match="unsupported anyOf"):
            resolve(node, where="test")

    def test_array_without_items_is_rejected(self) -> None:
        with pytest.raises(UnsupportedSchema, match="without items"):
            resolve({"type": "array"}, where="test")

    def test_inline_object_with_properties_is_rejected(self) -> None:
        node = {"type": "object", "properties": {"a": {"type": "string"}}}
        with pytest.raises(UnsupportedSchema, match="named model"):
            resolve(node, where="test")

    def test_unknown_type_is_rejected(self) -> None:
        with pytest.raises(UnsupportedSchema, match="unhandled type"):
            resolve({"type": "tuple"}, where="test")


class TestModelEmission:
    def test_required_and_defaults(self) -> None:
        out = build_model(
            "Sample",
            {
                "required": ["name"],
                "properties": {
                    "name": {"type": "string"},
                    "tags": {"type": "array", "items": {"type": "string"},
                             "default": []},
                    "note": {"anyOf": [{"type": "string"}, {"type": "null"}]},
                },
            },
        )
        assert "required this.name," in out
        assert "this.tags = const []," in out
        assert "final String? note;" in out
        # snake_case on the wire, camelCase in Dart
        assert "Map<String, dynamic> toJson()" in out

    def test_snake_case_becomes_camel_case(self) -> None:
        out = build_model(
            "Sample", {"required": ["craft_id"], "properties": {"craft_id": {"type": "string"}}}
        )
        assert "final String craftId;" in out
        assert "'craft_id': craftId," in out


def test_string_defaults_are_quoted() -> None:
    assert dart_default("INR", "String") == "'INR'"
    assert dart_default([], "List<String>") == "const []"
