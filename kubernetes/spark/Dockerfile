FROM gcr.io/spark-operator/spark-py:v3.0.0

# using root
USER root:root

# create directory for applications
RUN mkdir -p /app

# copy jars files
COPY ./jars/ /opt/spark/jars

# copy spark program
COPY spark-operator-processing-job-batch.py /app/

# set main work directory
WORKDIR /app

# user
USER root