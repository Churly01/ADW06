
/* APARTADO 2 DEL ENUNCIADO  */
/* Create a stream from the logstash topic */

/* No OLVIDAR*/
SET 'auto.offset.reset'='earliest';

/*Primero ejecutar lo siguiente ./ingest.sh 2306 muestra.log localhost 50000 */

/* CREATE STREAM FROM LOGSTASH  */
CREATE STREAM 2306_apache_raw (tag STRING, timestamp STRING, user_agent STRUCT<uaid STRING, device STRUCT<name STRING>, version STRING, original STRING, name STRING, os STRUCT<full_os STRING, version STRING, name STRING>>, url STRUCT<original STRING>, http STRUCT<response STRUCT<status_code INT, body STRUCT<bytes INT>>, request STRUCT<method STRING>, version STRING>, geoip STRUCT<ip STRING, geo STRUCT<country_name STRING, timezone STRING, country_iso_code STRING, location STRUCT<lon DOUBLE, lat DOUBLE>, continent_code STRING>, geo_as STRUCT<organization STRUCT<name STRING>, number INT>>) WITH (KAFKA_TOPIC='logstash', VALUE_FORMAT='JSON');

/* FILTER STREAM BY TAG  */
CREATE STREAM 2306_apache_filtered AS
SELECT * FROM 2306_apache_raw
WHERE tag = '2306'
AND geoip IS NOT NULL;

AND geoip.ip IS NOT NULL
AND geoip.geo IS NOT NULL
AND geoip.geo.country_name IS NOT NULL
AND geoip.geo.timezone IS NOT NULL
AND geoip.geo.country_iso_code IS NOT NULL
AND geoip.geo.location IS NOT NULL
AND geoip.geo.location.lon IS NOT NULL
AND geoip.geo.location.lat IS NOT NULL
AND geoip.geo.continent_code IS NOT NULL

/* SELECT ELEMENTS FROM STREAM*/

SELECT * FROM  2306_apache_filtered limit 1;

/* CREATE CONNECTOR TO MYSQL */
CREATE SOURCE CONNECTOR `2306-monitor-jdbc-source` WITH (
  'connector.class'='io.confluent.connect.jdbc.JdbcSourceConnector',
  'connection.url'='jdbc:mysql://mysql:3306/kafka',
  'connection.user' = 'kafka',
  'connection.password'='kpwd23',
  'mode'='incrementing',
  'incrementing.column.name'='idrt',
  'validate.non.null'='false',
  'topic.prefix'='adw.2306.',
  'table.whitelist'='monitor',
  'transforms' = 'createKey,extractInt',
  'transforms.createKey.type' = 'org.apache.kafka.connect.transforms.ValueToKey',
  'transforms.createKey.fields' = 'idrt',
  'transforms.extractInt.type' = 'org.apache.kafka.connect.transforms.ExtractField$Key',
  'transforms.extractInt.field' = 'idrt'
);

/* CREATE STREAM FROM MySQL DATA  */
CREATE STREAM 2306_monitor_stream (idrt INT, timestamp STRING, IP  STRING, UAID STRING, NV INT, UV STRING, rtreg TIMESTAMP) WITH (KAFKA_TOPIC='adw.2306.monitor', VALUE_FORMAT='AVRO');

/* APARTADO 3 DEL ENUNCIADO  */

