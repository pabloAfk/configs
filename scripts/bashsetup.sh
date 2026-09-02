#!/usr/bin/env bash

#1, dir de destino
BASHRC_D="$HOME/.bashrc.d"
BASHRC="$HOME/.bashrc"

echo "creating dir $BASHRC_D..."
mkdir -p "$BASHRC_D"

#2, putting "include" function on original .bashrc

INCLUDE_BLOCK='# load all the files from directory ~/.bashrc.d
if [ -d "$HOME/.bashrc.d" ]; then
	for file in "$HOME/.bashrc.d"/*.sh; do
		[ -r "$file" ] && source "$file"
	done
	unset file
	fi'

if ! grep -q '\.bashrc\.d' "$BASHRC" 2>/dev/nulll; then
	echo "" >> "$BASHRC"
	echo "$INCLUDE_BLOCK" >> "$BASHRC"
	echo " source automation added to your $BASHRC"
else
	echo " source config already exists in your $BASHRC"
fi

#3, create files with initial content/model

cat << 'EOF' > "$BASHRC_D/00-env.sh"

# ==========================================================
#                 00-env.sh - global envs
# ==========================================================

#               EDITORS

# export EDITOR="vim"
# export EDITOR="nvim"
# export EDITOR="nano"
# export EDITOR="micro"
# export EDITOR="mousepad"

#		PAGER

# export PAGER="less"


# export PATH="$HOME/.local/bin:$PATH"


EOF

cat << 'EOF' > "$BASHRC_D/10-aliases.sh"

# ==========================================================
# 	          10-aliases.sh - command shortcuts
# ==========================================================

# alias ll='ls -l'
# alias la='ls -a'
# alias lla='ls -la'
# alias ff='fastfetch'
# alias c='clear'
# alias e='exit'
# alias cf='clear && fastfetch'
# alias testdir='mkdir testdir && cd testdir'
# alias testfile='touch testfile && vim testfile'
# alias srcb='source ~/.bashrc'

EOF

cat << 'EOF' > "$BASHRC_D/20-functions.sh"

# ==========================================================
# 	        20-functions.sh
# ========================================================== 
#
# extract () {
#         if	        
