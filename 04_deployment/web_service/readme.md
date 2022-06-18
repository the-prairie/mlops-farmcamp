## Set up environment
---
pipenv install scikit-learn==1.1.1 flask fastapi "uvicorn[standard]" --python=3.9


##  Build docker image
---
Build and tag image
```
docker build -t fastpredict .   
```

Run container
```
docker run -d --name fastapi -p 9696:9696 fastpredict
```

Test sending request to endpoint 

```curl
curl -X 'POST' \
  'http://localhost:9696/predict' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "PULOCATIONID": 300,
  "DOLOCATIONID": 15,
  "TRIP_DISTANCE": 3840
}'
```