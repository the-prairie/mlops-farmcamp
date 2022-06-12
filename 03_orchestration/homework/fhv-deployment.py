from prefect.deployments import DeploymentSpec, SubprocessFlowRunner
import prefect
from prefect.orion.schemas.schedules import CronSchedule

DeploymentSpec(
    name="fhv-trip-duration-model",
    flow_location="./homework.py",
    parameters={
        "taxi_type":"fhv", 
        "bucket_name":"prefect-artifacts00",
        "run_date": "2021-08-15"
        },
    tags=["fhv"],
    schedule = CronSchedule(cron="0 9 15 * *"),
    flow_runner=SubprocessFlowRunner()
)