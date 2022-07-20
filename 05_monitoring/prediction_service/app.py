import os
from dotenv import load_dotenv
load_dotenv()

import pathlib
import pickle
import requests

from fastapi import FastAPI
from pydantic import BaseModel

from pymongo.mongo_client import MongoClient

# Environment variables
MODEL_FILE =  os.environ.get("MODEL_FILE", "lin_reg.bin")
MONGO_DB_ADDRESS = os.environ.get("MONGO_DB_ADDRESS", "mongodb://127.0.0.1:27017")
EVIDENTLY_SERVICE_ADDRESS = os.environ.get("EVIDENTLY_SERVICE_ADDRESS", "http://127.0.0.1:5000")


with open(MODEL_FILE, "rb") as f_in:
    dv, model = pickle.load(f_in)
    

app = FastAPI()

client = MongoClient(MONGO_DB_ADDRESS)
db = client.get_database("prediction_service")
collection = db.get_collection("data")

class Ride(BaseModel):
    PULOCATIONID: int
    DOLOCATIONID: int
    TRIP_DISTANCE: float
    
class PredictedRideDuration(BaseModel):
    PREDICTED_DURATION: float
    

@app.post("/predict")
async def predict_ride(ride: Ride):
    ride_dict = ride.dict()
    ride_dict["PU_DO"] = str(ride_dict["PULOCATIONID"]) + "_" + str(ride_dict["DOLOCATIONID"])
    
    X = dv.transform([ride_dict])
    y_pred = model.predict(X)[0]
    
    result = {
        "ride_duration": float(y_pred)
    }
    
    save_to_db(ride_dict, float(y_pred))
    send_to_evidently(ride_dict, float(y_pred))
    
    return result

def save_to_db(record, prediction):
    record = record.copy()
    record["prediction"] = prediction
    
    collection.insert_one(record)

def send_to_evidently(record, prediction):
    record = record.copy()
    record["prediction"] = prediction
    requests.post(f"{EVIDENTLY_SERVICE_ADDRESS}/iterate/taxi", json=[record])
    
     
    
    
    