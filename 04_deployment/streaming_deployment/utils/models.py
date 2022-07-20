""" Models for validation pubsub payloads """
from typing import Optional
import base64
from pydantic import BaseModel, Field 


class BaseModelWithPubSub(BaseModel):
    """ Extra decode functions for pubsub data """

    @classmethod
    def from_base64(cls, data: bytes):
        return cls.parse_raw(base64.b64decode(data).decode("utf-8"))

    @classmethod
    def from_event(cls, event: dict):
        return cls.from_base64(event["data"])


class RideFeatures(BaseModelWithPubSub):
    """ Ride feature data """
    PULOCATIONID: str = Field(..., title="Pickup Location ID")
    DOLOCATIONID: str = Field(..., title="Dropoff Location ID")
    TRIP_DISTANCE: int = Field(..., title="Trip distance")
    
class RideData(BaseModelWithPubSub):
    """ Ride event data """
    ride: Optional[RideFeatures] = None
    ride_id: str

