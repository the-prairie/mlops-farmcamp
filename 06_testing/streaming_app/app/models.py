""" Models for validation pubsub payloads """
from typing import Optional
import ujson
from pydantic import BaseModel, Field 


class RideFeatures(BaseModel):
    """ Ride feature data """
    PULOCATIONID: str = Field(..., title="Pickup Location ID")
    DOLOCATIONID: str = Field(..., title="Dropoff Location ID")
    TRIP_DISTANCE: int = Field(..., title="Trip distance")
    
    
    
class RideData(BaseModel):
    """ Ride event data """
    ride: Optional[RideFeatures] = None
    ride_id: str
    
    class Config:
        json_loads = ujson.loads

