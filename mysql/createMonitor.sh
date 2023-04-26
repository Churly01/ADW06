#!/bin/sh

until [ -S /var/run/mysqld/mysqld.sock ]
do
	sleep 1
done

while ! echo "source monitor.sql" | mysql -u kafka --password=kpwd23 -D kafka 1> /dev/null 2> /dev/null
do
	sleep 1
done
