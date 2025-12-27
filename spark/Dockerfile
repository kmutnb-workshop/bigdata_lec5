FROM eclipse-temurin:17-jre-jammy

ARG SPARK_VERSION=4.0.1
ARG SPARK_TGZ=spark-${SPARK_VERSION}-bin-hadoop3-connect.tgz
ARG SPARK_URL=https://downloads.apache.org/spark/spark-${SPARK_VERSION}/${SPARK_TGZ}

ARG HADOOP_AWS_VERSION=3.4.2
ARG AWS_SDK_BUNDLE=1.12.720

ENV SPARK_HOME=/opt/spark
ENV PATH=${PATH}:${SPARK_HOME}/bin:${SPARK_HOME}/sbin

RUN apt-get update && apt-get install -y --no-install-recommends       curl ca-certificates bash tini procps python3     && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL ${SPARK_URL} | tar -xz -C /opt  && mv /opt/spark-${SPARK_VERSION}-bin-hadoop3-connect ${SPARK_HOME}

RUN curl -fsSL https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_AWS_VERSION}/hadoop-aws-${HADOOP_AWS_VERSION}.jar       -o ${SPARK_HOME}/jars/hadoop-aws-${HADOOP_AWS_VERSION}.jar  && curl -fsSL https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_SDK_BUNDLE}/aws-java-sdk-bundle-${AWS_SDK_BUNDLE}.jar       -o ${SPARK_HOME}/jars/aws-java-sdk-bundle-${AWS_SDK_BUNDLE}.jar

COPY conf/spark-defaults.conf ${SPARK_HOME}/conf/spark-defaults.conf
COPY conf/log4j2.properties ${SPARK_HOME}/conf/log4j2.properties

COPY entrypoint-master.sh /opt/entrypoint-master.sh
COPY entrypoint-worker.sh /opt/entrypoint-worker.sh
RUN chmod +x /opt/entrypoint-*.sh

EXPOSE 7077 8080 8081
ENTRYPOINT ["tini","-g","--"]
CMD ["bash","-lc","sleep infinity"]
