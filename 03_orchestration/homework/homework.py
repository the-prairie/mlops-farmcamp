import pandas as pd

from sklearn.feature_extraction import DictVectorizer
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error

from prefect import flow, task

from utils.download_data import download_parquet


@task
def get_data(date, taxi_type):
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

@task
def read_data(path):
    df = pd.read_parquet(path)
    return df

@task
def prepare_features(df, categorical, train=True):
    df['duration'] = df.dropoff_datetime - df.pickup_datetime
    df['duration'] = df.duration.dt.total_seconds() / 60
    df = df.loc[(df.duration >= 1) & (df.duration <= 60)]

    mean_duration = df.duration.mean()
    if train:
        print(f"The mean duration of training is {mean_duration}")
    else:
        print(f"The mean duration of validation is {mean_duration}")
    
    df[categorical] = df[categorical].fillna(-1).astype('int').astype('str')
    return df

@task
def train_model(df, categorical):

    train_dicts = df[categorical].to_dict(orient='records')
    dv = DictVectorizer()
    X_train = dv.fit_transform(train_dicts) 
    y_train = df.duration.values

    print(f"The shape of X_train is {X_train.shape}")
    print(f"The DictVectorizer has {len(dv.feature_names_)} features")

    lr = LinearRegression()
    lr.fit(X_train, y_train)
    y_pred = lr.predict(X_train)
    mse = mean_squared_error(y_train, y_pred, squared=False)
    print(f"The MSE of training is: {mse}")
    return lr, dv

@task
def run_model(df, categorical, dv, lr):
    val_dicts = df[categorical].to_dict(orient='records')
    X_val = dv.transform(val_dicts) 
    y_pred = lr.predict(X_val)
    y_val = df.duration.values

    mse = mean_squared_error(y_val, y_pred, squared=False)
    print(f"The MSE of validation is: {mse}")
    return

@flow(name="Train For Hire Vehicle High Volume model")
def main(taxi_type: str = 'fhvhv', 
         date: str = '2022-03-01' or pd.Timestamp.now().date().strftime('%Y-%m-%d')):
    
    run_date, train_date, val_date = get_data(date=date, taxi_type="fhvhv").result()
    
    train_path = f'data/{taxi_type}_tripdata_{train_date}.parquet'
    val_path = f'data/{taxi_type}_tripdata_{val_date}.parquet'

    categorical = ['PULocationID', 'DOLocationID']

    df_train = read_data(train_path)
    df_train_processed = prepare_features(df_train, categorical)

    df_val = read_data(val_path)
    df_val_processed = prepare_features(df_val, categorical, False)

    # train the model
    lr, dv = train_model(df_train_processed, categorical).result()
    run_model(df_val_processed, categorical, dv, lr)

main()