from prefect.deployments import DeploymentSpec, SubprocessFlowRunner
from prefect.orion.schemas.schedules import CronSchedule

DeploymentSpec(
    name="fhv-trip-duration-model",
    flow_location="./homework.py",
    parameters={'run_date':'Hello from my first deployment!'},
    tags=['ETL'],
    schedule = CronSchedule(cron="0 9 15 * *"),
    flow_runner=SubprocessFlowRunner()
)