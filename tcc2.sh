#!/bin/bash
dialog                                           \
   --title 'Parâmetro'                         \
   --inputbox 'Digite a potência Pré estabelecida:' 0 0  2>/tmp/potencia.txt

potenciaPre=$( cat /tmp/potencia.txt )
echo "Potencia Pré estabelecida: $potenciaPre" \
  




for((i=1;i==1;))
do
#Captura todos os IPs ativos da rede:
#O fato de colocar todo o comando entre 2 parênteses, é para que seja
#um vetor:
IPS=($(nmap -n -sP 10.1.0.0/24 | grep "10.1.0." | awk ' { print $5  }  '))
#Inicia-se a leitura do vetor com os IPS encontrados:
for IP in "${IPS[@]}"
do

if [ "$IP" != "10.1.0.1"  ]
then
potenciaDoIp=$( tcpdump -c 1 -e -i mon0 src host $IP | awk ' { print substr($7,2,2) }  ' )


echo "Potência do $IP é --> $potenciaDoIp"

if [[ "$IP" != "10.1.0.1" && "$potenciaDoIp" > "$potenciaPre" ]]
then
echo "O ip não é o gateway"
echo "Fora da distância predeterminada"
#O comando abaixo captura quantas entradas o IP possui
# na lista do iptables para a variável ocIP
ocIP=$(iptables -L | grep -wc $IP -i)
# O comando abaixo verifica se o número de entradas é igual a 0, se for, insere 2 entradas
for(( ; "$ocIP" == 0 ; ))
do
echo "Bloqueando o ip $IP ;"
iptables -I INPUT -s $IP -j DROP
iptables -I FORWARD -s $IP -j DROP
#O comando abaixo verifica quantas entradas o ip possui novamente no iptables:
ocIP=$(iptables -L | grep -wc $IP -i)
done
else

#O comando abaixo captura quantas entradas o IP possui
# na lista do iptables para a variável ocIP
ocIP=$(iptables -L | grep -wc $IP -i)
# O comando abaixo verifica se o número de entradas é maior que 0, se for, deleta todas entradas
for(( ; "$ocIP" > 0 ; ))
do
echo "O IP $IP está dentro da potência pré estabelecida"
echo "Deletando entradas no Iptables para o $IP "
echo "Desbloqueando $IP"
iptables -D INPUT -s $IP -j DROP
iptables -D FORWARD -s $IP -j DROP
#O comando abaixo verifica quantas entradas o ip possui novamente no iptables:
ocIP=$(iptables -L | grep -wc $IP -i)
done

fi
fi
done
done
