#!/usr/bin/env bash
set -euo pipefail

export HADOOP_HOME=/opt/hadoop
export HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
export PATH=$PATH:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin

RESET_HDFS="${RESET_HDFS:-0}"
HDFS_SUPERUSER="${HDFS_SUPERUSER:-hadoop}"
HDFS_CREATE_USER="${HDFS_CREATE_USER:-jovyan}"

NN_DIR="/data/hdfs/namenode"
DN_DIR="/data/hdfs/datanode"

run_as_hadoop() { su -s /bin/bash hadoop -c "$*"; }

echo "=== Hadoop single-node (HDFS+YARN) start ==="
echo "RESET_HDFS=${RESET_HDFS}"

if [ "${RESET_HDFS}" = "1" ]; then
  echo "[RESET] Wiping HDFS volumes..."
  rm -rf "${NN_DIR}/"* "${DN_DIR}/"*
fi

if [ ! -f "${NN_DIR}/current/VERSION" ]; then
  echo "[HDFS] Formatting NameNode..."
  run_as_hadoop "hdfs namenode -format -force -nonInteractive"
else
  echo "[HDFS] Existing NameNode metadata found. Skip format."
fi

echo "[HDFS] Starting NameNode + DataNode..."
run_as_hadoop "hdfs --daemon start namenode"
run_as_hadoop "hdfs --daemon start datanode"

echo "[YARN] Starting ResourceManager + NodeManager..."
run_as_hadoop "yarn --daemon start resourcemanager"
run_as_hadoop "yarn --daemon start nodemanager"

echo "[WAIT] NameNode RPC 9000..."
for i in {1..40}; do
  if nc -z localhost 9000; then
    echo "✅ NameNode RPC is up."
    break
  fi
  sleep 1
done

echo "[HDFS] Bootstrap dirs..."
run_as_hadoop "HADOOP_USER_NAME=${HDFS_SUPERUSER} hdfs dfs -mkdir -p /user/${HDFS_SUPERUSER} || true"
run_as_hadoop "HADOOP_USER_NAME=${HDFS_SUPERUSER} hdfs dfs -mkdir -p /user/${HDFS_CREATE_USER} || true"
run_as_hadoop "HADOOP_USER_NAME=${HDFS_SUPERUSER} hdfs dfs -chown -R ${HDFS_CREATE_USER}:supergroup /user/${HDFS_CREATE_USER} || true"
run_as_hadoop "HADOOP_USER_NAME=${HDFS_SUPERUSER} hdfs dfs -chmod -R 755 /user/${HDFS_CREATE_USER} || true"

run_as_hadoop "HADOOP_USER_NAME=${HDFS_SUPERUSER} hdfs dfs -mkdir -p /models || true"
run_as_hadoop "HADOOP_USER_NAME=${HDFS_SUPERUSER} hdfs dfs -chmod -R 777 /models || true"

echo "[STATUS] jps:"
run_as_hadoop "jps"

echo "=== Hadoop is running ==="
tail -f ${HADOOP_HOME}/logs/* 2>/dev/null || tail -f /dev/null
