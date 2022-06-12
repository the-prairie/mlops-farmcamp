from inspect import Parameter
from numpy import source
import pandas as pd
import pickle
import tempfile
from google.cloud import storage
from typing import List
import requests
import pyarrow.parquet as pq
import pyarrow as pa
import pathlib

from sklearn.feature_extraction import DictVectorizer
from sklearn.linear_model import LinearRegression

from sklearn.metrics import mean_squared_error

from prefect import flow, task, get_run_logger
from prefect.task_runners import SequentialTaskRunner



def download_parquet(year_month: str, taxi_type="green", directory="data"):
    """ Download taxi dataset from NYC-TLC trip data website. Files are in parquet format.

    Args:
        year_month (str): Month to pull data for in format YYYY-MM
        taxi_type (str, optional): Taxi type to pull data for. Defaults to "green". Other options "yellow", "fhvhv", "fhv".
        directory (str, optional): Directory to save file to. Defaults to "data".
    """
    logger = get_run_logger()
    
    path = pathlib.Path(directory)
    path.mkdir(parents=True, exist_ok=True)
    
    url = f"https://s3.amazonaws.com/nyc-tlc/trip+data/{taxi_type}_tripdata_{year_month}.parquet"
    filename = url.split("/")[-1].replace("-","_")
    
    if path.joinpath(filename).is_file():
            logger.info(f"Skipping download as file already exists: {filename}")
    else:
        
        result = requests.get(url)
        try:
            result.raise_for_status()
        except requests.exceptions.HTTPError as e:
            logger.error(e)
            raise e
        except requests.exceptions.RequestException as e:
            logger.error(e)
            raise e
        
        # Save data to parquet file in local directory and return dataframe
        reader = pa.BufferReader(result.content)
        table = pq.read_table(reader)
        pq.write_table(table, f"{directory}/{filename}")
        
@task
def get_start_date(param_start_date: str) -> str:
    if param_start_date is None:
        param_start_date = pd.Timestamp.now().date().strftime('%Y-%m-%d')
    return param_start_date


@task(name="Download parquet data")
def get_data(date, taxi_type):
    logger = get_run_logger()
    
    run_date: str = date
    date_range = [d.strftime("%Y-%m") for d in pd.date_range(end=run_date, periods=3, freq="MS")]
    
    train_date = date_range[0]
    val_date = date_range[1]
    
    for dt in [train_date, val_date]:
        download_parquet(year_month=dt, taxi_type=taxi_type, directory="data")
        
    run_date = run_date.replace("-","_")
    train_date = train_date.replace("-","_")
    val_date = val_date.replace("-","_")
    logger.info(f"Run: {run_date}")
    logger.info(f"Training: {train_date}")
    logger.info(f"Validation: {val_date}")
        
    return run_date, train_date, val_date

@task(name="Read in parquet to dataframe")
def read_data(path):
    logger = get_run_logger()
    logger.info(f"Loading {path} into dataframe")
    df = pd.read_parquet(path)
    df.columns = df.columns.str.upper()
    
    logger.info(f"Dataframe shape: {df.shape}")
    return df

@task(name="Prepare dataset features")
def prepare_features(df, categorical, train=True):
    logger = get_run_logger()
    logger.info("Calculating trip duration & preparing features")
    
    df['DURATION'] = df["DROPOFF_DATETIME"]- df["PICKUP_DATETIME"]
    df['DURATION'] = df["DURATION"].dt.total_seconds() / 60
    df = df.loc[(df['DURATION'] >= 1) & (df['DURATION'] <= 60), :].copy()

    mean_duration = df['DURATION'].mean()
    if train:
        logger.info(f"The mean duration of training is {mean_duration}")
    else:
        logger.info(f"The mean duration of validation is {mean_duration}")
    
    df[categorical] = df[categorical].fillna(-1).astype('int').astype('str')
    return df

@task(name="Train model")
def train_model(df, categorical):
    logger = get_run_logger()
    logger.info("Training model")

    train_dicts = df[categorical].to_dict(orient='records')
    dv = DictVectorizer()
    X_train = dv.fit_transform(train_dicts) 
    y_train = df["DURATION"].values

    logger.info(f"The shape of X_train is {X_train.shape}")
    logger.info(f"The DictVectorizer has {len(dv.feature_names_)} features")

    lr = LinearRegression()
    lr.fit(X_train, y_train)
    y_pred = lr.predict(X_train)
    mse = mean_squared_error(y_train, y_pred, squared=False)
    logger.info(f"The MSE of training is: {mse}")
    
    return lr, dv

@task(name="Run model")
def run_model(df, categorical, dv, lr):
    logger = get_run_logger()
    logger.info("Running model")
    
    val_dicts = df[categorical].to_dict(orient='records')
    X_val = dv.transform(val_dicts) 
    y_pred = lr.predict(X_val)
    y_val = df["DURATION"].values

    mse = mean_squared_error(y_val, y_pred, squared=False)
    logger.info(f"The MSE of validation is: {mse}")
    return

@task
def get_path(taxi_type, date):
    return f'data/{taxi_type}_tripdata_{date}.parquet'

@task
def upload_artifacts_gcs(bucket_name: str, run_date: str, taxi_type: str, dv, lr):
    """Uploads file to gcs bucket

    Args:
        bucket_name (str): Name of gcs bucket
        source_files (List): List of path(s) of files to upload from local system
        destination_blob_name (str): Name of gcs storage object
    """
    with tempfile.TemporaryDirectory() as tmpdir:
        storage_client = storage.Client()
        bucket = storage_client.bucket(bucket_name)
        
        temp_path = pathlib.Path(tmpdir)
        with open(temp_path.joinpath(f"dv-{run_date}.pkl"), "wb") as f_out:
            pickle.dump(dv, f_out)
        with open(temp_path.joinpath(f"model-{run_date}.bin"), "wb") as f_out:
            pickle.dump(lr, f_out)
        
        for file in temp_path.iterdir():
            blob = bucket.blob(f"{taxi_type}/{file.name}")
            blob.upload_from_filename(file)
    

@flow(task_runner=SequentialTaskRunner(), name="train_ride_duration_model")
def main(taxi_type: str,
         bucket_name: str,
         run_date: str):
    
    run_date = get_start_date(run_date)
    
    # logger = get_run_logger()
    
    run_date, train_date, val_date = get_data(date=run_date, taxi_type=taxi_type).result()
    
    
    train_path = get_path(taxi_type, train_date)
    val_path = get_path(taxi_type, val_date)

    categorical = ['PULOCATIONID', 'DOLOCATIONID']

    df_train = read_data(train_path)
    df_train_processed = prepare_features(df_train, categorical)
    
    df_val = read_data(val_path)
    df_val_processed = prepare_features(df_val, categorical)
    
    # train the model
    lr, dv = train_model(df_train_processed, categorical).result()
    run_model(df_val_processed, categorical, dv, lr)
    
    # save artifacts to GCS
    upload_artifacts_gcs(bucket_name, run_date, taxi_type, dv, lr)