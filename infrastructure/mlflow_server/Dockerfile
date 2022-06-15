FROM google/cloud-sdk:332.0.0

WORKDIR /mlflow/

RUN mkdir -p /mlflow/ \
  && apt-get update --allow-releaseinfo-change\
  && apt-get -y install --no-install-recommends apt-transport-https \
  ca-certificates gnupg default-libmysqlclient-dev libpq-dev build-essential curl

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY run_tracking.sh .
RUN chmod +x run_tracking.sh

CMD /mlflow/run_tracking.sh