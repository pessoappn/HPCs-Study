#!/bin/bash

echo 'Iniciando Coletor dos Dados'

echo 'Informe o Tempo da Captura /s: (Ex.60 para 1m):'
read y

echo 'Informe o Intervalo de Captura dos Dados de HPCs/RAM/CPU/REDE /s: (Ex.10 para 10s):'
read h
x=$(expr $h \* 1000)
z=$(expr $y / 10)

echo 'Coletando os Dados: HPCs/RAM/CPU/REDE'
echo '...'

###

# Contadores de [Hardware Event] & [Hardware Event Cache] 4/4 (25 conts)

perf stat -o contador1.txt -e branch-instructions,branch-misses,bus-cycles,cache-misses,cache-references,cpu-cycles,instructions,ref-cycles -I $x -a -g -- sleep $y & perf stat -o contador2.txt -e L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,LLC-load-misses,LLC-loads -I $x -a -g -- sleep $y & perf stat -o contador3.txt -e LLC-store-misses,LLC-stores,branch-load-misses,branch-loads,dTLB-load-misses,dTLB-loads -I $x -a -g -- sleep $y & perf stat -o contador4.txt -e dTLB-store-misses,dTLB-stores,iTLB-load-misses,iTLB-loads,node-load-misses -I $x -a -g -- sleep $y & free -m -s $h -c $z | sed '1 d' | awk '{$1=""; print}' | sed "N;s/\n//" | sed -u '/a/d' | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9}' > RAM.txt & sar $h $z | sed '1,2 d'| sed '$ d' | awk '{$1="";$2=""; print}' | sed 's/\,/\./g' | awk '{print $1,$2,$3,$4,$5,$6}' > DadosCPU.txt & ifstat -i eno1 $h $z | sed -u '/eno1/d' | sed -u '/KB/d' | awk '{print $1,$2}' > REDE.txt

### Adicionando Header
sed -e '1i\' -e 'Total Used Free Shared Buff/Cache Avaliable TotalSwp UsedSwp FreeSwp' RAM.txt > DadosRAM.txt & sed -e '1i\' -e 'KBpsIn KBpsOut' REDE.txt > DadosREDE.txt


## Tratamento Dados HPC

sed -e '1,3d' < contador1.txt | sed -u '/time/d' | awk '{print $1}' | cut -s -d"." -f1 | awk '!x[$0]++' | tr -s '[:space:]' > time.txt | sed -e '1,3d' < contador1.txt | sed -u '/time/d' |  awk '{print $2}' | sed -e 'N;N;N;N;N;N;N;s/\n/ /g' | tr -s '[:space:]' > 1cont.txt | sed -e '1,3d' < contador2.txt | sed -u '/time/d' |  awk '{print $2}' | sed -e 'N;N;N;N;N;s/\n/ /g' | tr -s '[:space:]' > 2cont.txt |sed -e '1,3d' < contador3.txt | sed -u '/time/d' |  awk '{print $2}' | sed -e 'N;N;N;N;N;s/\n/ /g' | tr -s '[:space:]' > 3cont.txt | sed -e '1,3d' < contador4.txt | sed -u '/time/d' |  awk '{print $2}' | sed -e 'N;N;N;N;s/\n/ /g' |tr -s '[:space:]' > 4cont.txt && paste -d " " time.txt 1cont.txt 2cont.txt 3cont.txt 4cont.txt > allcont.txt && sed -e '1i\' -e 'Time branch-instructions branch-misses bus-cycles cache-misses cache-references cpu-cycles instructions ref-cycles L1-dcache-load-misses L1-dcache-loads L1-dcache-stores L1-icache-load-misses LLC-load-misses LLC-loads LLC-store-misses LLC-stores branch-load-misses branch-loads dTLB-load-misses dTLB-loads dTLB-store-misses dTLB-stores iTLB-load-misses iTLB-loads node-load-misses' allcont.txt > DadosHPC.txt

paste -d " " DadosHPC.txt DadosCPU.txt DadosRAM.txt DadosREDE.txt > AllColetores.txt

echo 'Captura dos Dados Finalizada!'
