#!/bin/bash

# Pasta onde ficam seus wallpapers
WALL_DIR="$HOME/wallpapers/"

# Entra na pasta dos wallpapers (encerra se a pasta não existir)
cd "$WALL_DIR" 2>/dev/null || { echo "Pasta $WALL_DIR não encontrada!"; exit 1; }

# Ajusta o prompt do menu
PS3="Escolha seu wallpaper (ou Ctrl+C para sair): "

echo "=== Selecione o Wallpaper ==="

# Pega todos os arquivos .png, .jpg e .jpeg da pasta
select file in *.{png,jpg,jpeg}; do
    # Verifica se o usuário escolheu uma opção válida
    if [ -n "$file" ] && [ -f "$file" ]; then
        xwallpaper --zoom "$WALL_DIR/$file"
        echo "Wallpaper '$file' aplicado com sucesso!"
        break
    else
        echo "Opção inválida! Tente novamente."
    fi
done
