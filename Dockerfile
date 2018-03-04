FROM anapsix/alpine-java
MAINTAINER Jonas Gabriel "jonas.gbl@gmail.com"

RUN apk add --update curl git unzip python3 py-pip 
RUN pip install -U py4j

ENV SPARK_VERSION=2.3.0
ENV HADOOP_VERSION=2.7.5

RUN curl -sL --retry 3 \
 "http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" \
 | tar -xz -C /opt \
 && rm -rf /opt/hadoop-$HADOOP_VERSION/share/doc

RUN curl -sL --retry 3 \
  "http://mirrors.dotsrc.org/apache/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop2.7.tgz" \
  | tar -xz -C /opt \
  && rm -rf /opt/spark-$SPARK_VERSION-bin-without-hadoop/examples \
  && mv /opt/spark-$SPARK_VERSION-bin-hadoop2.7 /opt/spark-$SPARK_VERSION

ADD conf/spark-defaults.conf /opt/spark-$SPARK_VERSION/conf/
ADD conf/spark-env.sh /opt/spark-$SPARK_VERSION/conf/
ADD sbin/spark-daemon.sh     /opt/spark-$SPARK_VERSION/sbin/

ENV HADOOP_HOME=/opt/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop

ENV SPARK_HOME=/opt/spark-$SPARK_VERSION

ENV PYTHONHASHSEED=0
ENV PYTHONIOENCODING=UTF-8
ENV PYSPARK_PYTHON=python3

ENV PATH=$PATH:$HADOOP_HOME/bin
ENV	PATH=$PATH:$SPARK_HOME/bin
ENV	PATH=$PATH:$SPARK_HOME/sbin

ENV SPARK_MASTER_WEBUI_PORT=8080
ENV SPARK_WORKER_WEBUI_PORT=8081
ENV SPARK_MASTER_PORT=7077
ENV SPARK_WORKER_PORT=7078

#This is needed so the spark-daemon works in the foreground
ENV SPARK_NO_DAEMONIZE=1

EXPOSE $SPARK_MASTER_WEBUI_PORT $SPARK_WORKER_WEBUI_PORT $SPARK_MASTER_PORT $SPARK_WORKER_PORT

# Ports for spark.driver.port, spark.blockManager.port defined in spark-defaults.conf
EXPOSE 7070 7071 7080

# Used for publishing the Driver applicationn on the cluster
VOLUME /srv

WORKDIR $SPARK_HOME

CMD ["start-master.sh"]
