#!/bin/bash

TITLE="HilaCLI"
VERSION="0.2"

clear

print_header() {
  echo "==================================="
  echo " $TITLE - executor guiado"
  echo " Versão: $VERSION"
  echo "==================================="
  echo
}

pause() {
  read -rp "pressione ENTER pra continuar..."
}

confirm() {
  read -rp "$1 [s/N]: " choice
  [[ "$choice" =~ ^[Ss]$ ]]
}

run_cmd() {
  echo
  echo ">>> Executando:"
  echo "$*"
  echo
  eval "$@"
  echo
}

# ==========================
# === SLACKWARE UPDATE ====
# ==========================

slackware_update() {
  clear
  print_header
  echo "Slackware → Atualização do sistema"
  echo

  if confirm "Deseja rodar: slackpkg update ?"; then
    run_cmd "sudo slackpkg update"
  else
    echo "Pulando slackpkg update."
  fi
  pause

  if confirm "Deseja rodar: slackpkg upgrade-all ?"; then
    run_cmd "sudo slackpkg upgrade-all"
  else
    echo "Pulando upgrade-all."
  fi
  pause

  slackware_kernel_check
}

# ==========================
# === KERNEL CHECK =========
# ==========================

slackware_kernel_check() {
  clear
  print_header
  echo "Slackware → Verificação de kernel"
  echo

  echo "Kernel atualmente em execução:"
  uname -r
  echo

  echo "Kernels disponíveis em /lib/modules:"
  ls /lib/modules
  echo

  echo "NOTA:"
  echo "Se em /lib/modules aparecer kernel diferente do uname -r, então mudou sim."
  echo

  if confirm "Deseja prosseguir para regenerar initrd e atualizar boot?"; then
    slackware_mkinitrd_menu
  else
    echo "Pulando etapa de kernel."
    pause
  fi
}

# ==========================
# === MKINITRD FLOW ========
# ==========================

slackware_mkinitrd_menu() {
  while true; do
    clear
    print_header
    echo "Slackware → Kernel / Initrd"
    echo
    echo "1) Descobrir comando do mkinitrd (command_generator)"
    echo "2) Gerar initrd (kernel generic)"
    echo "3) Copiar kernel + initrd pra ESP"
    echo "4) Gerar grub.cfg"
    echo "0) Voltar"
    echo
    read -rp "> " opt

    case "$opt" in
      1) slackware_mkinitrd_generator ;;
      2) slackware_mkinitrd_run ;;
      3) slackware_copy_esp ;;
      4) slackware_grub ;;
      0) break ;;
      *) echo "Opção inválida"; pause ;;
    esac
  done
}

# ==========================
# === MKINITRD GENERATOR ===
# ==========================

slackware_mkinitrd_generator() {
  clear
  print_header
  echo "Slackware → mkinitrd command generator"
  echo

  run_cmd "sudo /usr/share/mkinitrd/mkinitrd_command_generator.sh"
  pause
}

# ==========================
# === MKINITRD RUN =========
# ==========================

slackware_mkinitrd_run() {
  clear
  print_header
  echo "Slackware → Gerar initrd (kernel generic)"
  echo

  echo "Cole aqui o comando mkinitrd que você deseja executar."
  echo "Exemplo:"
  echo "sudo mkinitrd -c -k 6.12.66 -f ext4 -r /dev/nvme0n1p2 \\"
  echo "  -m xhci-pci:ohci-pci:ehci-pci:xhci-hcd:uhci-hcd:ehci-hcd:hid:usbhid:i2c-hid:hid_generic:hid-asus:hid-cherry:hid-logitech:hid-logitech-dj:hid-logitech-hidpp:hid-lenovo:hid-microsoft:hid_multitouch:ext4 \\"
  echo "  -u -o /boot/initrd-generic.img"
  echo

  read -rp "mkinitrd> " MKCMD
  echo

  if confirm "Confirmar execução desse comando?"; then
    run_cmd "$MKCMD"
  else
    echo "mkinitrd cancelado."
  fi
  pause
}

# ==========================
# === COPY TO ESP ==========
# ==========================

slackware_copy_esp() {
  clear
  print_header
  echo "Slackware → Copiar kernel pra ESP"
  echo

  echo "Isso irá rodar:"
  echo "sudo cp -v /boot/vmlinuz-generic /boot/efi/EFI/Slackware/vmlinuz"
  echo "sudo cp -v /boot/initrd-generic.img /boot/efi/EFI/Slackware/initrd.gz"
  echo

  if confirm "Confirmar cópia?"; then
    run_cmd "sudo cp -v /boot/vmlinuz-generic /boot/efi/EFI/Slackware/vmlinuz"
    run_cmd "sudo cp -v /boot/initrd-generic.img /boot/efi/EFI/Slackware/initrd.gz"
  else
    echo "Cópia cancelada."
  fi
  pause
}

# ==========================
# === GRUB =================
# ==========================

slackware_grub() {
  clear
  print_header
  echo "Slackware → Gerar grub.cfg"
  echo

  echo "Isso irá rodar:"
  echo "sudo grub-mkconfig -o /boot/efi/EFI/Slackware/grub/grub.cfg"
  echo

  if confirm "Confirmar geração do grub.cfg?"; then
    run_cmd "sudo grub-mkconfig -o /boot/efi/EFI/Slackware/grub/grub.cfg"
  else
    echo "grub.cfg não foi gerado."
  fi
  pause
}

# ==========================
# === MENUS =================
# ==========================

slackware_menu() {
  while true; do
    clear
    print_header
    echo "Distros → Slackware"
    echo
    echo "1) Atualizar sistema"
    echo "2) Kernel / Initrd / Boot"
    echo "0) Voltar"
    echo
    read -rp "> " opt

    case "$opt" in
      1) slackware_update ;;
      2) slackware_kernel_check ;;
      0) break ;;
      *) echo "Opção inválida"; pause ;;
    esac
  done
}

distros_menu() {
  while true; do
    clear
    print_header
    echo "Módulo: Distros"
    echo
    echo "1) Slackware"
    echo "0) Voltar"
    echo
    read -rp "> " opt

    case "$opt" in
      1) slackware_menu ;;
      0) break ;;
      *) echo "Ainda não implementado"; pause ;;
    esac
  done
}

main_menu() {
  while true; do
    clear
    print_header
    echo "1) Distros"
    echo "2) O que é o HilaCLI"
    echo "0) Sair"
    echo
    read -rp "> " opt

    case "$opt" in
      1) distros_menu ;;
      2) echo "HilaCLI = executor guiado da Lanis"; pause ;;
      0) exit 0 ;;
      *) echo "Opção inválida"; pause ;;
    esac
  done
}

main_menu
