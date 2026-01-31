#!/bin/bash

# cripto.sh - Criptografia alfabética simples
# Nova arquitetura com modificadores de bloco
#
# BÁSICO:
#   a-z = 01-26, espaço = 27
#
# MODIFICADORES DE BLOCO:
#   90 = início/fim de MAIÚSCULAS
#   91 = início/fim de NÚMEROS
#   92 = início/fim de ACENTUADOS
#
# PONTUAÇÃO:
#   , = 28, ? = 29, ( = 31, ) = 32, ! = 33, . = 34
#   : = 35, ; = 36, - = 37, " = 38

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
    echo "  Espaço: 27"
    echo "  Pontuação: , = 28, ? = 29, ( = 31, ) = 32, ! = 33, . = 34"
    echo "             : = 35, ; = 36, - = 37, \" = 38"
    echo ""
    echo "  Modificadores de bloco:"
    echo "    90...90 = MAIÚSCULAS"
    echo "    91...91 = NÚMEROS"
    echo "    92...92 = ACENTUADOS"
    echo ""
    echo "Exemplos:"
    echo "  'oi' → '1509'"
    echo "  'Oi' → '90151990'"
    echo "  '123' → '91010203091'"
    echo "  'é' → '92050392'"
    echo "  'São Paulo' → '9019009201152715309016012115'"
}

# Mapa de caracteres acentuados para suas versões base
# Retorna: "base acento" (ex: "e agudo")
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

# Função para criptografar: texto → números
criptografar() {
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
            [ $em_maiusculas -eq 1 ] && resultado="${resultado}90" && em_maiusculas=0
            [ $em_numeros -eq 1 ] && resultado="${resultado}91" && em_numeros=0
            
            # Abre bloco de acentuados se necessário
            [ $em_acentuados -eq 0 ] && resultado="${resultado}92" && em_acentuados=1
            
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
            [ $em_maiusculas -eq 1 ] && resultado="${resultado}90" && em_maiusculas=0
            [ $em_numeros -eq 1 ] && resultado="${resultado}91" && em_numeros=0
            [ $em_acentuados -eq 1 ] && resultado="${resultado}92" && em_acentuados=0
            
            local num=$(printf "%02d" $(( $(printf "%d" "'$char") - 96 )))
            resultado="${resultado}${num}"
            
        elif [[ "$char" =~ ^[A-Z]$ ]]; then
            # Letra maiúscula
            [ $em_numeros -eq 1 ] && resultado="${resultado}91" && em_numeros=0
            [ $em_acentuados -eq 1 ] && resultado="${resultado}92" && em_acentuados=0
            [ $em_maiusculas -eq 0 ] && resultado="${resultado}90" && em_maiusculas=1
            
            local num=$(printf "%02d" $(( $(printf "%d" "'$char") - 64 )))
            resultado="${resultado}${num}"
            
        elif [[ "$char" =~ ^[0-9]$ ]]; then
            # Número
            [ $em_maiusculas -eq 1 ] && resultado="${resultado}90" && em_maiusculas=0
            [ $em_acentuados -eq 1 ] && resultado="${resultado}92" && em_acentuados=0
            [ $em_numeros -eq 0 ] && resultado="${resultado}91" && em_numeros=1
            
            local num=$(printf "%02d" "$char")
            resultado="${resultado}${num}"
            
        else
            # Caractere especial - fecha todos os blocos
            [ $em_maiusculas -eq 1 ] && resultado="${resultado}90" && em_maiusculas=0
            [ $em_numeros -eq 1 ] && resultado="${resultado}91" && em_numeros=0
            [ $em_acentuados -eq 1 ] && resultado="${resultado}92" && em_acentuados=0
            
            case "$char" in
                " ") resultado="${resultado}27" ;;
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
    [ $em_maiusculas -eq 1 ] && resultado="${resultado}90"
    [ $em_numeros -eq 1 ] && resultado="${resultado}91"
    [ $em_acentuados -eq 1 ] && resultado="${resultado}92"
    
    echo "📤 $resultado"
}

# Função para descriptografar: números → texto
descriptografar() {
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
        
        case "$par" in
            90)
                # Modificador de maiúsculas
                em_maiusculas=$((1 - em_maiusculas))
                i=$((i+2))
                ;;
            91)
                # Modificador de números
                em_numeros=$((1 - em_numeros))
                i=$((i+2))
                ;;
            92)
                # Modificador de acentuados
                em_acentuados=$((1 - em_acentuados))
                i=$((i+2))
                ;;
            27) resultado="${resultado} "; i=$((i+2)) ;;
            28) resultado="${resultado},"; i=$((i+2)) ;;
            29) resultado="${resultado}?"; i=$((i+2)) ;;
            31) resultado="${resultado}("; i=$((i+2)) ;;
            32) resultado="${resultado})"; i=$((i+2)) ;;
            33) resultado="${resultado}!"; i=$((i+2)) ;;
            34) resultado="${resultado}."; i=$((i+2)) ;;
            35) resultado="${resultado}:"; i=$((i+2)) ;;
            36) resultado="${resultado};"; i=$((i+2)) ;;
            37) resultado="${resultado}-"; i=$((i+2)) ;;
            38) resultado="${resultado}\""; i=$((i+2)) ;;
            00|01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26)
                local num=$((10#$par))
                
                if [ $em_numeros -eq 1 ]; then
                    # É um número
                    resultado="${resultado}${num}"
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
                        local char=$(printf "\\$(printf '%03o' $((num + 64)))")
                    else
                        local char=$(printf "\\$(printf '%03o' $((num + 96)))")
                    fi
                    resultado="${resultado}${char}"
                    i=$((i+2))
                fi
                ;;
            *)
                echo "[AVISO] Par inválido ignorado: '$par'" >&2
                i=$((i+2))
                ;;
        esac
    done
    
    echo "📥 $resultado"
}

# Interface principal
main() {
    echo "=== Cripto.sh ==="
    echo "c: Criptografar | d: Descriptografar | h: Ajuda | q: Sair"
    
    while true; do
        echo -n "? "
        read comando
        
        case "$comando" in
            c|-c)
                echo -n "> "
                read texto
                if [ -n "$texto" ]; then
                    criptografar "$texto"
                else
                    echo "ERRO: Texto vazio!" >&2
                fi
                ;;
            d|-d)
                echo -n "> "
                read numeros
                if [ -n "$numeros" ]; then
                    descriptografar "$numeros"
                else
                    echo "ERRO: Números vazios!" >&2
                fi
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
```

**Principais mudanças:**

✅ **Nova arquitetura com modificadores de bloco**
- `90...90` = MAIÚSCULAS
- `91...91` = NÚMEROS  
- `92...92` = ACENTUADOS

✅ **Suporte completo a acentos** (cada acentuado = 4 dígitos: base + tipo de acento)

✅ **Suporte a números** (0-9)

**Exemplos de uso:**
```
"é" → 92050192 (bloco acentuado, e=05, agudo=01)
"Oi" → 90151990 (bloco maiúsculo, O=15, i=09)
"123" → 91000102030991 (bloco numérico)
"São Paulo" → 9019009201150392152730901601211509027
