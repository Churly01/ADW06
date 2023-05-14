#!/bin/bash

docker-compose up -d

docker exec mysql /createMonitor.sh

read -n 1 -p "Press key after logstash started"
./log-ingest/ingest.sh 2306 ./log-ingest/muestra.log localhost 50000 &

sleep 2
read -n 1 -p "Press key after ksqldb-server started"
docker exec -t ksqldb-cli ksql -f /apache_raw.ksql http://ksqldb-server:8088
docker exec -t ksqldb-cli ksql -f /connector_monitor.ksql http://ksqldb-server:8088
docker exec -t ksqldb-cli ksql -f /stream_monitor.ksql http://ksqldb-server:8088
docker exec -t ksqldb-cli ksql -f /stream_acceso.ksql http://ksqldb-server:8088
docker exec -t ksqldb-cli ksql -f /table_nacc.ksql http://ksqldb-server:8088
docker exec -t ksqldb-cli ksql -f /table_geoip.ksql http://ksqldb-server:8088
docker exec -t ksqldb-cli ksql -f /connector_geoip.ksql http://ksqldb-server:8088

read -n 1 -p "Press to launch queries"
trap '' 2
(trap - 2; exec docker exec -t ksqldb-cli ksql -f /q1.ksql http://ksqldb-server:8088)
(trap - 2; exec docker exec -t ksqldb-cli ksql -f /q2.ksql http://ksqldb-server:8088)
trap 2
