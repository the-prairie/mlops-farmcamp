Download files from terminal command using `download_parquet_shell`:

Inputs:
--start_yyyy_mm_dd
--end_yyyy_mm_dd
--taxi_type

Outputs:
.parquet file saved into /data directory


```
python3 utils/download_parquet_shell.py --start_yyyy_mm_dd="2021-01-01" --end_yyyy_mm_dd="2021-03-01" --taxi_type="fhv"

```