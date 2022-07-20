import asyncio
import logging

from fastapi import FastAPI
import router

logging.basicConfig(level=logging.INFO)


app = FastAPI()

@app.get("/")
async def Home():
    return "welcome home"


app.include_router(router.route)
asyncio.create_task(router.consume())




# def prepare_features(ride):
#     features = {}
#     features["ROUTE"] = f'{str(ride["PULOCATIONID"])}_{str(ride["DOLOCATIONID"])}'
#     features["TRIP_DISTANCE"] = ride["TRIP_DISTANCE"]
#     return features
    
    
# def predict(features):
#     predictions = 10
    
#     return predictions
   

# def prediction_handler(event: dict, context: Context):
#     logging.info(f"""Function was triggered by messageId {context.event_id} published at {context.timestamps} to {context.resource["name"]}""")
    
#     # decode event
#     try:
#         ride = RideData.parse_event(event)
#     except ValidationError as err:
#         logging.error("Validation error", err=err)
#         raise err
#     logging.info(f"Resolved data: {ride}")
    
    
    # if "data" in event:
    #     data = base64.b64decode(event["data"]).decode("utf-8")
    #     ride = data["ride"]
    #     ride_id = data["RIDE_ID"]
    
    #     features = prepare_features(ride)
    #     prediction = predict(features)
    # else:
    #     logging.info("No data!")

    # return {
    #     "ride_duration": prediction,
    #     "ride_id": ride_id
    # } 
