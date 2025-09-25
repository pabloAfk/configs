# .bashrc

# If not running interactively, don't do anything


#
# ~/.bashrc
#
#!/bin/bash

# Pasta das imagens
 folder=~/Imagens/noimg
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
# next_index=$(( (last_index + 1) % ${#imgs[@]} ))
echo $next_index > "$index_file"

# Mostra imagem com kitty
# kitty +kitten icat --place 20x100@0x0 "${imgs[$next_index]}"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'


 PS1='\W void '

# echo -e "\n\n\n\n\n\n\n\n\n\n" 
# echo -e "everyone is always connected."

[[ $- != *i* ]] && return

export XDG_DATA_DIRS="$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:/home/dystopia/.local/share/flatpak/exports/share"

alias rundoomiwadfreedoom='chocolate-doom -iwad ~/Games/doom/freedoom/freedoom-0.13.0/freedoom2.wad'
alias ls='ls --color=auto'
#PS1='[\u@\h \W]\$ '
alias prime-run='env __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia __VK_LAYER_NV_optimus=NVIDIA_only __GL_THREADED_OPTIMIZATIONS=1'
alias convert='magick convert'

alias uc='/opt/ungoogled-chromium/chrome --enable-features=NetworkService --user-data-dir=$HOME/.config/ungoogled-chromium'
alias edex='~/Apps/eDEX-UI-Linux-x86_64.AppImage'
alias um='unimatrix -b -s 93 -l CCCCp'

export DXVK_ENABLE_VULKAN=0
