#!/bin/bash

echo "=== calculadora de farm (dress to impress) ==="
echo

read -p "moedas atuais: " atual
read -p "meta de moedas: " meta

if [ "$atual" -ge "$meta" ]; then
  echo
  echo "ja atingiu ou passou da meta"
  exit 0
fi

echo
echo "escolha o modo:"
echo "1) automatico"
echo "2) manual (benchmark de 1 minuto)"
read -p "> " modo

case $modo in
  1)
    echo
    echo "tipo de servidor:"
    echo "1) muito ruim (15 moedas/min)"
    echo "2) ruim (25 moedas/min)"
    echo "3) bom (35 moedas/min)"
    echo "4) muito bom (50 moedas/min)"
    read -p "> " servidor

    case $servidor in
      1) taxa=15 ;;
      2) taxa=25 ;;
      3) taxa=35 ;;
      4) taxa=50 ;;
      *)
        echo "opcao invalida"
        exit 1
        ;;
    esac
    ;;
    
  2)
    echo
    echo "farme por 1 minuto"
    read -p "quantas moedas ganhou nesse minuto? " taxa

    if [ "$taxa" -le 0 ]; then
      echo "valor invalido"
      exit 1
    fi
    ;;
    
  *)
    echo "modo invalido"
    exit 1
    ;;
esac

faltam=$((meta - atual))
minutos=$(echo "scale=2; $faltam / $taxa" | bc)

horas_int=$(echo "$minutos / 60" | bc | cut -d. -f1)
min_rest=$(echo "$minutos - ($horas_int * 60)" | bc | cut -d. -f1)

echo
echo "faltam $faltam moedas"
echo "taxa usada: $taxa moedas/min"
echo "tempo estimado:"
echo "- $minutos minutos"
echo "- aproximadamente ${horas_int}h ${min_rest}min"
