#!/bin/bash
#Começa a interface wlan1 em modo monitor:
airmon-ng start wlan1
#Este laço bloqueia todos os IPs da rede 10.1.0.0/24 :
x=2
while [ "$x" -lt 254 ]
do
iptables -I INPUT -s "10.1.0.$x" -j DROP
iptables -I FORWARD -s "10.1.0.$x" -j DROP
x=$[$x+1]
done
echo "Todos os ips da rede estão bloqueados!"
#Este comando inicia o segundo script
./tcc2.sh
