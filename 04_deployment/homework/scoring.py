# %%
import pickle
import pandas as pd
import tempfile
import pathlib
from google.cloud import storage

from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter

# Parse command line arguments
parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
parser.add_argument("-y", "--year", default="2021", help="Calendar year")
parser.add_argument("-m", "--month", default="01", type=str, help="Calendar month")
parser.add_argument("-t", "--taxi_type", default="fhv", type=str, help="Taxi type to download data for.")
args = vars(parser.parse_args())


categorical = ['PUlocationID', 'DOlocationID']
TAXI_TYPE = "fhv"

def read_data(filename):
    df = pd.read_parquet(filename)
    
    df['duration'] = df.dropOff_datetime - df.pickup_datetime
    df['duration'] = df.duration.dt.total_seconds() / 60

    df = df[(df.duration >= 1) & (df.duration <= 60)].copy()

    df[categorical] = df[categorical].fillna(-1).astype('int').astype('str')
    
    return df

def upload_artifacts_gcs(bucket_name: str, df_result: pd.DataFrame):
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
        file = f"fhv_predictions_{year}_{month}.parquet"
        
        df_result.to_parquet(
        temp_path.joinpath(file),
        engine='pyarrow',
        compression=None,
        index=False)

        blob = bucket.blob(f"{TAXI_TYPE}/{file}")
        blob.upload_from_filename(temp_path.joinpath(file))
        
        print("File uploaded!")

def main(year, month):
    df = read_data(f'https://nyc-tlc.s3.amazonaws.com/trip+data/fhv_tripdata_{year}-{month}.parquet')
    
    with open("model.bin", "rb") as f_in:
        dv, lr = pickle.load(f_in)

    dicts = df[categorical].to_dict(orient='records')
    X_val = dv.transform(dicts)
    y_pred = lr.predict(X_val)
    
    print(f"Mean predicted ride duration for {year}-{month}: {y_pred.mean()}")

    df["ride_id"] = f"{year}/{month}_" + df.index.astype(str)
    df["predicted_duration"] = y_pred

    df_result = df.loc[:, ["ride_id", "predicted_duration"]]

    upload_artifacts_gcs(bucket_name="scoring-ml", df_result=df_result)
    
if __name__ == "__main__":
    year = args["year"]
    month = args["month"]
    main(year, month)
