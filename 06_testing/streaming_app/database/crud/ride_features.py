

from fastapi.encoders import jsonable_encoder

# from common.logger import get_logger
from common.logger import get_logger
from common.models import ProcessedRide
from database.database import ride_features_table, database

logger = get_logger(__file__)

async def insert_processed_ride(processed_ride: ProcessedRide):
    # Flatten model structure and insert to DB
    try:
        logger.info(
            f"Inserting processed payment [{processed_ride.RIDE_ID}]..."
        )
        # Encode model values to serializable types
        encoded = jsonable_encoder(
            processed_ride.dict(exclude_none=True, exclude_unset=True),
        )
        query = processed_ride.insert().values(encoded)
        await database.execute(query)
    except Exception as e:
        logger.exception(str(e))
        raise e
    

async def get_ride_features():
    logger.info("Getting ride features...")
    query = ride_features_table.select()
    return await database.fetch_all(query=query)