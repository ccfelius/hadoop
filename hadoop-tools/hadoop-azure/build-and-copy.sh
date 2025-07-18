#!/bin/bash

# Exit immediately if a command fails
set -e

# Define variables
JAR_NAME=hadoop-azure-3.3.6.jar
JAR_PATH=/home/t-lofelius/repo/hadoop/hadoop-tools/hadoop-azure/target/$JAR_NAME
BACKUP_DIR=/home/t-lofelius/spark-abfs-jars

# Build the custom Hadoop JAR
echo "🔧 Building Hadoop Azure JAR..."
mvn clean package -DskipTests

# Verify build success
if [ ! -f "$JAR_PATH" ]; then
  echo "❌ Build failed: $JAR_NAME not found at $JAR_PATH"
  exit 1
fi

# Copy the JAR to backup location
echo "📦 Copying JAR to backup folder: $BACKUP_DIR"
cp "$JAR_PATH" "$BACKUP_DIR"

# Copy the JAR to Spark
echo "🚀 Deploying JAR to Spark: $SPARK_HOME/jars/"
cp "$JAR_PATH" "$SPARK_HOME/jars/"

# Copy the JAR to Hadoop
echo "🚀 Deploying JAR to Hadoop: $HADOOP_HOME/share/hadoop/common/lib/"
cp "$JAR_PATH" "$HADOOP_HOME/share/hadoop/common/lib/"


WORKERS_FILE="$HOME/spark/conf/workers"

# Loop through each worker and copy the JAR
while read -r WORKER; do
  echo "📡 Copying JAR to worker node: $WORKER"

  # Copy to Spark jars directory
  scp "$JAR_PATH" "$WORKER:$SPARK_HOME/jars/"

  # Copy to Hadoop common lib directory
  scp "$JAR_PATH" "$WORKER:$HADOOP_HOME/share/hadoop/common/lib/"
done < "$WORKERS_FILE"

echo "✅ JAR deployed to all worker nodes."


echo "✅ Deployment complete: $JAR_NAME is now available to Spark and Hadoop."

