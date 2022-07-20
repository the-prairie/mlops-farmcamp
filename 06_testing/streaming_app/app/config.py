from os import environ
from pathlib import Path
import asyncio

ROOT_DIR = Path(__file__).parent.parent.absolute()

# Environment variables

# Kafka configuration
KAFKA_TOPIC = environ.get("KAFKA_TOPIC", "rides")
KAFKA_HOST: str = environ.get("KAFKA_HOST", "localhost")
KAFKA_PORT: str = environ.get("KAFKA_PORT", 9093)
KAFKA_BOOTSTRAP_SERVERS=f"{KAFKA_HOST}:{KAFKA_PORT}"
KAFKA_CONSUMER_GROUP = environ.get("KAFKA_CONSUMER_GROUP", "group")


# Postgres configuration
POSTGRES_USERNAME = environ.get("POSTGRES_USERNAME", "docker")
POSTGRES_PASSWORD = environ.get("POSTGRES_PASSWORD", "docker")
POSTGRES_HOST = environ.get("POSTGRES_HOST", "localhost")
POSTGRES_PORT = environ.get("POSTGRES_PORT", 5432)
DATABASE_URL = f"postgresql://{POSTGRES_USERNAME}:{POSTGRES_PASSWORD}@{POSTGRES_HOST}:{POSTGRES_PORT}/taxi_rides"

loop = asyncio.get_event_loop()