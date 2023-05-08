#!/bin/bash
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]
then
    echo "Argumentos no válidos. Deben ser 4: Equipo Fichero Serv Port"
    exit 1
else
    while read lin; do
    echo $1 $lin
    done < $2  | nc -w 2 $3 $4
fi
