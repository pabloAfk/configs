#!/bin/bash

export DIALOGRC="$HOME/.dialogrc"

# precisa instalar o brightnessctl e o dialog
cat > "$DIALOGRC" << 'EOF'
screen_color = (WHITE,BLACK,ON)
shadow_color = (BLACK,BLACK,ON)
dialog_color = (WHITE,BLACK,ON)
title_color = (WHITE,BLACK,ON)
border_color = (WHITE,BLACK,ON)
button_active_color = (BLACK,WHITE,ON)
button_inactive_color = (WHITE,BLACK,ON)
button_key_active_color = (BLACK,WHITE,ON)
button_key_inactive_color = (WHITE,BLACK,ON)
EOF

LAST="1"  # começa em "aumentar"

while true; do
  BRIGHT=$(brightnessctl g)
  MAX=$(brightnessctl m)
  PERC=$((BRIGHT * 100 / MAX))

  CHOICE=$(dialog \
    --clear \
    --default-item "$LAST" \
    --menu "brilho: $PERC%" 12 40 4 \
    1 "aumentar" \
    2 "diminuir" \
    3 "sair" \
    3>&1 1>&2 2>&3)

  clear

  case "$CHOICE" in
    1)
      brightnessctl set +5%
      LAST="1"
      ;;
    2)
      brightnessctl set 5%-
      LAST="2"
      ;;
    3|*)
      exit 0
      ;;
  esac
done
