FROM gcr.io/getindata-images-public/mlflow:1.22.0
ENV TINI_VERSION v0.19.0


RUN apt update && apt install -y curl netcat && mkdir -p /oauth2-proxy && cd /oauth2-proxy && \
    curl -L -o proxy.tar.gz https://github.com/oauth2-proxy/oauth2-proxy/releases/download/v6.1.1/oauth2-proxy-v6.1.1.linux-amd64.tar.gz && \
    tar -xzf proxy.tar.gz && mv oauth2-proxy-*.linux-amd64/oauth2-proxy . && rm proxy.tar.gz && \
    rm -rf /var/lib/apt/lists/*

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

COPY start.sh start.sh
RUN chmod +x start.sh

ENTRYPOINT ["/tini", "--", "./start.sh"]