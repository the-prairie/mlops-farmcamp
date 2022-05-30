

*Make sure AWS CLI is installed*

```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

Check with `which aws` and `aws --version`


*Make sure AWS CLI is installed*


*Export env variables from .env file*
```bash
while read line; do export $line; done < .env
```

Check by running `echo $AWS_ACCESS_KEY_ID`


------------------------


ssh -i ".secrets/mlops.pem" ec2-user@ec2-15-222-242-133.ca-central-1.compute.amazonaws.com


mlflow server -h 0.0.0.0 -p 5000 --backend-store-uri postgresql://postgres:mlflowdb@mlflow-db.cqu5rpwhcjrf.ca-central-1.rds.amazonaws.com:5432/mlflow_db --default-artifact-root s3://mlflow-artifacts-b