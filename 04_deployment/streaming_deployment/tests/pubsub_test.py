
""" Tests for main.py """

import pytest
import json
from base64 import b64encode
from utils.models import RideData

from functions_framework import create_app  # type: ignore

FUNCTION_SOURCE = "./main.py"

@pytest.fixture(scope="module")
def predict_client():
    """ Predict client """
    return create_app("ride_prediction", FUNCTION_SOURCE, "event").test_client()



@pytest.fixture
def tick_payload():
    """ Payload for tick """
    data = RideData().json()
    return {
        "context": {
            "eventId": "some-eventId",
            "timestamp": "some-timestamp",
            "eventType": "some-eventType",
            "resource": "some-resource",
        },
        "data": {"data": b64encode(data.encode()).decode()},
    }