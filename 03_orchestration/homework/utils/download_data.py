
import requests
import pyarrow.parquet as pq
import pyarrow as pa
import logging
import pathlib

logger = logging.Logger("download_data")

def download_parquet(year_month: str, taxi_type="green", directory="data"):
    """ Download taxi dataset from NYC-TLC trip data website. Files are in parquet format.

    Args:
        year_month (str): Month to pull data for in format YYYY-MM
        taxi_type (str, optional): Taxi type to pull data for. Defaults to "green". Other options "yellow", "fhvhv", "fhv".
        directory (str, optional): Directory to save file to. Defaults to "data".
    """
    
    path = pathlib.Path(directory)
    path.mkdir(parents=True, exist_ok=True)
    
    url = f"https://s3.amazonaws.com/nyc-tlc/trip+data/{taxi_type}_tripdata_{year_month}.parquet"
    filename = url.split("/")[-1].replace("-","_")
    
    if path.joinpath(filename).is_file():
            print(f"Skipping download as file already exists: {filename}")
    else:
        
        result = requests.get(url)
        try:
            result.raise_for_status()
        except requests.exceptions.HTTPError as e:
            logger.log(logging.ERROR, e)
            raise e
        except requests.exceptions.RequestException as e:
            logger.log(logging.ERROR, e)
            raise e
        
        # Save data to parquet file in local directory and return dataframe
        reader = pa.BufferReader(result.content)
        table = pq.read_table(reader)
        pq.write_table(table, f"{directory}/{filename}")