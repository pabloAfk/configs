#!/bin/sh

HORA=$(date "+%d/%m/%Y - %H:%M:%S")

BAT_PERCENT=$(sysctl -n hw.acpi.battery.life 2>/dev/null)
BAT_STATE=$(sysctl -n hw.acpi.battery.state 2>/dev/null)

case "$BAT_STATE" in
0) BAT_STATUS="carregando" ;;
1) BAT_STATUS="na_bateria" ;;
2) BAT_STATUS="carregado" ;;
*) BAT_STATUS="desconhecido" ;;
esac

echo "=============================="
echo " sysinfo FreeBSD - made by Dys"
echo "=============================="
echo "hora_atual: $HORA"

if [ -n "$BAT_PERCENT" ]; then
    echo "bateria: ${BAT_PERCENT}% - ${BAT_STATUS}"
else
    echo "bateria: nao_detectada"
fi

echo "=============================="

