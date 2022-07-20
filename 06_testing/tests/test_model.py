import pytest

from prediction_service.prediction_model import AbstractPredictionModel, LRPredictionModel


def test_prepare_features():
    ride = {
        ""
    }
    
    actual_features = 