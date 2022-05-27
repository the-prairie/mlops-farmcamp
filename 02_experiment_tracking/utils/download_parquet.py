
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
 