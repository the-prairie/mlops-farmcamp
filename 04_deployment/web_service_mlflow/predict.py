import pickle
from fastapi import FastAPI
from pydantic import BaseModel

import mlflow
import os
from dotenv import load_dotenv
load_dotenv()

MLFLOW_TRACKING_URI = os.environ.get("MLFLOW_TRACKING_URI")
mlflow.set_tracking_uri(f"{MLFLOW_TRACKING_URI}:4040")

model_name = "SklearnRFGreenTaxi"
model_version = 2
model = mlflow.pyfunc.load_model(
    model_uri=f"models:/{model_name}/{model_version}"
)


app = FastAPI()

class Ride(BaseModel):
    PULOCATIONID: int
    DOLOCATIONID: int
    TRIP_DISTANCE: float
    
class PredictedRideDuration(BaseModel):
    PREDICTED_DURATION: float
   

def prepare_features(ride):
    features = {}
    features["ROUTE"] = f'{ride["PULOCATIONID"].astype(str)}_{ride["DOLOCATIONID"].astype(str)}'
    features["TRIP_DISTANCE"] = ride["TRIP_DISTANCE"]
    return features
    
    
def predict(features):
    predictions = model.predict(features)
    
    return predictions[0]


@app.get("/")
def read_root():
    return "Hello Rider"


@app.post("/predict")
async def predict_ride(ride: Ride):
    ride_dict = ride.dict()
    features = prepare_features(ride_dict)
    prediction = predict(features=features)
    
    
    return {
        "Ride duration": prediction,
        "Model": model_name,
        "Model Version": model_version
    }
