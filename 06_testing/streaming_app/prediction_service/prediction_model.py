import pickle
import uuid
from abc import ABC, abstractmethod

from common.models import RideData, ProcessedRide

class AbstractPredictionModel(ABC):
    """Base abstract class for other RidePrediction implementation, should be used as interface. """
    
    @abstractmethod
    def compute_features(self, ride: RideData):
        pass
    
    @abstractmethod
    def predict(self, ride: RideData, features) -> ProcessedRide:
        pass
    
    def process(self, ride: RideData) -> ProcessedRide:
        """
        This method applies feature processing logic on input ride:
        1. Compute inpute features for model
        2. Predict ride duration
        """
        features, record = self.compute_features(ride)
        prediction = self.predict(features)
        record["PREDICTED_DURATION"] = prediction
        
        return record
    
class LRPredictionModel(AbstractPredictionModel):
    def __init__(self, dv, model):
         super().__init__()
         self.dv = dv
         self.model = model
         
    def compute_features(self, ride: RideData):
        record = ride.copy()
        record["TRIP_ROUTE"] = record["PULOCATIONID"] + "_" + record["DOLOCATIONID"] 
        features = self.dv.transform([record])
        return features, record
    
    def predict(self, ride: RideData, features) -> ProcessedRide:
        prediction = self.model.predict(features)
        ride_id = str(uuid.uuid4())
        return ProcessedRide(
            RIDE_ID=ride_id,
            PREDICTED_DURATION=prediction,
            **ride.dict()
        )
        
    

