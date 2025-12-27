FROM eclipse-temurin:11-jre-jammy

ARG HADOOP_VERSION=3.4.2
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
ENV PATH=${PATH}:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin

RUN apt-get update && apt-get install -y --no-install-recommends       curl ca-certificates bash tini procps netcat-openbsd     && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash hadoop

RUN curl -fsSL https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz     | tar -xz -C /opt  && ln -s /opt/hadoop-${HADOOP_VERSION} ${HADOOP_HOME}  && chown -R hadoop:hadoop /opt/hadoop-${HADOOP_VERSION}

RUN mkdir -p /data/hdfs/namenode /data/hdfs/datanode  && chown -R hadoop:hadoop /data/hdfs

COPY conf/*.xml ${HADOOP_CONF_DIR}/
COPY entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

EXPOSE 9870 9864 8088 8042 9000
ENTRYPOINT ["tini","-g","--","/opt/entrypoint.sh"]
