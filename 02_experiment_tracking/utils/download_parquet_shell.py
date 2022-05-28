import argparse
import requests
import pyarrow.parquet as pq
import pyarrow as pa
import pandas as pd






def download_parquet(year_month, taxi_type="green", directory="data/"):
    url = f"https://s3.amazonaws.com/nyc-tlc/trip+data/{taxi_type}_tripdata_{year_month}.parquet"
    filename = url.split("/")[-1]

    try:
        result = requests.get(url)
    except requests.exceptions.HTTPError as e:
            print("ERROR ".center(90, "-"))
            print(e, file=sys.stderr)
            print("~~> file may not be available on server.")
    except requests.exceptions.RequestException as e:
            print(e, file=sys.stderr)
    
    # Save data to parquet file in local directory and return dataframe
    reader = pa.BufferReader(result.content)
    table = pq.read_table(reader)
    schema = []
    column_names = table.schema.names
    for col in column_names:
        column_type = table.schema.field(col).type
        if column_type in [pa.timestamp("us"), pa.timestamp("ns"), pa.timestamp("ms")]:
            column_type = pa.string()


        schema.append(pa.field(col, column_type))
    
    table = table.cast(pa.schema(schema))
    pq.write_table(table, f"{directory}{filename}")
    
def main(params):
    taxi_type = params.taxi_type
    start_date = params.start_yyyy_mm_dd
    end_date = params.end_yyyy_mm_dd

    data_months = list(pd.period_range(start=start_date, end=end_date, freq="M").astype(str))
    
    for ym in data_months:
        print(f"...Downloading {taxi_type} data for {ym}..\n")
        print("**********")
        download_parquet(year_month=ym, taxi_type=taxi_type)



if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Ingest parquet files from http site to local folders.")
    parser.add_argument('--start_yyyy_mm_dd', required=True)
    parser.add_argument('--end_yyyy_mm_dd', required=True)
    parser.add_argument('--taxi_type', required=True)

    args = parser.parse_args()


    main(args)