FROM jupyter/base-notebook:python-3.11

USER root
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends       openjdk-17-jdk ca-certificates curl     && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

ARG SPARK_VERSION=4.0.1
ARG SPARK_TGZ=spark-${SPARK_VERSION}-bin-hadoop3-connect.tgz
ARG SPARK_URL=https://downloads.apache.org/spark/spark-${SPARK_VERSION}/${SPARK_TGZ}

ENV SPARK_HOME=/opt/spark
RUN curl -fsSL ${SPARK_URL} | tar -xz -C /opt  && mv /opt/spark-${SPARK_VERSION}-bin-hadoop3-connect ${SPARK_HOME}  && chown -R jovyan:users ${SPARK_HOME}

ENV PATH="${SPARK_HOME}/bin:${SPARK_HOME}/sbin:${PATH}"

RUN pip install --no-cache-dir --upgrade pip && pip install --no-cache-dir \
    pandas numpy matplotlib pyarrow pymysql sqlalchemy mysql-connector-python \
    boto3 s3fs minio findspark pyspark==4.0.1 \
    pymongo qdrant-client sentence-transformers pandas tqdm

COPY jupyterlab_entrypoint.sh /usr/local/bin/jupyterlab_entrypoint.sh
RUN chmod +x /usr/local/bin/jupyterlab_entrypoint.sh  && mkdir -p /opt/jupyter/work  && chown -R jovyan:users /opt/jupyter /home/jovyan

USER jovyan
WORKDIR /home/jovyan/work
EXPOSE 8888
ENTRYPOINT ["/usr/local/bin/jupyterlab_entrypoint.sh"]
