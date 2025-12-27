#!/bin/sh

# detecta se esta na bateria ou na tomada
AC_STATE=$(acpi -a 2>/dev/null)

# modo atual
CURRENT_MODE=$(powerprofilesctl get 2>/dev/null)

echo "=============================="
echo " battery mode - linux"
echo "=============================="

if echo "$AC_STATE" | grep -qi off-line; then
    echo "energia: bateria"
    echo "modo atual: $CURRENT_MODE"

    if [ "$CURRENT_MODE" != "power-saver" ]; then
        echo
        printf "deseja ativar modo economia (power-saver)? [s/N]: "
        read ans
        if [ "$ans" = "s" ] || [ "$ans" = "S" ]; then
            powerprofilesctl set power-saver
            echo "modo economia ativado"
        else
            echo "modo mantido"
        fi
    fi
else
    echo "energia: tomada (AC)"
    echo "modo atual: $CURRENT_MODE"

    if [ "$CURRENT_MODE" = "power-saver" ]; then
        echo
        printf "deseja voltar para modo normal (balanced)? [s/N]: "
        read ans
        if [ "$ans" = "s" ] || [ "$ans" = "S" ]; then
            powerprofilesctl set balanced
            echo "modo normal ativado"
        else
            echo "modo mantido"
        fi
    fi
fi

echo "=============================="
