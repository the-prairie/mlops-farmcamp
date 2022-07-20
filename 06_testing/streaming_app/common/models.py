""" Models for validation pubsub payloads """
from typing import Optional
import ujson
import uuid
from pydantic import BaseModel, Field, validator


class RideData(BaseModel):
    """ Ride feature data """
    PULOCATIONID: str = Field(..., title="Pickup Location ID")
    DOLOCATIONID: str = Field(..., title="Dropoff Location ID")
    TRIP_ROUTE: Optional[str] = None
    TRIP_DISTANCE: float = Field(..., title="Trip distance")
    RIDE_ID: Optional[str] = None
    
    @validator("RIDE_ID", pre=True, always=True)
    def set_ride_id(cls, v):
        return str(uuid.uuid4())
    
    @validator("TRIP_ROUTE", pre=True, always=True)
    def set_trip_route(cls, v, values) -> str:
        return f'{values["PULOCATIONID"]}_{values["DOLOCATIONID"]}'
    
    class Config:
        json_loads = ujson.loads


class ProcessedRide(RideData):
    """ Ride feature data """
    PREDICTED_DURATION: float

    

    
    
    

