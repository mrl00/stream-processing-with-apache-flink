KAFKA_CONTAINER=kafka1

docker exec -it $KAFKA_CONTAINER kafka-topics --create --bootstrap-server "kafka1:19092,kafka2:19092,kafka3:19092" --replication-factor 3 --partitions 1 --topic transactions
docker exec -it $KAFKA_CONTAINER kafka-topics --create --bootstrap-server "kafka1:19092,kafka2:19092,kafka3:19092" --replication-factor 3 --partitions 1 --config cleanup.policy=compact --topic customers
docker exec -it $KAFKA_CONTAINER kafka-topics --create --bootstrap-server "kafka1:19092,kafka2:19092,kafka3:19092" --replication-factor 3 --partitions 1 --config cleanup.policy=compact --topic accounts
docker exec -it $KAFKA_CONTAINER kafka-topics --create --bootstrap-server "kafka1:19092,kafka2:19092,kafka3:19092" --replication-factor 3 --partitions 1 --topic transactions.debits
docker exec -it $KAFKA_CONTAINER kafka-topics --create --bootstrap-server "kafka1:19092,kafka2:19092,kafka3:19092" --replication-factor 3 --partitions 1 --topic transactions.credits
