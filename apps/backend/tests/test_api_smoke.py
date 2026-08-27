"""Smoke tests against the mock profile.

If these fail with the network disabled, our demo insurance has a hole in it.
"""

from __future__ import annotations

import base64

import pytest
from app.main import app
from fastapi.testclient import TestClient


@pytest.fixture
def client() -> TestClient:
    return TestClient(app)


def test_health(client: TestClient) -> None:
    assert client.get("/v1/health").json() == {"status": "ok"}


def test_crafts_endpoint_returns_seed(client: TestClient) -> None:
    body = client.get("/v1/crafts").json()
    assert any(c["id"] == "pochampally_ikat" for c in body)
    assert all(c["collection"] for c in body)


def test_voice_to_catalog_produces_both_locales_and_flags_missing(
    client: TestClient,
) -> None:
    payload = {"language": "te-IN", "audio_base64": base64.b64encode(b"fake").decode()}
    body = client.post("/v1/catalog/from-voice", json=payload).json()

    locales = {d["locale"] for d in body["descriptions"]}
    assert locales == {"en-IN", "hi-IN"}

    # The mock deliberately leaves hours and quantity unfilled: the app must be
    # told to ask about them aloud rather than the model inventing values.
    assert "hours_to_make" in body["attributes"]["missing"]
    assert "quantity_available" in body["attributes"]["missing"]

    # Craft vocabulary must reach the keywords -- that is Bet 02 working.
    en = next(d for d in body["descriptions"] if d["locale"] == "en-IN")
    assert "ikat" in en["keywords"]


def test_rejects_bad_base64(client: TestClient) -> None:
    r = client.post(
        "/v1/catalog/from-voice", json={"language": "hi-IN", "audio_base64": "!!!not base64!!!"}
    )
    assert r.status_code == 422


def test_quote_never_suggests_below_floor(client: TestClient) -> None:
    r = client.post(
        "/v1/pricing/quote",
        json={
            "craft_id": "banarasi_brocade",
            "state": "Uttar Pradesh",
            "material_cost": "4500",
            "hours": "160",
            "finish_score": 0.2,
        },
    )
    body = r.json()
    assert float(body["suggested"]) >= float(body["floor"])
    assert body["rationale"]


def test_quote_unknown_craft_is_404(client: TestClient) -> None:
    r = client.post(
        "/v1/pricing/quote",
        json={
            "craft_id": "nope",
            "state": "Bihar",
            "material_cost": "1",
            "hours": "1",
        },
    )
    assert r.status_code == 404
