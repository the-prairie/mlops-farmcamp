from databases import Database
from sqlalchemy import (
    Column,
    Integer,
    MetaData,
    String,
    Table,
    create_engine,
    Float,
    Text,
    Boolean,
)

from common.config import DATABASE_URL

engine = create_engine(DATABASE_URL)
database = Database(DATABASE_URL)
metadata = MetaData()



# Table for storing features
ride_features_table = Table(
    "ride_features",
    metadata,
    Column("ID", Integer, primary_key=True, autoincrement=True),
    Column(
        "RIDE_ID",
        String(36),  # 36 characters, 16-byte numbers (as hex), hyphenated
        index=True,
    ),
    Column(
        "POLOCATIONID",  # Pickup location ID
        String(3),  
        index=True,
    ),
    Column(
        "DOLOCATIONID",  # Drop off location ID
        String(3),  
        index=True,
    ),
    Column(
        "TRIP_ROUTE",  # Combination of PULocationID and DOLocationID
        String(10),  
        index=True,
    ),
    Column("TRIP_DISTANCE", Float, nullable=False),
    Column("PREDICTED_DURATION", Float, server_default=None)

)
