
### Deploy function
With function called `prediction_handler` in main.py

```
functions-framework --target prediction_handler  --debug
```

Test response:
```
curl -X POST localhost:8080 \
 -H "Content-Type:application/json" \
 -d '{ 
    "ride": {
        "PULOCATIONID": 130, 
        "DOLOCATIONID": 205, 
        "TRIP_DISTANCE": 3.66
        }, 
        "RIDE_ID": 123
    }'
```

### Create pub/sub topic

*gcloud pubsub topics create <TOPIC_NAME>*
```
gcloud pubsub topics create ride_events
```

### Deploy function
```
gcloud functions deploy prediction_handler \
--runtime python39 \
--trigger-topic ride_events
```

### Trigger function
Sending test data
```
gcloud pubsub topics publish ride_events --message "test test"
```

```
gcloud pubsub topics publish ride_events --message '{ 
    "ride": {
        "PULOCATIONID": 130, 
        "DOLOCATIONID": 205, 
        "TRIP_DISTANCE": 3.66
        }, 
        "RIDE_ID": 123
    }'
```


