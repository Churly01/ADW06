#!/bin/sh

docker-compose up -d

docker exec mysql /createMonitor.sh

read -n 1 -p "Press key after logstash started"
./log-ingest/ingest.sh 2306 ./log-ingest/muestra.log localhost 50000 &

sleep 2
read -n 1 -p "Press key after ksqldb-server started"
docker exec ksqldb-cli ksql -f /server.ksql http://ksqldb-server:8088
sleep 1
#Haha no esperar a que se creen los topics goes brrrrrrrr
docker exec -t ksqldb-cli ksql -f /server.ksql http://ksqldb-server:8088
