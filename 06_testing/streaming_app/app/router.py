from fastapi import APIRouter
from models import RideData
from config import loop, KAFKA_BOOTSTRAP_SERVERS, KAFKA_CONSUMER_GROUP, KAFKA_TOPIC

from aiokafka import AIOKafkaProducer, AIOKafkaConsumer
import asyncio
import json

route = APIRouter()

@route.post("/create_ride")
async def send(ride: RideData):
    producer = AIOKafkaProducer(loop=loop, bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS)
    await producer.start()
    try:
        # Product message
        print(f"Ride received: {ride.dict()}")
        value_json = json.dumps(ride.dict()).encode("utf-8")
        await producer.send_and_wait(topic=KAFKA_TOPIC, value=value_json)
    finally:
        # Wait for all pending messages to be delivered or expire
        await producer.stop()
  
@route.post("/prediction")        
async def consume():
    consumer = AIOKafkaConsumer(KAFKA_TOPIC, loop=loop, bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS, group_id=KAFKA_CONSUMER_GROUP)
    await consumer.start()
    try:
        async for msg in consumer:
            print(f"Consumer message: {msg}")
            serialized_message = json.loads(msg.value)
            features = prepare_features(serialized_message.get("ride"))
            prediction = predict(features)
            print(serialized_message.get("ride_id"))
            return {
                    "prediction": prediction,
                    "ride_id": serialized_message.get("ride_id")
                    }
    finally:
        await consumer.stop()
        
        
def prepare_features(ride):
    features = {}
    features["ROUTE"] = f'{str(ride["PULOCATIONID"])}_{str(ride["DOLOCATIONID"])}'
    features["TRIP_DISTANCE"] = ride["TRIP_DISTANCE"]
    return features

    
def predict(features):
    predictions = 10
    return predictions
    