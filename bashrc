#
# ~/.bashrc
#
#!/bin/bash

# Pasta das imagens
folder=~/Imagens/bashimgs
index_file=~/.last_foto_index

# Lista imagens
imgs=($(find "$folder" -type f \( -iname "*.png" -o -iname "*.jpg" \) | sort))

# Último índice
if [ -f "$index_file" ]; then
    last_index=$(cat "$index_file")
else
    last_index=-1
fi

# Próximo índice
next_index=$(( (last_index + 1) % ${#imgs[@]} ))
echo $next_index > "$index_file"

# Mostra imagem com kitty
kitty +kitten icat --place 20x100@0x0 "${imgs[$next_index]}"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
echo -e "\n\n\n\n\n\n\n"
echo -e "everyone is always connected."
