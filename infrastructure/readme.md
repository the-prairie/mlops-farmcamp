** Bootstrapped / chopped n screwed from https://github.com/artefactory/one-click-mlflow ***


### Build docker image
----

[See container registry info here](https://cloud.google.com/container-registry/docs/pushing-and-pulling)

Tagging with version of mlflow being installed.

```bash
docker built -t mlflow:1.26.1 .
```

Tag your local image with registry name
```
docker tag mlflow:1.26.1 gcr.io/mlops00/mlflow:1.26.1
```

Push image to registry
```
docker push gcr.io/mlops00/mlflow:1.26.1
```