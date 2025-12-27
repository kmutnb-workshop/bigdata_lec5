#!/usr/bin/env bash
set -euo pipefail
export SPARK_HOME=/opt/spark
export PATH=$PATH:${SPARK_HOME}/bin:${SPARK_HOME}/sbin

: "${SPARK_MASTER_HOST:=spark-master}"
: "${SPARK_MASTER_PORT:=7077}"
: "${SPARK_MASTER_WEBUI_PORT:=8080}"

echo "=== Spark Master starting ==="
${SPARK_HOME}/sbin/start-master.sh   --host ${SPARK_MASTER_HOST}   --port ${SPARK_MASTER_PORT}   --webui-port ${SPARK_MASTER_WEBUI_PORT}

tail -f ${SPARK_HOME}/logs/* || tail -f /dev/null
