#!/bin/bash
#
# verifica_sistema.sh
# Verificador de status do sistema após instalação limpa / troca de distro.
# Interface em dialog, com relatorio final salvo em ~/verificacao_sistema_AAAAMMDD.log
#
# Uso: ./verifica_sistema.sh
# Requer: dialog (sudo apt install dialog)

set -uo pipefail

# ----------------------------------------------------------------------------
# Configuração básica
# ----------------------------------------------------------------------------
HOME_SCRIPTS="$HOME/scripts"
REPORT_FILE="$HOME/verificacao_sistema_$(date +%Y%m%d).log"
DIALOG_TMP=""
PLAIN_TMP=""

OK_LIST=()
FAIL_LIST=()
WARN_LIST=()
SUGGESTIONS=()

# ----------------------------------------------------------------------------
# Checagem de dependência
# ----------------------------------------------------------------------------
if ! command -v dialog &>/dev/null; then
    echo "Erro: o pacote 'dialog' não está instalado."
    echo "Instale com: sudo apt install dialog   (Debian/Ubuntu)"
    echo "          ou: sudo dnf install dialog  (Fedora)"
    echo "          ou: sudo pacman -S dialog    (Arch)"
    exit 1
fi

cleanup() {
    [[ -n "$DIALOG_TMP" && -f "$DIALOG_TMP" ]] && rm -f "$DIALOG_TMP"
    [[ -n "$PLAIN_TMP" && -f "$PLAIN_TMP" ]] && rm -f "$PLAIN_TMP"
    clear
}
trap cleanup EXIT

# ----------------------------------------------------------------------------
# Funções auxiliares de registro de resultado
# ----------------------------------------------------------------------------
reset_arrays() {
    OK_LIST=()
    FAIL_LIST=()
    WARN_LIST=()
    SUGGESTIONS=()
    DIALOG_TMP=$(mktemp)
    PLAIN_TMP=$(mktemp)
    : > "$DIALOG_TMP"
    : > "$PLAIN_TMP"
}

# add_result STATUS "Nome" "Detalhe" ["sugestão de instalação"]
add_result() {
    local status="$1" name="$2" detail="$3" suggestion="${4:-}"
    case "$status" in
        OK)
            OK_LIST+=("$name: $detail")
            printf '\\Z2✅ %s\\Zn: %s\n' "$name" "$detail" >> "$DIALOG_TMP"
            printf '[OK] %s: %s\n' "$name" "$detail" >> "$PLAIN_TMP"
            ;;
        FAIL)
            FAIL_LIST+=("$name")
            [[ -n "$suggestion" ]] && SUGGESTIONS+=("$name -> $suggestion")
            printf '\\Z1❌ %s\\Zn: %s\n' "$name" "$detail" >> "$DIALOG_TMP"
            printf '[FALTANDO] %s: %s\n' "$name" "$detail" >> "$PLAIN_TMP"
            ;;
        WARN)
            WARN_LIST+=("$name")
            [[ -n "$suggestion" ]] && SUGGESTIONS+=("$name -> $suggestion")
            printf '\\Z3⚠ %s\\Zn: %s\n' "$name" "$detail" >> "$DIALOG_TMP"
            printf '[PARCIAL] %s: %s\n' "$name" "$detail" >> "$PLAIN_TMP"
            ;;
    esac
}

# Mostra uma caixa de progresso rápida antes de rodar cada checagem
run_check() {
    local label="$1"
    shift
    dialog --title "Verificando..." --infobox "Verificando ${label}..." 5 50
    sleep 0.12
    "$@"
}

# ----------------------------------------------------------------------------
# 1. APLICATIVOS E PACOTES
# ----------------------------------------------------------------------------
check_flatpak() {
    if command -v flatpak &>/dev/null; then
        local ver count
        ver=$(flatpak --version 2>/dev/null)
        count=$(flatpak list --app 2>/dev/null | wc -l)
        add_result OK "Flatpak" "$ver instalado, $count pacote(s) instalado(s)"
    else
        add_result FAIL "Flatpak" "não encontrado" "sudo apt install flatpak"
    fi
}

check_browser() {
    local found=""
    for b in firefox google-chrome google-chrome-stable chromium chromium-browser; do
        if command -v "$b" &>/dev/null; then
            found="$b"
            break
        fi
    done
    if [[ -n "$found" ]]; then
        add_result OK "Navegador" "$found instalado"
    else
        add_result FAIL "Navegador" "nenhum navegador encontrado (Firefox/Chrome/Chromium)" "sudo apt install firefox"
    fi
}

check_pavucontrol() {
    if command -v pavucontrol &>/dev/null; then
        add_result OK "Pavucontrol" "instalado"
    else
        add_result FAIL "Pavucontrol" "não encontrado" "sudo apt install pavucontrol"
    fi
}

check_pulseaudio() {
    if command -v pulseaudio &>/dev/null; then
        if pactl info &>/dev/null || pgrep -x pulseaudio &>/dev/null; then
            add_result OK "PulseAudio" "instalado e em execução"
        else
            add_result WARN "PulseAudio" "instalado, mas não parece estar rodando" "pulseaudio --start"
        fi
    else
        add_result FAIL "PulseAudio" "não encontrado" "sudo apt install pulseaudio"
    fi
}

check_notepad() {
    if command -v leafpad &>/dev/null; then
        add_result OK "Bloco de notas" "leafpad instalado"
    elif command -v mousepad &>/dev/null; then
        add_result OK "Bloco de notas" "mousepad instalado"
    else
        add_result FAIL "Bloco de notas" "leafpad/mousepad não encontrados" "sudo apt install leafpad"
    fi
}

check_vi() {
    if command -v vim &>/dev/null; then
        add_result OK "Editor Vi/Vim" "vim instalado"
    elif command -v vi &>/dev/null; then
        add_result OK "Editor Vi/Vim" "vi instalado"
    else
        add_result FAIL "Editor Vi/Vim" "não encontrado" "sudo apt install vim"
    fi
}

check_scrot() {
    if command -v scrot &>/dev/null; then
        add_result OK "Scrot" "instalado"
    else
        add_result FAIL "Scrot" "não encontrado" "sudo apt install scrot"
    fi
}

check_xwallpaper() {
    if command -v xwallpaper &>/dev/null; then
        add_result OK "Xwallpaper" "instalado"
    else
        add_result FAIL "Xwallpaper" "não encontrado" "sudo apt install xwallpaper"
    fi
}

check_dmenu() {
    if command -v dmenu &>/dev/null; then
        add_result OK "Dmenu" "instalado"
    else
        add_result FAIL "Dmenu" "não encontrado" "sudo apt install suckless-tools"
    fi
}

# ----------------------------------------------------------------------------
# 2. CONFIGURAÇÕES DE SISTEMA
# ----------------------------------------------------------------------------
check_wifi() {
    if command -v nmtui &>/dev/null; then
        local wifi_iface=""
        if command -v iw &>/dev/null; then
            wifi_iface=$(iw dev 2>/dev/null | awk '$1=="Interface"{print $2}' | head -n1)
        fi
        if [[ -n "$wifi_iface" ]]; then
            add_result OK "WiFi (nmtui)" "nmtui disponível, interface detectada: $wifi_iface"
        else
            add_result WARN "WiFi (nmtui)" "nmtui disponível, mas nenhuma interface wireless detectada" "verifique o driver da placa de rede"
        fi
    else
        add_result FAIL "WiFi (nmtui)" "nmtui/NetworkManager não encontrado" "sudo apt install network-manager"
    fi
}

check_sudo_doas() {
    local has_sudo=0 has_doas=0
    command -v sudo &>/dev/null && has_sudo=1
    command -v doas &>/dev/null && has_doas=1
    if [[ $has_sudo -eq 1 && $has_doas -eq 1 ]]; then
        add_result WARN "Sudo/Doas" "ambos instalados (sudo e doas) - verifique qual está em uso"
    elif [[ $has_sudo -eq 1 ]]; then
        add_result OK "Sudo/Doas" "sudo instalado e configurado"
    elif [[ $has_doas -eq 1 ]]; then
        add_result OK "Sudo/Doas" "doas instalado e configurado"
    else
        add_result FAIL "Sudo/Doas" "nenhum dos dois encontrado" "sudo apt install sudo"
    fi
}

# ----------------------------------------------------------------------------
# 3. SCRIPTS PERSONALIZADOS (~/scripts/)
# ----------------------------------------------------------------------------
check_custom_scripts() {
    local scripts=(bright.sh bat.sh wallpaper-switcher.sh intest.sh swap.sh)
    for s in "${scripts[@]}"; do
        if [[ -f "$HOME_SCRIPTS/$s" ]]; then
            if [[ -x "$HOME_SCRIPTS/$s" ]]; then
                add_result OK "Script $s" "encontrado e executável em ~/scripts/"
            else
                add_result WARN "Script $s" "encontrado, mas sem permissão de execução" "chmod +x $HOME_SCRIPTS/$s"
            fi
        else
            add_result FAIL "Script $s" "não encontrado em ~/scripts/" "criar $HOME_SCRIPTS/$s e rodar: chmod +x $HOME_SCRIPTS/$s"
        fi
    done
}

# ----------------------------------------------------------------------------
# 4. CONFIGURAÇÕES DO BASH
# ----------------------------------------------------------------------------
check_bashrc() {
    local bashrc="$HOME/.bashrc"
    if [[ ! -f "$bashrc" ]]; then
        add_result FAIL ".bashrc" "arquivo não encontrado em $HOME" "criar o arquivo ~/.bashrc"
        return
    fi
    add_result OK ".bashrc" "arquivo encontrado em $HOME"

    for alias_name in bright wal intest; do
        if grep -qE "alias[[:space:]]+${alias_name}=" "$bashrc"; then
            add_result OK "Alias '$alias_name'" "configurado em .bashrc"
        else
            add_result FAIL "Alias '$alias_name'" "não encontrado em .bashrc" "adicionar em ~/.bashrc: alias ${alias_name}='...'"
        fi
    done

    if grep -qE '^[[:space:]]*(export[[:space:]]+)?PS1=' "$bashrc"; then
        add_result OK "PS1 (prompt)" "prompt personalizado configurado em .bashrc"
    else
        add_result WARN "PS1 (prompt)" "nenhuma customização de PS1 encontrada em .bashrc" "definir PS1 personalizado em ~/.bashrc"
    fi
}

# ----------------------------------------------------------------------------
# Agrupadores de checagem
# ----------------------------------------------------------------------------
run_apps_check() {
    run_check "Flatpak" check_flatpak
    run_check "Navegador" check_browser
    run_check "Pavucontrol" check_pavucontrol
    run_check "PulseAudio" check_pulseaudio
    run_check "Bloco de notas" check_notepad
    run_check "Editor Vi/Vim" check_vi
    run_check "Scrot" check_scrot
    run_check "Xwallpaper" check_xwallpaper
    run_check "Dmenu" check_dmenu
}

run_config_check() {
    run_check "WiFi (nmtui)" check_wifi
    run_check "PulseAudio" check_pulseaudio
    run_check "Pavucontrol" check_pavucontrol
    run_check "Sudo/Doas" check_sudo_doas
}

run_scripts_check() {
    run_check "scripts personalizados" check_custom_scripts
}

run_bash_check() {
    run_check "configurações do bash" check_bashrc
}

full_check() {
    reset_arrays
    run_apps_check
    run_check "WiFi (nmtui)" check_wifi
    run_check "Sudo/Doas" check_sudo_doas
    run_scripts_check
    run_bash_check
    show_report
}

apps_only_check() {
    reset_arrays
    run_apps_check
    show_report
}

config_only_check() {
    reset_arrays
    run_config_check
    show_report
}

scripts_only_check() {
    reset_arrays
    run_scripts_check
    show_report
}

bash_only_check() {
    reset_arrays
    run_bash_check
    show_report
}

# ----------------------------------------------------------------------------
# Relatório final
# ----------------------------------------------------------------------------
show_report() {
    dialog --title "Relatório de Verificação" --colors --textbox "$DIALOG_TMP" 26 78

    local total=$(( ${#OK_LIST[@]} + ${#FAIL_LIST[@]} + ${#WARN_LIST[@]} ))
    local summary=""
    summary+="Resumo geral:\n"
    summary+="  OK:       ${#OK_LIST[@]}\n"
    summary+="  Parcial:  ${#WARN_LIST[@]}\n"
    summary+="  Faltando: ${#FAIL_LIST[@]}\n"
    summary+="  Total verificado: $total\n\n"

    if [[ ${#FAIL_LIST[@]} -gt 0 ]]; then
        summary+="Itens faltando:\n"
        for item in "${FAIL_LIST[@]}"; do
            summary+="  - $item\n"
        done
    else
        summary+="Nenhum item faltando. Tudo certo!\n"
    fi

    dialog --title "Resumo" --msgbox "$(echo -e "$summary")" 22 70

    ask_save_report
}

ask_save_report() {
    dialog --title "Salvar relatório" \
        --yesno "Deseja salvar o relatório completo em arquivo?\n\n$REPORT_FILE" 9 60
    if [[ $? -eq 0 ]]; then
        save_report_to_file
        dialog --title "Relatório salvo" --msgbox "Relatório salvo em:\n$REPORT_FILE" 8 60
    fi
}

save_report_to_file() {
    {
        echo "=============================================="
        echo " Relatório de Verificação do Sistema"
        echo " Data: $(date '+%d/%m/%Y %H:%M:%S')"
        echo " Usuário: $USER   Host: $(hostname)"
        echo "=============================================="
        echo
        echo "--- Itens verificados ---"
        cat "$PLAIN_TMP"
        echo
        echo "--- Resumo ---"
        echo "OK: ${#OK_LIST[@]}  |  Parcial: ${#WARN_LIST[@]}  |  Faltando: ${#FAIL_LIST[@]}"
        echo

        if [[ ${#FAIL_LIST[@]} -gt 0 ]]; then
            echo "--- Itens faltando ---"
            for item in "${FAIL_LIST[@]}"; do
                echo " - $item"
            done
            echo

            if [[ ${#SUGGESTIONS[@]} -gt 0 ]]; then
                echo "--- Comandos sugeridos para instalação/correção ---"
                for s in "${SUGGESTIONS[@]}"; do
                    echo " - $s"
                done
            fi
        else
            echo "Nenhum item faltando. Sistema configurado corretamente."
        fi
    } > "$REPORT_FILE"
}

# ----------------------------------------------------------------------------
# Menu principal
# ----------------------------------------------------------------------------
main_menu() {
    dialog --backtitle "Verificador de Sistema - Pós-instalação" \
        --title "Verificador de Sistema" \
        --menu "Escolha uma opção:" 17 60 6 \
        1 "Verificar tudo" \
        2 "Verificar apenas aplicativos e pacotes" \
        3 "Verificar apenas configurações de sistema" \
        4 "Verificar apenas scripts personalizados" \
        5 "Verificar apenas configurações do bash" \
        6 "Sair" \
        3>&1 1>&2 2>&3
}

while true; do
    choice=$(main_menu)
    ret=$?
    if [[ $ret -ne 0 ]]; then
        break
    fi
    case "$choice" in
        1) full_check ;;
        2) apps_only_check ;;
        3) config_only_check ;;
        4) scripts_only_check ;;
        5) bash_only_check ;;
        6) break ;;
    esac
done

clear
echo "Verificação encerrada. Se você salvou o relatório, ele está em: $REPORT_FILE"
exit 0