#!/bin/bash

# cripto.sh - Criptografia alfabética simples
# Nova arquitetura com modificadores de bloco e sistema de 2 chaves
#
# BÁSICO:
#   a-z = 01-26
#   espaço = 50-59 (aleatório dentro desta faixa)
#
# MODIFICADORES DE BLOCO (ESPECIAIS - não recebem chaves):
#   60 = início/fim de MAIÚSCULAS
#   61 = início/fim de NÚMEROS
#   62 = início/fim de ACENTUADOS
#   Espaço = 50-59 (qualquer número nesta faixa)
#
# PONTUAÇÃO:
#   , = 28, ? = 29, ( = 31, ) = 32, ! = 33, . = 34
#   : = 35, ; = 36, - = 37, " = 38
#
# SISTEMA DE CHAVES:
#   key1 (0-99): soma aos números PARES (último dígito par)
#   key2 (0-99): soma aos números ÍMPARES (último dígito ímpar)
#   Formato: [valor_criptografado][flag_paridade]
#   Flag: 0=veio de par, 1=veio de ímpar
#   ESPECIAIS (50-62): não recebem chaves, ficam como estão

show_help() {
    echo "Uso: ./cripto.sh"
    echo "Comandos disponíveis:"
    echo "  c, -c    Criptografar (texto → números)"
    echo "  d, -d    Descriptografar (números → texto)"
    echo "  h, -h, help  Mostrar esta ajuda"
    echo "  q, -q, quit  Sair"
    echo ""
    echo "Formato de codificação:"
    echo "  Letras minúsculas: 01-26 (a=01, b=02, ..., z=26)"
    echo "  Espaço: 50-59 (aleatório dentro desta faixa)"
    echo "  Pontuação: , = 28, ? = 29, ( = 31, ) = 32, ! = 33, . = 34"
    echo "             : = 35, ; = 36, - = 37, \" = 38"
    echo ""
    echo "  Modificadores de bloco (ESPECIAIS - não recebem chaves):"
    echo "    60...60 = MAIÚSCULAS"
    echo "    61...61 = NÚMEROS"
    echo "    62...62 = ACENTUADOS"
    echo ""
    echo "SISTEMA DE CHAVES:"
    echo "  key1 (0-99): soma aos números PARES (terminam em 0,2,4,6,8)"
    echo "  key2 (0-99): soma aos números ÍMPARES (terminam em 1,3,5,7,9)"
    echo "  Formato final: [valor][flag] onde flag=0(par) ou 1(ímpar)"
    echo "  ESPECIAIS (50-62): não recebem chaves, mantêm valor original"
    echo ""
    echo "Exemplos (sem chaves):"
    echo "  'oi' → '1509'"
    echo "  'Oi' → '60151960'"
    echo "  '123' → '61010203061'"
    echo "  'é' → '62050162'"
    echo ""
    echo "Exemplo com chaves (key1=10, key2=2):"
    echo "  'fi' (1609) → '2600291'"
    echo "  16(par)+10=26→'260', 09(ímpar)+2=11→'111'"
    echo "  Espaço (ex: 53) → '53' (especial, não recebe chave)"
}

# Mapa de caracteres acentuados para suas versões base
mapear_acentuado() {
    local char="$1"
    case "$char" in
        á|Á) echo "a agudo" ;;
        à|À) echo "a grave" ;;
        ã|Ã) echo "a til" ;;
        â|Â) echo "a circunflexo" ;;
        ä|Ä) echo "a trema" ;;
        é|É) echo "e agudo" ;;
        è|È) echo "e grave" ;;
        ê|Ê) echo "e circunflexo" ;;
        ë|Ë) echo "e trema" ;;
        í|Í) echo "i agudo" ;;
        ì|Ì) echo "i grave" ;;
        î|Î) echo "i circunflexo" ;;
        ï|Ï) echo "i trema" ;;
        ó|Ó) echo "o agudo" ;;
        ò|Ò) echo "o grave" ;;
        ô|Ô) echo "o circunflexo" ;;
        õ|Õ) echo "o til" ;;
        ö|Ö) echo "o trema" ;;
        ú|Ú) echo "u agudo" ;;
        ù|Ù) echo "u grave" ;;
        û|Û) echo "u circunflexo" ;;
        ü|Ü) echo "u trema" ;;
        ç|Ç) echo "c cedilha" ;;
        ñ|Ñ) echo "n til" ;;
        *) echo "" ;;
    esac
}

# Converte tipo de acento para número
acento_para_numero() {
    local acento="$1"
    case "$acento" in
        agudo) echo "01" ;;
        grave) echo "02" ;;
        til) echo "03" ;;
        circunflexo) echo "04" ;;
        trema) echo "05" ;;
        cedilha) echo "06" ;;
        *) echo "00" ;;
    esac
}

# Converte número para tipo de acento
numero_para_acento() {
    local num="$1"
    case "$num" in
        01) echo "agudo" ;;
        02) echo "grave" ;;
        03) echo "til" ;;
        04) echo "circunflexo" ;;
        05) echo "trema" ;;
        06) echo "cedilha" ;;
        *) echo "" ;;
    esac
}

# Aplica acento a uma letra base
aplicar_acento() {
    local base="$1"
    local acento="$2"
    local maiuscula="$3"

    local resultado=""

    case "${base}${acento}" in
        aagudo) resultado="á" ;;
        agrave) resultado="à" ;;
        atil) resultado="ã" ;;
        acircunflexo) resultado="â" ;;
        atrema) resultado="ä" ;;
        eagudo) resultado="é" ;;
        egrave) resultado="è" ;;
        ecircunflexo) resultado="ê" ;;
        etrema) resultado="ë" ;;
        iagudo) resultado="í" ;;
        igrave) resultado="ì" ;;
        icircunflexo) resultado="î" ;;
        itrema) resultado="ï" ;;
        oagudo) resultado="ó" ;;
        ograve) resultado="ò" ;;
        ocircunflexo) resultado="ô" ;;
        otil) resultado="õ" ;;
        otrema) resultado="ö" ;;
        uagudo) resultado="ú" ;;
        ugrave) resultado="ù" ;;
        ucircunflexo) resultado="û" ;;
        utrema) resultado="ü" ;;
        ccedilha) resultado="ç" ;;
        ntil) resultado="ñ" ;;
        *) resultado="$base" ;;
    esac

    # Converte para maiúscula se necessário
    if [ "$maiuscula" = "1" ]; then
        resultado=$(echo "$resultado" | tr 'a-zá-úç' 'A-ZÁ-ÚÇ')
    fi

    echo "$resultado"
}

# Gera um número aleatório entre 50-59 para espaço
gerar_espaco() {
    local random_num=$((RANDOM % 10 + 50))  # 50-59
    echo "$random_num"
}

# Função para solicitar chaves
solicitar_chaves() {
    while true; do
        echo -n "key1 (0-99): "
        read key1

        # Verifica se é número válido
        if [[ ! "$key1" =~ ^[0-9]+$ ]] || [ "$key1" -lt 0 ] || [ "$key1" -gt 99 ]; then
            echo "ERRO: key1 deve ser um número entre 0 e 99!"
            continue
        fi

        echo -n "key2 (0-99): "
        read key2

        if [[ ! "$key2" =~ ^[0-9]+$ ]] || [ "$key2" -lt 0 ] || [ "$key2" -gt 99 ]; then
            echo "ERRO: key2 deve ser um número entre 0 e 99!"
            continue
        fi

        break
    done
}

# Função para criptografar com chaves
criptografar_com_chaves() {
    local numeros="$1"
    local key1="$2"
    local key2="$3"
    local resultado=""
    local i=0

    # Remove qualquer caractere não numérico
    numeros=$(echo "$numeros" | tr -cd '0-9')

    # Valida se tem número par de dígitos (sem contar flags ainda)
    if [ $((${#numeros} % 2)) -ne 0 ]; then
        echo "[ERRO] Número ímpar de dígitos! Entrada inválida." >&2
        return 1
    fi

    # Processa os números em pares de 2 dígitos
    while [ $i -lt ${#numeros} ]; do
        local par="${numeros:$i:2}"
        local valor_par=$((10#$par))

        # Verifica se é ESPECIAL (50-62)
        if [ $valor_par -ge 50 ] && [ $valor_par -le 62 ]; then
            # É ESPECIAL: não aplica chave, apenas repete
            resultado="${resultado}${par}"
        else
            local ultimo_digito="${par:1:1}"

            # Determina paridade pelo último dígito
            if [[ "$ultimo_digito" =~ [02468] ]]; then
                # PAR: soma key1
                local valor=$((valor_par + key1))
                valor=$((valor % 100))  # Módulo 100 (00-99)

                # Formata com 2 dígitos e adiciona flag 0
                resultado="${resultado}$(printf "%02d" $valor)0"
            else
                # ÍMPAR: soma key2
                local valor=$((valor_par + key2))
                valor=$((valor % 100))  # Módulo 100 (00-99)

                # Formata com 2 dígitos e adiciona flag 1
                resultado="${resultado}$(printf "%02d" $valor)1"
            fi
        fi

        i=$((i+2))
    done

    echo "$resultado"
}

# Função para descriptografar com chaves
descriptografar_com_chaves() {
    local numeros="$1"
    local key1="$2"
    local key2="$3"
    local resultado=""
    local i=0

    # Remove qualquer caractere não numérico
    numeros=$(echo "$numeros" | tr -cd '0-9')

    # Processa os números
    while [ $i -lt ${#numeros} ]; do
        # Verifica se próximo grupo é ESPECIAL (2 dígitos) ou NORMAL (3 dígitos)
        local primeiro_par="${numeros:$i:2}"
        local valor_primeiro=$((10#$primeiro_par))

        if [ $valor_primeiro -ge 50 ] && [ $valor_primeiro -le 62 ]; then
            # É ESPECIAL: apenas 2 dígitos
            resultado="${resultado}${primeiro_par}"
            i=$((i+2))
        else
            # É NORMAL: 3 dígitos (2 valor + 1 flag)
            if [ $((i+2)) -ge ${#numeros} ]; then
                echo "[ERRO] Fim inesperado dos dados!" >&2
                break
            fi

            local valor_cript="${numeros:$i:2}"
            local flag="${numeros:$((i+2)):1}"
            local valor_original

            # Determina operação pela flag
            if [ "$flag" = "0" ]; then
                # Veio de PAR: subtrai key1
                valor_original=$((10#$valor_cript - key1))
            else
                # Veio de ÍMPAR: subtrai key2
                valor_original=$((10#$valor_cript - key2))
            fi

            # Ajusta para faixa 00-99 (módulo 100)
            while [ $valor_original -lt 0 ]; do
                valor_original=$((valor_original + 100))
            done
            valor_original=$((valor_original % 100))

            # Formata com 2 dígitos
            resultado="${resultado}$(printf "%02d" $valor_original)"
            i=$((i+3))
        fi
    done

    echo "$resultado"
}

# Função para criptografar: texto → números (sem chaves)
criptografar_sem_chaves() {
    local texto="$1"
    local resultado=""
    local em_maiusculas=0
    local em_numeros=0
    local em_acentuados=0

    # Percorre cada caractere
    for (( i=0; i<${#texto}; i++ )); do
        local char="${texto:$i:1}"

        # Verifica se é acentuado
        local mapa=$(mapear_acentuado "$char")

        if [ -n "$mapa" ]; then
            # É um caractere acentuado
            # Fecha blocos anteriores se necessário
            [ $em_maiusculas -eq 1 ] && resultado="${resultado}60" && em_maiusculas=0
            [ $em_numeros -eq 1 ] && resultado="${resultado}61" && em_numeros=0

            # Abre bloco de acentuados se necessário
            [ $em_acentuados -eq 0 ] && resultado="${resultado}62" && em_acentuados=1

            # Extrai base e acento
            local base=$(echo "$mapa" | cut -d' ' -f1)
            local acento=$(echo "$mapa" | cut -d' ' -f2)

            # Converte base para número
            local base_lower=$(echo "$base" | tr 'A-Z' 'a-z')
            local num_base=$(printf "%02d" $(( $(printf "%d" "'$base_lower") - 96 )))

            # Converte acento para número
            local num_acento=$(acento_para_numero "$acento")

            resultado="${resultado}${num_base}${num_acento}"

        elif [[ "$char" =~ ^[a-z]$ ]]; then
            # Letra minúscula
            [ $em_maiusculas -eq 1 ] && resultado="${resultado}60" && em_maiusculas=0
            [ $em_numeros -eq 1 ] && resultado="${resultado}61" && em_numeros=0
            [ $em_acentuados -eq 1 ] && resultado="${resultado}62" && em_acentuados=0

            local num=$(printf "%02d" $(( $(printf "%d" "'$char") - 96 )))
            resultado="${resultado}${num}"

        elif [[ "$char" =~ ^[A-Z]$ ]]; then
            # Letra maiúscula
            [ $em_numeros -eq 1 ] && resultado="${resultado}61" && em_numeros=0
            [ $em_acentuados -eq 1 ] && resultado="${resultado}62" && em_acentuados=0
            [ $em_maiusculas -eq 0 ] && resultado="${resultado}60" && em_maiusculas=1

            local num=$(printf "%02d" $(( $(printf "%d" "'$char") - 64 )))
            resultado="${resultado}${num}"

        elif [[ "$char" =~ ^[0-9]$ ]]; then
            # Número
            [ $em_maiusculas -eq 1 ] && resultado="${resultado}60" && em_maiusculas=0
            [ $em_acentuados -eq 1 ] && resultado="${resultado}62" && em_acentuados=0
            [ $em_numeros -eq 0 ] && resultado="${resultado}61" && em_numeros=1

            local num=$(printf "%02d" "$char")
            resultado="${resultado}${num}"

        elif [[ "$char" == " " ]]; then
            # ESPAÇO - gera número aleatório entre 50-59
            [ $em_maiusculas -eq 1 ] && resultado="${resultado}60" && em_maiusculas=0
            [ $em_numeros -eq 1 ] && resultado="${resultado}61" && em_numeros=0
            [ $em_acentuados -eq 1 ] && resultado="${resultado}62" && em_acentuados=0

            local espaco=$(gerar_espaco)
            resultado="${resultado}${espaco}"

        else
            # Caractere especial - fecha todos os blocos
            [ $em_maiusculas -eq 1 ] && resultado="${resultado}60" && em_maiusculas=0
            [ $em_numeros -eq 1 ] && resultado="${resultado}61" && em_numeros=0
            [ $em_acentuados -eq 1 ] && resultado="${resultado}62" && em_acentuados=0

            case "$char" in
                ",") resultado="${resultado}28" ;;
                "?") resultado="${resultado}29" ;;
                "(") resultado="${resultado}31" ;;
                ")") resultado="${resultado}32" ;;
                "!") resultado="${resultado}33" ;;
                ".") resultado="${resultado}34" ;;
                ":") resultado="${resultado}35" ;;
                ";") resultado="${resultado}36" ;;
                "-") resultado="${resultado}37" ;;
                "\"") resultado="${resultado}38" ;;
                *) echo "[AVISO] Caractere ignorado: '$char'" >&2 ;;
            esac
        fi
    done

    # Fecha blocos abertos
    [ $em_maiusculas -eq 1 ] && resultado="${resultado}60"
    [ $em_numeros -eq 1 ] && resultado="${resultado}61"
    [ $em_acentuados -eq 1 ] && resultado="${resultado}62"

    echo "$resultado"
}

# Função para descriptografar: números → texto (sem chaves)
descriptografar_sem_chaves() {
    local numeros="$1"
    local resultado=""
    local i=0
    local em_maiusculas=0
    local em_numeros=0
    local em_acentuados=0

    # Remove qualquer caractere não numérico
    numeros=$(echo "$numeros" | tr -cd '0-9')

    # Valida se tem número par de dígitos
    if [ $((${#numeros} % 2)) -ne 0 ]; then
        echo "[ERRO] Número ímpar de dígitos! Entrada inválida." >&2
        return 1
    fi

    # Processa os números
    while [ $i -lt ${#numeros} ]; do
        local par="${numeros:$i:2}"
        local valor_par=$((10#$par))

        # Verifica se é ESPAÇO (50-59)
        if [ $valor_par -ge 50 ] && [ $valor_par -le 59 ]; then
            resultado="${resultado} "
            i=$((i+2))

        # Verifica se é MODIFICADOR DE BLOCO
        elif [ "$par" = "60" ]; then
            # Modificador de maiúsculas
            em_maiusculas=$((1 - em_maiusculas))
            i=$((i+2))
        elif [ "$par" = "61" ]; then
            # Modificador de números
            em_numeros=$((1 - em_numeros))
            i=$((i+2))
        elif [ "$par" = "62" ]; then
            # Modificador de acentuados
            em_acentuados=$((1 - em_acentuados))
            i=$((i+2))

        # Verifica pontuação
        elif [ "$par" = "28" ]; then
            resultado="${resultado},"
            i=$((i+2))
        elif [ "$par" = "29" ]; then
            resultado="${resultado}?"
            i=$((i+2))
        elif [ "$par" = "31" ]; then
            resultado="${resultado}("
            i=$((i+2))
        elif [ "$par" = "32" ]; then
            resultado="${resultado})"
            i=$((i+2))
        elif [ "$par" = "33" ]; then
            resultado="${resultado}!"
            i=$((i+2))
        elif [ "$par" = "34" ]; then
            resultado="${resultado}."
            i=$((i+2))
        elif [ "$par" = "35" ]; then
            resultado="${resultado}:"
            i=$((i+2))
        elif [ "$par" = "36" ]; then
            resultado="${resultado};"
            i=$((i+2))
        elif [ "$par" = "37" ]; then
            resultado="${resultado}-"
            i=$((i+2))
        elif [ "$par" = "38" ]; then
            resultado="${resultado}\""
            i=$((i+2))

        # Letras e números
        elif [ $valor_par -ge 1 ] && [ $valor_par -le 26 ]; then
            if [ $em_numeros -eq 1 ]; then
                # É um número dentro do bloco 61...61
                resultado="${resultado}${valor_par}"
                i=$((i+2))
            elif [ $em_acentuados -eq 1 ]; then
                # É uma letra acentuada - precisa ler 4 dígitos (base + acento)
                if [ $((i+3)) -ge ${#numeros} ]; then
                    echo "[ERRO] Bloco acentuado incompleto!" >&2
                    break
                fi

                local base_num="${numeros:$i:2}"
                local acento_num="${numeros:$((i+2)):2}"

                # Converte base para letra
                local base_val=$((10#$base_num))
                if [ $base_val -ge 1 ] && [ $base_val -le 26 ]; then
                    local base_char=$(printf "\\$(printf '%03o' $((base_val + 96)))")
                    local acento_tipo=$(numero_para_acento "$acento_num")

                    local char=$(aplicar_acento "$base_char" "$acento_tipo" "$em_maiusculas")
                    resultado="${resultado}${char}"
                else
                    echo "[AVISO] Código de base inválido: $base_num" >&2
                fi

                i=$((i+4))
            else
                # É uma letra normal
                if [ $em_maiusculas -eq 1 ]; then
                    local char=$(printf "\\$(printf '%03o' $((valor_par + 64)))")
                else
                    local char=$(printf "\\$(printf '%03o' $((valor_par + 96)))")
                fi
                resultado="${resultado}${char}"
                i=$((i+2))
            fi
        else
            echo "[AVISO] Par inválido ignorado: '$par'" >&2
            i=$((i+2))
        fi
    done

    echo "$resultado"
}

# Interface principal
main() {
    echo "=== Cripto.sh (v3.0 - Espaço 50-59) ==="
    echo "c: Criptografar | d: Descriptografar | h: Ajuda | q: Sair"

    while true; do
        echo -n "? "
        read comando

        case "$comando" in
            c|-c)
                echo -n "txt2num > "
                read texto
                if [ -z "$texto" ]; then
                    echo "ERRO: Texto vazio!" >&2
                    continue
                fi

                #echo "Primeiro, converter texto para números..."
                local numeros=$(criptografar_sem_chaves "$texto")
                #echo "Números sem chaves: $numeros"

                echo "apply cript keys:"
                solicitar_chaves

                local resultado=$(criptografar_com_chaves "$numeros" "$key1" "$key2")
                echo "cript: $resultado"
                ;;
            d|-d)
                echo -n "num2txt > "
                read entrada_numeros
                if [ -z "$entrada_numeros" ]; then
                    echo "ERRO: Números vazios!" >&2
                    continue
                fi

                #echo "chaves..."
                solicitar_chaves

                local numeros=$(descriptografar_com_chaves "$entrada_numeros" "$key1" "$key2")
                #echo "Números sem chaves: $numeros"

                #echo "Agora, converter números para texto..."
                local resultado=$(descriptografar_sem_chaves "$numeros")
                echo "decript: $resultado"
                ;;
            h|-h|help)
                show_help
                ;;
            q|-q|quit)
                echo "Saindo..."
                exit 0
                ;;
            "")
                continue
                ;;
            *)
                echo "Comando inválido! Use c, d, h ou q"
                ;;
        esac
    done
}

# Executa o script
main
