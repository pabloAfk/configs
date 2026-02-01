#!/bin/bash

# ============================================================
# SISTEMA DE CRIPTOGRAFIA HOMOFÔNICA - VERSÃO EXPANDIDA
# Suporte a caracteres especiais: ( ) " ! ?
# ============================================================

POOL="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
# CARACTERES SUPORTADOS EXPANDIDOS (69 caracteres)
CHARS="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .()\"!?"

# ========== GERAÇÃO DE MAPA SEM COLISÕES ==========
gerar_mapa() {
    local key1="$1"
    declare -A usados
    
    for ((i=0; i<${#CHARS}; i++)); do
        local char="${CHARS:$i:1}"
        local tentativa=0
        local repr=""
        
        # Tenta até encontrar representação única
        while true; do
            local seed=$((key1 * (i+1) * 12345 + tentativa * 9999))
            repr=""
            
            for ((j=0; j<5; j++)); do
                local idx=$(( (seed + j * 1000) % ${#POOL} ))
                repr="${repr}${POOL:$idx:1}"
            done
            
            # Verifica se já foi usado
            if [ -z "${usados[$repr]}" ]; then
                usados[$repr]=1
                break
            fi
            
            ((tentativa++))
            
            # Segurança: se tentar muitas vezes, muda estratégia
            if [ $tentativa -gt 100 ]; then
                # Usa posição direta no pool
                repr=""
                for ((j=0; j<5; j++)); do
                    local idx=$(( (i * 1000 + j + tentativa) % ${#POOL} ))
                    repr="${repr}${POOL:$idx:1}"
                done
                if [ -z "${usados[$repr]}" ]; then
                    usados[$repr]=1
                    break
                fi
                ((tentativa++))
            fi
        done
        
        echo "$char=$repr"
    done
}

# ========== CALCULAR ROTAÇÃO ==========
calcular_rotacao() {
    local key2="$1"
    local pos="$2"
    echo $(( ((key2 % 100) * (pos + 1)) % 5 ))
}

# ========== ROTACIONAR DIREITA ==========
rotacionar_direita() {
    local str="$1"
    local n="$2"
    
    if [ "$n" -eq 0 ]; then
        echo "$str"
    else
        echo "${str:$n}${str:0:$n}"
    fi
}

# ========== ROTACIONAR ESQUERDA ==========
rotacionar_esquerda() {
    local str="$1"
    local n="$2"
    
    if [ "$n" -eq 0 ]; then
        echo "$str"
    else
        local shift=$((5 - n))
        echo "${str:$shift}${str:0:$shift}"
    fi
}

# ========== CRIPTOGRAFIA ==========
criptografar() {
    local texto="$1"
    local k1="$2"
    local k2="$3"

    declare -A mapa
    while IFS='=' read -r chave valor; do
        mapa["$chave"]="$valor"
    done < <(gerar_mapa "$k1")

    local resultado=""
    
    for ((pos=0; pos<${#texto}; pos++)); do
        local char="${texto:$pos:1}"
        
        # Verifica se o caractere é suportado
        if [[ ! "$CHARS" == *"$char"* ]]; then
            # Normalização de caracteres acentuados
            case "$char" in
                á|à|â|ã|ä) char="a" ;;
                é|è|ê|ë) char="e" ;;
                í|ì|î|ï) char="i" ;;
                ó|ò|ô|õ|ö) char="o" ;;
                ú|ù|û|ü) char="u" ;;
                ç) char="c" ;;
                Á|À|Â|Ã|Ä) char="A" ;;
                É|È|Ê|Ë) char="E" ;;
                Í|Ì|Î|Ï) char="I" ;;
                Ó|Ò|Ô|Õ|Ö) char="O" ;;
                Ú|Ù|Û|Ü) char="U" ;;
                Ç) char="C" ;;
                ,) char="." ;;
                \;) char="." ;;
                :) char="." ;;
                -) char=" " ;;
                _) char=" " ;;
                *) char=" " ;;  # Qualquer outro vira espaço
            esac
        fi

        local repr="${mapa[$char]}"
        
        if [ -z "$repr" ]; then
            resultado+="?????"
            continue
        fi
        
        local rot=$(calcular_rotacao "$k2" "$pos")
        local rotacionado=$(rotacionar_direita "$repr" "$rot")
        
        resultado+="$rotacionado"
    done

    echo "S:$resultado"
}

# ========== DESCRIPTOGRAFIA ==========
descriptografar() {
    local cifra="$1"
    local k1="$2"
    local k2="$3"
    
    local cifrado="${cifra:2}"

    declare -A mapa_reverso
    while IFS='=' read -r chave valor; do
        mapa_reverso["$valor"]="$chave"
    done < <(gerar_mapa "$k1")

    local resultado=""
    local pos=0

    for ((i=0; i<${#cifrado}; i+=5)); do
        if [ $((i+5)) -gt ${#cifrado} ]; then
            resultado+="?"
            break
        fi

        local bloco="${cifrado:$i:5}"
        local rot=$(calcular_rotacao "$k2" "$pos")
        local original=$(rotacionar_esquerda "$bloco" "$rot")
        
        if [ -n "${mapa_reverso[$original]}" ]; then
            resultado+="${mapa_reverso[$original]}"
        else
            resultado+="?"
        fi
        
        ((pos++))
    done

    echo "$resultado"
}

# ========== VERIFICAR COLISÕES ==========
verificar_colisoes() {
    local k1="$1"
    
    declare -A reprs
    local total=0
    local colisoes=0
    
    while IFS='=' read -r char repr; do
        ((total++))
        if [ -n "${reprs[$repr]}" ]; then
            echo "COLISÃO: '$char' e '${reprs[$repr]}' = '$repr'"
            ((colisoes++))
        fi
        reprs[$repr]="$char"
    done < <(gerar_mapa "$k1")
    
    echo "Total: $total caracteres, $colisoes colisões"
    return $colisoes
}

# ========== MOSTRAR CARACTERES SUPORTADOS ==========
mostrar_suportados() {
    echo "═══════════════════════════════════════════════"
    echo "CARACTERES SUPORTADOS (69 total):"
    echo "═══════════════════════════════════════════════"
    echo ""
    echo "Letras minúsculas:"
    echo "  a b c d e f g h i j k l m n o p q r s t u v w x y z"
    echo ""
    echo "Letras MAIÚSCULAS:"
    echo "  A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
    echo ""
    echo "Números:"
    echo "  0 1 2 3 4 5 6 7 8 9"
    echo ""
    echo "Caracteres especiais:"
    echo "  [espaço] . ( ) \" ! ?"
    echo ""
    echo "═══════════════════════════════════════════════"
    echo "NORMALIZAÇÕES AUTOMÁTICAS:"
    echo "═══════════════════════════════════════════════"
    echo ""
    echo "Acentos removidos:"
    echo "  á à â ã ä → a"
    echo "  é è ê ë → e"
    echo "  í ì î ï → i"
    echo "  ó ò ô õ ö → o"
    echo "  ú ù û ü → u"
    echo "  ç → c"
    echo ""
    echo "Pontuação convertida:"
    echo "  , ; : → ."
    echo "  - _ → [espaço]"
    echo ""
    echo "Outros caracteres → [espaço]"
    echo "═══════════════════════════════════════════════"
}

# ========== TESTES ==========
testar_completo() {
    echo "🧪 EXECUTANDO TESTES AUTOMÁTICOS"
    echo "=================================="

    # Primeiro, verifica colisões nas chaves de teste
    echo ""
    echo "Verificando colisões nas chaves de teste..."
    for k1 in 123 111 789 333 555 777 999 100 50 1; do
        echo -n "  k1=$k1: "
        verificar_colisoes "$k1" | tail -1
    done

    echo ""
    echo "Testando criptografia/descriptografia..."

    local testes=(
        "oi:123:456"
        "abc:111:222"
        "teste:789:123"
        "123:333:444"
        "A B:555:666"
        "hello:777:888"
        "WORLD:999:111"
        "Ola mundo:100:200"
        "Test 123.:50:75"
        "a:1:1"
        "xyz:999:0"
        "Ola!:200:300"
        "(teste):400:500"
        "Sim ou nao?:600:700"
        "E ai?:700:100"
        "Oi (tudo bem)!:250:350"
    )

    local passaram=0
    local total=${#testes[@]}

    for teste in "${testes[@]}"; do
        IFS=':' read -r texto k1 k2 <<< "$teste"

        echo ""
        echo "▶ Teste: '$texto' (k1=$k1, k2=$k2)"

        local cifra=$(criptografar "$texto" "$k1" "$k2")
        echo "  Cifra: ${cifra:0:50}..." # Mostra só os primeiros 50 chars

        local decifrado=$(descriptografar "$cifra" "$k1" "$k2")
        echo "  Decif: '$decifrado'"

        # Para textos com acentos, normaliza antes de comparar
        local texto_norm="$texto"
        texto_norm="${texto_norm//á/a}"
        texto_norm="${texto_norm//é/e}"
        texto_norm="${texto_norm//í/i}"
        texto_norm="${texto_norm//ó/o}"
        texto_norm="${texto_norm//ú/u}"
        texto_norm="${texto_norm//ã/a}"
        texto_norm="${texto_norm//õ/o}"
        texto_norm="${texto_norm//â/a}"
        texto_norm="${texto_norm//ê/e}"
        texto_norm="${texto_norm//ô/o}"
        texto_norm="${texto_norm//ç/c}"

        if [ "$texto_norm" = "$decifrado" ]; then
            echo "  ✅ PASSOU"
            ((passaram++))
        else
            echo "  ❌ FALHOU (esperado: '$texto_norm', obtido: '$decifrado')"
        fi
    done

    echo ""
    echo "=================================="
    echo "Resultado: $passaram/$total testes passaram"
    echo ""

    [ "$passaram" -eq "$total" ] && return 0 || return 1
}

# ========== INTERFACE ==========
main() {
    clear
    echo "╔════════════════════════════════════════════════╗"
    echo "║  SISTEMA DE CRIPTOGRAFIA HOMOFÔNICA           ║"
    echo "║          Versão Expandida v3.0                ║"
    echo "║   Suporte a: ( ) \" ! ? e mais caracteres     ║"
    echo "╚════════════════════════════════════════════════╝"
    echo ""

    if testar_completo; then
        echo "🎉 TODOS OS TESTES PASSARAM! Sistema validado."
    else
        echo "⚠️  Alguns testes falharam"
        echo ""
        echo -n "Continuar mesmo assim? (s/n): "
        read resposta
        if [ "$resposta" != "s" ] && [ "$resposta" != "S" ]; then
            exit 1
        fi
    fi

    echo ""
    read -p "Pressione ENTER para continuar..."

    while true; do
        clear
        echo "╔════════════════════════════════════════════════╗"
        echo "║              MENU PRINCIPAL                   ║"
        echo "╚════════════════════════════════════════════════╝"
        echo ""
        echo "  [c] Criptografar mensagem"
        echo "  [d] Descriptografar mensagem"
        echo "  [v] Verificar colisões em uma chave"
        echo "  [s] Ver caracteres suportados"
        echo "  [t] Executar testes novamente"
        echo "  [q] Sair"
        echo ""
        echo -n "Escolha: "
        read escolha

        case "$escolha" in
            c)
                clear
                echo "═══ CRIPTOGRAFAR ═══"
                echo ""
                echo -n "Texto: "
                read texto
                
                [ -z "$texto" ] && { echo "❌ Texto vazio!"; sleep 2; continue; }

                echo -n "Key1 (0-999): "
                read k1
                
                [[ ! "$k1" =~ ^[0-9]+$ ]] || [ "$k1" -lt 0 ] || [ "$k1" -gt 999 ] && {
                    echo "❌ Key1 inválida!"; sleep 2; continue; }

                echo -n "Key2 (0-999): "
                read k2
                
                [[ ! "$k2" =~ ^[0-9]+$ ]] || [ "$k2" -lt 0 ] || [ "$k2" -gt 999 ] && {
                    echo "❌ Key2 inválida!"; sleep 2; continue; }

                echo ""
                echo "⏳ Gerando mapa sem colisões..."
                cifra=$(criptografar "$texto" "$k1" "$k2")
                
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "🔐 CIFRADO:"
                echo "$cifra"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo ""
                echo "💡 Dica: Guarde esta cifra e suas chaves!"
                echo ""
                read -p "Pressione ENTER..."
                ;;

            d)
                clear
                echo "═══ DESCRIPTOGRAFAR ═══"
                echo ""
                echo -n "Cifra: "
                read cifra
                
                [ -z "$cifra" ] || [ "${cifra:0:2}" != "S:" ] && {
                    echo "❌ Cifra inválida! Deve começar com 'S:'"; sleep 2; continue; }

                echo -n "Key1: "
                read k1
                
                echo -n "Key2: "
                read k2

                echo ""
                echo "⏳ Descriptografando..."
                texto=$(descriptografar "$cifra" "$k1" "$k2")
                
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "📝 TEXTO DESCRIPTOGRAFADO:"
                echo "$texto"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo ""
                read -p "Pressione ENTER..."
                ;;

            v)
                clear
                echo "═══ VERIFICAR COLISÕES ═══"
                echo ""
                echo -n "Key1 para verificar: "
                read k1
                
                echo ""
                echo "⏳ Verificando..."
                verificar_colisoes "$k1"
                echo ""
                
                if [ $? -eq 0 ]; then
                    echo "✅ Esta chave está segura (sem colisões)!"
                else
                    echo "⚠️  Esta chave tem colisões! Escolha outra."
                fi
                
                echo ""
                read -p "Pressione ENTER..."
                ;;

            s)
                clear
                mostrar_suportados
                echo ""
                read -p "Pressione ENTER..."
                ;;

            t)
                clear
                testar_completo
                echo ""
                read -p "Pressione ENTER..."
                ;;

            q)
                clear
                echo "👋 Até logo!"
                echo ""
                echo "Lembre-se: Suas chaves são secretas!"
                echo "Sem elas, não há como recuperar os dados."
                echo ""
                exit 0
                ;;

            *)
                echo "❌ Opção inválida!"
                sleep 1
                ;;
        esac
    done
}

main
