import pandas as pd
import pickle
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
        
    return run_date, train_date, val_date

@task(name="Read in parquet to dataframe")
def read_data(path):
    logger = get_run_logger()
    logger.info(f"Loading {path} into dataframe")
    df = pd.read_parquet(path)
    
    logger.info(f"Dataframe shape: {df.shape}")
    return df

@task(name="Prepare dataset features")
def prepare_features(df, categorical, train=True):
    logger = get_run_logger()
    logger.info("Calculating trip duration & preparing features")
    
    df['duration'] = df.dropOff_datetime - df.pickup_datetime
    df['duration'] = df.duration.dt.total_seconds() / 60
    df = df.loc[(df.duration >= 1) & (df.duration <= 60), :].copy()

    mean_duration = df.duration.mean()
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
    y_train = df.duration.values

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
    y_val = df.duration.values

    mse = mean_squared_error(y_val, y_pred, squared=False)
    logger.info(f"The MSE of validation is: {mse}")
    return

@task
def get_path(taxi_type, date):
    return f'data/{taxi_type}_tripdata_{date}.parquet'

@flow(task_runner=SequentialTaskRunner(), name="Train For Hire Vehicle High Volume model")
def main(taxi_type: str = 'fhvhv', 
         date: str = '2022-03-01' or pd.Timestamp.now().date().strftime('%Y-%m-%d')):
    
    # logger = get_run_logger()
    
    run_date, train_date, val_date = get_data(date=date, taxi_type=taxi_type).result()
    # logger.info(f"\n Run:{run_date}\n Training:{train_date}\n Validation:{val_date}")
    
    train_path = get_path(taxi_type, train_date)
    val_path = get_path(taxi_type, val_date)

    categorical = ['PUlocationID', 'DOlocationID']

    df_train = read_data(train_path)
    df_train_processed = prepare_features(df_train, categorical)
    
    df_val = read_data(val_path)
    df_val_processed = prepare_features(df_val, categorical)
    
    # train the model
    lr, dv = train_model(df_train_processed, categorical).result()
    run_model(df_val_processed, categorical, dv, lr)
    
    # save preprocessor
    with open(f"models/dv-{run_date}.pkl", "wb") as f_out:
        pickle.dump(dv, f_out)
    # save model
    with open(f"models/model-{run_date}.bin", "wb") as f_out:
        pickle.dump(lr, f_out)

   
main(date="2021-08-15", taxi_type="fhv")