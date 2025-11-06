FROM flink:1.20

COPY ./jars/flink-connector-jdbc-3.3.0-1.20.jar /opt/flink/lib/
COPY ./jars/flink-connector-kafka-4.0.1-2.0.jar /opt/flink/lib/
COPY ./jars/flink-sql-connector-postgres-cdc-3.5.0.jar /opt/flink/lib/
COPY ./jars/postgresql-42.7.8.jar /opt/flink/lib/
