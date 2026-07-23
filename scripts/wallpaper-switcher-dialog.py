#!/bin/bash

# Define a configuração de cores do dialog
export DIALOGRC="$HOME/.dialogrc"

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

# Pasta onde ficam seus wallpapers
WALL_DIR="$HOME/Downloads"

# Entra na pasta dos wallpapers (encerra se a pasta não existir)
cd "$WALL_DIR" 2>/dev/null || { echo "Pasta $WALL_DIR não encontrada!"; exit 1; }

LAST="1"  # Começa na primeira opção por padrão

while true; do
  # Ativa o nullglob para evitar problemas se não houver imagens de extensão específica
  shopt -s nullglob
  FILES=(*.png *.jpg *.jpeg)
  shopt -u nullglob

  # Verifica se foram encontradas imagens
  if [ ${#FILES[@]} -eq 0 ]; then
    dialog --msgbox "Nenhuma imagem (.png, .jpg, .jpeg) encontrada em $WALL_DIR" 8 50
    clear
    exit 1
  fi

  # Monta o array de opções para o dialog
  # Exemplo: 1 "foto1.jpg" 2 "foto2.png" ...
  MENU_OPTIONS=()
  i=1
  for file in "${FILES[@]}"; do
    MENU_OPTIONS+=("$i" "$file")
    ((i++))
  done

  # Adiciona a opção de Sair no final do menu
  EXIT_NUM=$i
  MENU_OPTIONS+=("$EXIT_NUM" "Sair")

  # Exibe o menu
  CHOICE=$(dialog \
    --clear \
    --default-item "$LAST" \
    --menu "=== Selecione o Wallpaper ===" 18 60 10 \
    "${MENU_OPTIONS[@]}" \
    3>&1 1>&2 2>&3)

  # Trata o código de saída do dialog (se o usuário apertou ESC ou Cancelar)
  EXIT_CODE=$?
  if [ $EXIT_CODE -ne 0 ] || [ "$CHOICE" -eq "$EXIT_NUM" ]; then
    clear
    exit 0
  fi

  # Pega o nome do arquivo selecionado com base no índice (arrays no Bash são base-0, por isso ${FILES[$((CHOICE-1))]})
  SELECTED_FILE="${FILES[$((CHOICE-1))]}"

  # Aplica o wallpaper se o arquivo existir
  if [ -n "$SELECTED_FILE" ] && [ -f "$SELECTED_FILE" ]; then
    xwallpaper --zoom "$WALL_DIR/$SELECTED_FILE"
    LAST="$CHOICE"  # Guarda a última escolha para manter o cursor nela no próximo loop
  fi
done
