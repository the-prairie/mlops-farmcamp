import asyncio
import json
from operator import mod
import pickle
from concurrent.futures import ThreadPoolExecutor

from aiokafka import AIOKafkaConsumer

import database.crud.ride_features as ride_features_crud
from common.config import KAFKA_BOOTSTRAP_SERVERS, KAFKA_CONSUMER_GROUP, KAFKA_TOPIC, LOGGED_MODEL
from common.logger import get_logger
from common.models import ProcessedRide
from database.database import database
from prediction_service.prediction_model import LRPredictionModel, AbstractPredictionModel

logger = get_logger(__name__)

with open(LOGGED_MODEL, 'rb') as f_in:
    dv, model = pickle.load(f_in)
   

def init_stream_consumer() -> AIOKafkaConsumer:
    """ Initializes and returns the stream consumer """
    logger.info("Initializing stream consumer...")
    return AIOKafkaConsumer(
        KAFKA_TOPIC,
        bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS,
        group_id=KAFKA_CONSUMER_GROUP,
        auto_offset_reset="earliest",
        auto_commit_interval_ms=1000,
        value_deserializer=lambda m: json.loads(m.decode("utf-8")),
    )


def init_model() -> AbstractPredictionModel:
    """ Initializes and returns model """
    logger.info("Initializing ML model...")
    return LRPredictionModel(
        dv=dv,
        model=model
    )
    


async def main():
    loop = asyncio.get_event_loop()
    executor = ThreadPoolExecutor(max_workers=1)

    prediction_model = init_model()
    consumer = init_stream_consumer()

    # Establish database connection and start consumer
    await database.connect()
    await consumer.start()

    try:
        logger.info("Consuming messages...")
        # Then processes them using the risk engine
        async for message in consumer:
            processed_ride = await loop.run_in_executor(
                executor, prediction_model.process, ProcessedRide(**message.value)
            )
            # Insert processed payment to database
            await ride_features_crud.insert_processed_ride(
                processed_ride=processed_ride
            )
    except Exception as e:
        logger.exception(f"Exception: {e}")

    finally:
        logger.info("Stopping consumer and disconnecting from database gracefully...")
        await consumer.stop()
        await database.disconnect()


if __name__ == "__main__":
    """
    This is the entry point to the RiskEngine service, this service consumes a Kafka stream, applies the RiskEngine
    logic and writes its processed results to a database.
    This service handles 2 different types of workload:
    1) CPU/GPU bound RiskEngine (Basically non IO related work)
    2) IO bound writing results to DB
    We will start an event loop in its own thread and offload the second type of workload to this thread
    """
    asyncio.run(main())