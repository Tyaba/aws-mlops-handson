import json
from unittest.mock import patch

import pytest
from fastapi.testclient import TestClient


@pytest.fixture(scope="module")
@patch("predictor.setup.get_model_preprocessor")
def test_client(mocked_get_model_preprocessor):
    from predictor.routers import router

    return TestClient(router)


def test_healthcheck(test_client):
    response = test_client.get("/healthcheck")
    assert response.status_code == 200
    assert response.json() == {"health": "ok"}


def test_predict(test_client):
    data = {
        "hour": "14102100",
        "banner_pos": "0",
        "site_id": "1fbe01fe",
        "site_domain": "f3845767",
        "site_category": "28905ebd",
        "app_id": "ecad2386",
        "app_domain": "7801e8d9",
        "app_category": "07d7df22",
        "device_id": "a99f214a",
        "device_ip": "ddd2926e",
        "device_model": "44956a24",
        "device_type": "1",
    }

    response = test_client.post("/predict", data=json.dumps(data))
    assert response.status_code == 200
    assert "prediction" in response.json()
    assert "model" in response.json()
