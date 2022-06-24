import pickle
from fastapi import FastAPI
from pydantic import BaseModel



app = FastAPI()

class Ride(BaseModel):
    PULOCATIONID: int
    DOLOCATIONID: int
    TRIP_DISTANCE: float
    
class PredictedRideDuration(BaseModel):
    PREDICTED_DURATION: float

with open ("models/linreg_model.bin", "rb") as f_in:
   (dv, model) = pickle.load(f_in)
   

def prepare_features(ride):
    features = {}
    features["ROUTE"] = f'{ride["PULOCATIONID"]}_{ride["DOLOCATIONID"]}'
    features["TRIP_DISTANCE"] = ride["TRIP_DISTANCE"]
    return features
    
    
def predict(features):
    X = dv.transform(features)
    predictions = model.predict(X)
    
    return predictions[0]

@app.get("/")
def read_root():
    return "Hello Rider"


@app.post("/predict")
async def predict_ride(ride: Ride):
    ride_dict = ride.dict()
    features = prepare_features(ride_dict)
    prediction = predict(features=features)
    
    
    return {"Ride duration":prediction}


