#!/usr/bin/env bash
set -euo pipefail
export SPARK_HOME=/opt/spark
export PATH=$PATH:${SPARK_HOME}/bin:${SPARK_HOME}/sbin

: "${SPARK_MASTER_URL:=spark://spark-master:7077}"
: "${SPARK_WORKER_WEBUI_PORT:=8081}"

echo "=== Spark Worker starting ==="
${SPARK_HOME}/sbin/start-worker.sh   --webui-port ${SPARK_WORKER_WEBUI_PORT}   ${SPARK_MASTER_URL}

tail -f ${SPARK_HOME}/logs/* || tail -f /dev/null
