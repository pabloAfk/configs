slack cat Lanis.sh
#!/bin/bash

TITLE="Lanis - documentação viva"
VERSION="1.4"

declare -A DATA

#################
# === DISTROS ===
#################

DATA["distros"]="slackware debian arch"

DATA["distros.slackware"]="atualizacao mirrors pacotes"

DATA["distros.slackware.atualizacao"]=$'############ ATUALIZAÇÃO NO SLACKWARE ############\n\n--- atualizar sistema ---\n\nslackpkg update\nslackpkg install-new\nslackpkg upgrade-all\nslackpkg clean-system\n\n--- gerar initrd (kernel generic) ---\n\n/usr/share/mkinitrd/mkinitrd_command_generator.sh\n\n(gera o comando automaticamente baseado no teu sistema)\n\n--- copiar kernel pra ESP ---\n\ncp /boot/vmlinuz-generic /boot/efi/EFI/Slackware/vmlinuz\ncp /boot/initrd-generic.img /boot/efi/EFI/Slackware/initrd.gz\n\n--- atualizar grub ---\n\ngrub-mkconfig -o /boot/efi/EFI/Slackware/grub/grub.cfg\n\n--- verificar se kernel mudou ---\n\nuname -r\nls /lib/modules\n\n(se aparecer versão diferente, kernel foi atualizado sim)'

DATA["distros.slackware.mirrors"]=$'Mirrors usados:\n\n- https://slackware.nl/slackware/slackware64-current/\n- https://slackware.nl/slackware/slackware64-15.0/'

DATA["distros.slackware.pacotes"]=$'############ PACOTES NO SLACKWARE ############\n\n--- slackpkg ---\n\nGerenciador oficial.\n\nslackpkg update\nslackpkg install-new\nslackpkg upgrade-all\nslackpkg clean-system\n\n--- sbopkg ---\n\nInterface para SlackBuilds.\n\nsbopkg\nsbopkg -r\nsbopkg -i pacote\n\n--- slackpkg+ ---\n\nmais pacotes pro slackpkg\n\nSite:\nhttps://slakfinder.org/slackpkg+.html\n\nConfig:\n/etc/slackpkg/slackpkgplus.conf\n\n( TROCA A VERSÃO DO SLACKWARE NOS MIRRORS )\n\nMirrors descomentados:\n- multilib\n- alienbob\n- slackonly\n\npkgs_priority:\n- alienbob\n- multilib\n\nRepo do alienbob:\nhttps://slackware.nl/people/alien/\n\nNOTA: LER O CHANGELOG AO MEXER COM SLACKONLY'
###########################################################

DATA["distros.debian"]="atualizacao"

DATA["distros.debian.atualizacao"]=$'sudo apt update\n\nsudo apt upgrade\n\npode ser diário ou semanal'
###########################################################
DATA["distros.arch"]="yay"
DATA["distros.arch.yay"]='- Atualize seu sistema e instale as dependências necessárias:\n
sudo pacman -Syu --needed base-devel git
\n\n
- Clone o repositório do YAY:\n
git clone https://aur.archlinux.org/yay.git
\n\n
- Acesse o diretório clonado:
\ncd yay
\n\n
- Compile e instale o YAY:\n
makepkg -si
\n\n
- Verifique a instalação:\n
yay --version'

#####################
# === LINUX GERAL ===
#####################

DATA["linux"]="initramfs grub systemd permissoes boot_process"

DATA["linux.initramfs"]=$'Initramfs:\n\nSistema de arquivos temporário carregado pelo bootloader.\nServe para montar o root real e carregar módulos.'
DATA["linux.grub"]=$'GRUB:\n\nBootloader mais comum.\nConfig principal: /etc/default/grub\nGerar config: grub-mkconfig -o /boot/grub/grub.cfg'
DATA["linux.systemd"]=$'systemd:\n\ninit system moderno.\nComandos:\nsystemctl start|stop|enable|status'
DATA["linux.permissoes"]=$'Permissões:\n\nrwx = 4 2 1\nchmod\nchown\numask'
DATA["linux.boot_process"]=$'Boot process:\n\nBIOS/UEFI → Bootloader → Kernel → Initramfs → init/systemd → userspace'

########################
# === FERRAMENTAS ===
########################

DATA["ferramentas"]="nmap git ssh tmux"

DATA["ferramentas.nmap"]=$'Nmap:\n\nScanner de rede.\nEx:\nnmap -sS -sV -A alvo'
DATA["ferramentas.git"]=$'Git:\n\nControle de versão.\ngit clone\ngit pull\ngit commit -m'
DATA["ferramentas.ssh"]=$'SSH:\n\nAcesso remoto seguro.\nssh user@host'
DATA["ferramentas.tmux"]=$'Tmux:\n\nMultiplexador de terminal.\ntmux\nCtrl+b c / % / "'

#############################
# ===== INTERFACE UI ===== #
#############################

welcome() {
  dialog --backtitle "$TITLE" \
         --title "Lanis" \
         --msgbox "oi, eu sou a Lanis\n\nteu cérebro linux offline\n\nusa as setas e enter pra navegar\n\nversão $VERSION" \
         12 60
}

main_menu() {
  while true; do
    choice=$(dialog --backtitle "$TITLE" \
      --title "menu principal" \
      --cancel-label "sair" \
      --menu "escolhe uma categoria:" \
      15 60 10 \
      "distros" "distribuições linux" \
      "linux" "conceitos gerais" \
      "ferramentas" "comandos e tools" \
      "sobre" "sobre a lanis" \
      3>&1 1>&2 2>&3)

    [ $? -ne 0 ] && exit_script

    case "$choice" in
      distros|linux|ferramentas)
        category_menu "$choice"
        ;;
      sobre)
        about
        ;;
    esac
  done
}

category_menu() {
  local category="$1"
  local items="${DATA[$category]}"

  while true; do
    local options=()
    for i in $items; do
      options+=("$i" "")
    done

    options+=("<< voltar" "menu principal")

    choice=$(dialog --backtitle "$TITLE" \
      --title "$category" \
      --menu "escolhe:" \
      20 60 12 \
      "${options[@]}" \
      3>&1 1>&2 2>&3)

    [ $? -ne 0 ] && exit_script
    [ "$choice" = "<< voltar" ] && return

    subcategory_menu "$category" "$choice"
  done
}

subcategory_menu() {
  local category="$1"
  local item="$2"
  local base_key="$category.$item"

  local has_children=0
  for k in "${!DATA[@]}"; do
    [[ "$k" == "$base_key."* ]] && has_children=1
  done

  if [ "$has_children" -eq 0 ]; then
    show_text "$base_key"
    return
  fi

  local subs="${DATA[$base_key]}"

  while true; do
    local options=()
    for s in $subs; do
      options+=("$s" "")
    done

    options+=("<< voltar" "$category")

    choice=$(dialog --backtitle "$TITLE" \
      --title "$category → $item" \
      --menu "escolhe:" \
      20 70 12 \
      "${options[@]}" \
      3>&1 1>&2 2>&3)

    [ $? -ne 0 ] && exit_script
    [ "$choice" = "<< voltar" ] && return

    show_text "$base_key.$choice"
  done
}

show_text() {
  local key="$1"
  local text="${DATA[$key]}"

  dialog --backtitle "$TITLE" \
         --title "$key" \
         --extra-button --extra-label "voltar" \
         --ok-label "menu principal" \
         --msgbox "$text" \
         20 75

  case $? in
    3) return ;;
    0) exit_script ;;
  esac
}

about() {
  dialog --backtitle "$TITLE" \
         --title "sobre" \
slack cat Lanis.sh
#!/bin/bash

TITLE="Lanis - documentação viva"
VERSION="1.4"

declare -A DATA

#################
# === DISTROS ===
#################

DATA["distros"]="slackware debian arch"

DATA["distros.slackware"]="atualizacao mirrors pacotes"

DATA["distros.slackware.atualizacao"]=$'############ ATUALIZAÇÃO NO SLACKWARE ############\n\n--- atualizar sistema ---\n\nslackpkg update\nslackpkg install-new\nslackpkg upgrade-all\nslackpkg clean-system\n\n--- gerar initrd (kernel generic) ---\n\n/usr/share/mkinitrd/mkinitrd_command_generator.sh\n\n(gera o comando automaticamente baseado no teu sistema)\n\n--- copiar kernel pra ESP ---\n\ncp /boot/vmlinuz-generic /boot/efi/EFI/Slackware/vmlinuz\ncp /boot/initrd-generic.img /boot/efi/EFI/Slackware/initrd.gz\n\n--- atualizar grub ---\n\ngrub-mkconfig -o /boot/efi/EFI/Slackware/grub/grub.cfg\n\n--- verificar se kernel mudou ---\n\nuname -r\nls /lib/modules\n\n(se aparecer versão diferente, kernel foi atualizado sim)'

DATA["distros.slackware.mirrors"]=$'Mirrors usados:\n\n- https://slackware.nl/slackware/slackware64-current/\n- https://slackware.nl/slackware/slackware64-15.0/'

DATA["distros.slackware.pacotes"]=$'############ PACOTES NO SLACKWARE ############\n\n--- slackpkg ---\n\nGerenciador oficial.\n\nslackpkg update\nslackpkg install-new\nslackpkg upgrade-all\nslackpkg clean-system\n\n--- sbopkg ---\n\nInterface para SlackBuilds.\n\nsbopkg\nsbopkg -r\nsbopkg -i pacote\n\n--- slackpkg+ ---\n\nmais pacotes pro slackpkg\n\nSite:\nhttps://slakfinder.org/slackpkg+.html\n\nConfig:\n/etc/slackpkg/slackpkgplus.conf\n\n( TROCA A VERSÃO DO SLACKWARE NOS MIRRORS )\n\nMirrors descomentados:\n- multilib\n- alienbob\n- slackonly\n\npkgs_priority:\n- alienbob\n- multilib\n\nRepo do alienbob:\nhttps://slackware.nl/people/alien/\n\nNOTA: LER O CHANGELOG AO MEXER COM SLACKONLY'
###########################################################

DATA["distros.debian"]="atualizacao"

DATA["distros.debian.atualizacao"]=$'sudo apt update\n\nsudo apt upgrade\n\npode ser diário ou semanal'
###########################################################
DATA["distros.arch"]="yay"
DATA["distros.arch.yay"]='- Atualize seu sistema e instale as dependências necessárias:\n
sudo pacman -Syu --needed base-devel git
\n\n
- Clone o repositório do YAY:\n
git clone https://aur.archlinux.org/yay.git
\n\n
- Acesse o diretório clonado:
\ncd yay
\n\n
- Compile e instale o YAY:\n
makepkg -si
\n\n
- Verifique a instalação:\n
yay --version'

#####################
# === LINUX GERAL ===
#####################

DATA["linux"]="initramfs grub systemd permissoes boot_process"

DATA["linux.initramfs"]=$'Initramfs:\n\nSistema de arquivos temporário carregado pelo bootloader.\nServe para montar o root real e carregar módulos.'
DATA["linux.grub"]=$'GRUB:\n\nBootloader mais comum.\nConfig principal: /etc/default/grub\nGerar config: grub-mkconfig -o /boot/grub/grub.cfg'
DATA["linux.systemd"]=$'systemd:\n\ninit system moderno.\nComandos:\nsystemctl start|stop|enable|status'
DATA["linux.permissoes"]=$'Permissões:\n\nrwx = 4 2 1\nchmod\nchown\numask'
DATA["linux.boot_process"]=$'Boot process:\n\nBIOS/UEFI → Bootloader → Kernel → Initramfs → init/systemd → userspace'

########################
# === FERRAMENTAS ===
########################

DATA["ferramentas"]="nmap git ssh tmux"

DATA["ferramentas.nmap"]=$'Nmap:\n\nScanner de rede.\nEx:\nnmap -sS -sV -A alvo'
DATA["ferramentas.git"]=$'Git:\n\nControle de versão.\ngit clone\ngit pull\ngit commit -m'
DATA["ferramentas.ssh"]=$'SSH:\n\nAcesso remoto seguro.\nssh user@host'
DATA["ferramentas.tmux"]=$'Tmux:\n\nMultiplexador de terminal.\ntmux\nCtrl+b c / % / "'

#############################
# ===== INTERFACE UI ===== #
#############################

welcome() {
  dialog --backtitle "$TITLE" \
         --title "Lanis" \
         --msgbox "oi, eu sou a Lanis\n\nteu cérebro linux offline\n\nusa as setas e enter pra navegar\n\nversão $VERSION" \
         12 60
}

main_menu() {
  while true; do
    choice=$(dialog --backtitle "$TITLE" \
      --title "menu principal" \
      --cancel-label "sair" \
      --menu "escolhe uma categoria:" \
      15 60 10 \
      "distros" "distribuições linux" \
      "linux" "conceitos gerais" \
      "ferramentas" "comandos e tools" \
      "sobre" "sobre a lanis" \
      3>&1 1>&2 2>&3)

    [ $? -ne 0 ] && exit_script

    case "$choice" in
      distros|linux|ferramentas)
        category_menu "$choice"
        ;;
      sobre)
        about
        ;;
    esac
  done
}

category_menu() {
  local category="$1"
  local items="${DATA[$category]}"

  while true; do
    local options=()
    for i in $items; do
      options+=("$i" "")
    done

    options+=("<< voltar" "menu principal")

    choice=$(dialog --backtitle "$TITLE" \
      --title "$category" \
      --menu "escolhe:" \
      20 60 12 \
      "${options[@]}" \
      3>&1 1>&2 2>&3)

    [ $? -ne 0 ] && exit_script
    [ "$choice" = "<< voltar" ] && return

    subcategory_menu "$category" "$choice"
  done
}

subcategory_menu() {
  local category="$1"
  local item="$2"
  local base_key="$category.$item"

  local has_children=0
  for k in "${!DATA[@]}"; do
    [[ "$k" == "$base_key."* ]] && has_children=1
  done

  if [ "$has_children" -eq 0 ]; then
    show_text "$base_key"
    return
  fi

  local subs="${DATA[$base_key]}"

  while true; do
    local options=()
    for s in $subs; do
      options+=("$s" "")
    done

    options+=("<< voltar" "$category")

    choice=$(dialog --backtitle "$TITLE" \
      --title "$category → $item" \
      --menu "escolhe:" \
      20 70 12 \
      "${options[@]}" \
      3>&1 1>&2 2>&3)

    [ $? -ne 0 ] && exit_script
    [ "$choice" = "<< voltar" ] && return

    show_text "$base_key.$choice"
  done
}

show_text() {
  local key="$1"
  local text="${DATA[$key]}"

  dialog --backtitle "$TITLE" \
         --title "$key" \
         --extra-button --extra-label "voltar" \
         --ok-label "menu principal" \
         --msgbox "$text" \
         20 75

  case $? in
    3) return ;;
    0) exit_script ;;
  esac
}

about() {
  dialog --backtitle "$TITLE" \
         --title "sobre" \
         --extra-button --extra-label "voltar" \
         --ok-label "menu principal" \
         --msgbox "Lanis\n\nassistente offline em shell\n\nestilo sbopkg/dwm\n\ntudo editável direto no código\n\nfeito pra organizar conhecimento técnico" \
         15 60

  case $? in
    3) return ;;
    0) return ;;
  esac
}

exit_script() {
  clear
  echo "vlw por usar a lanis 🐧"
  exit 0
}

main() {
  if ! command -v dialog &>/dev/null; then
    echo "instala dialog primeiro"
    exit 1
  fi

  clear
  welcome
  main_menu
}

main
