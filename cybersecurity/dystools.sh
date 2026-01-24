#!/bin/bash
# dystools.sh - Backup/Restauração
# Modo 1: Backup (sistema saudável) → copia binários
# Modo 2: Restauração (sistema corrompido) → só configura PATH
# Modo 3: BusyBox → Baixa binário estático universal

PENDRIVE="$1"
if [ -z "$PENDRIVE" ]; then
    echo "Uso: $0 /caminho/do/pendrive [modo]"
    echo "Modos:"
    echo "  backup    - Copia binários atuais (sistema saudável)"
    echo "  rescue    - Usa backup existente (sistema corrompido)"
    echo "  busybox   - Instala BusyBox estático (universal)"
    echo "  auto      - Detecta automaticamente (padrão)"
    echo "  force     - Força novo backup (PERIGO: sobrescreve!)"
    exit 1
fi

MODO="${2:-auto}"
DBIN_DIR="$PENDRIVE/dbin"
BACKUP_FLAG="$DBIN_DIR/.backup_seguro"

# ============================================
# FUNÇÃO: Modo BACKUP (copia do sistema → pendrive)
# ============================================
backup_mode() {
    echo "🔒 MODO BACKUP - Copiando binários ORIGINAIS"
    echo "Execute apenas se confia 100% no sistema atual"
    echo ""
    
    # PROTEÇÃO: Verificar se já existe backup
    if [ -f "$BACKUP_FLAG" ]; then
        echo "❌ ERRO: Pendrive já tem backup seguro!"
        echo "   Data: $(cat "$DBIN_DIR/.backup_date" 2>/dev/null || echo "DESCONHECIDA")"
        echo ""
        echo "⚠️  Para evitar sobrescrever backup bom:"
        echo "   1) Use modo 'rescue' para usar backup existente"
        echo "   2) Use modo 'busybox' para alternativa"
        echo "   3) Renomeie backup atual: mv $DBIN_DIR ${DBIN_DIR}_backup"
        echo ""
        echo "Se TEM CERTEZA que quer sobrescrever:"
        read -p "   Digite 'SOBRESCREVER-PERIGO': " CONFIRM
        if [ "$CONFIRM" != "SOBRESCREVER-PERIGO" ]; then
            echo "Cancelado por segurança."
            exit 1
        fi
        echo "Removendo backup antigo..."
        rm -rf "$DBIN_DIR"
    fi
    
    read -p "Continuar com backup? (digite 'CONFIRMAR'): " CONFIRM
    if [ "$CONFIRM" != "CONFIRMAR" ]; then
        echo "Cancelado. Use modo 'rescue' se sistema pode estar infectado."
        exit 0
    fi
    
    # Cria diretório
    mkdir -p "$DBIN_DIR"
    
    # Lista de comandos críticos
    COMANDOS="ls ps grep cp mv rm cat echo find chmod chown kill mount df du ping ssh scp wget curl"
    
    echo "Criando backup seguro..."
    CONTADOR=0
    for cmd in $COMANDOS; do
        if which "$cmd" >/dev/null 2>&1; then
            BIN_PATH=$(which "$cmd")
            if cp -p "$BIN_PATH" "$DBIN_DIR/d$cmd" 2>/dev/null; then
                echo "  ✓ $cmd → d$cmd"
                CONTADOR=$((CONTADOR + 1))
            fi
        fi
    done
    
    # Salvar hashes para verificação futura
    echo "Gerando hashes de verificação..."
    for dcmd in "$DBIN_DIR"/d*; do
        if [ -f "$dcmd" ]; then
            md5sum "$dcmd" >> "$DBIN_DIR/.backup_hashes.md5" 2>/dev/null
        fi
    done
    
    # Marca pendrive como "backup seguro"
    touch "$BACKUP_FLAG"
    date > "$DBIN_DIR/.backup_date"
    echo "Backup criado do sistema: $(uname -a)" > "$DBIN_DIR/.backup_source"
    
    echo ""
    echo "✅ BACKUP COMPLETO"
    echo "Comandos copiados: $CONTADOR"
    echo "Pendrive agora contém backup seguro dos binários."
    echo "Use 'rescue' se suspeitar de infecção."
    echo ""
    echo "Hashes salvos em: $DBIN_DIR/.backup_hashes.md5"
    echo "(Guarde esses hashes para verificação futura)"
}

# ============================================
# FUNÇÃO: Modo BUSYBOX (instala estático universal)
# ============================================
busybox_mode() {
    echo "📦 MODO BUSYBOX - Instalando binário estático universal"
    echo "Ideal para: máximo portabilidade, mínimo espaço"
    echo ""
    
    # Verificar internet
    if ! ping -c1 -W2 8.8.8.8 >/dev/null 2>&1; then
        echo "⚠️  Sem internet. BusyBox já instalado?"
        if [ -f "$DBIN_DIR/busybox" ]; then
            echo "✓ BusyBox encontrado, configurando..."
        else
            echo "❌ Sem internet e BusyBox não encontrado."
            echo "   Conecte à internet ou use modo 'rescue'."
            exit 1
        fi
    fi
    
    mkdir -p "$DBIN_DIR"
    
    # Baixar BusyBox estático
    echo "Baixando BusyBox estático..."
    if wget -q -O "$DBIN_DIR/busybox.tmp" \
       "https://busybox.net/downloads/binaries/1.35.0-x86_64-linux-musl/busybox"; then
        mv "$DBIN_DIR/busybox.tmp" "$DBIN_DIR/busybox"
        chmod +x "$DBIN_DIR/busybox"
        
        # Criar links
        echo "Criando links com prefixo 'd'..."
        "$DBIN_DIR/busybox" --list | while read cmd; do
            ln -sf busybox "$DBIN_DIR/d$cmd" 2>/dev/null
            echo -n "."
        done
        echo ""
        
        # Marcar como BusyBox
        echo "BusyBox estático 1.35.0" > "$DBIN_DIR/.backup_source"
        date > "$DBIN_DIR/.backup_date"
        touch "$BACKUP_FLAG"
        
        echo ""
        echo "✅ BUSYBOX INSTALADO"
        echo "Comandos disponíveis: $("$DBIN_DIR/busybox" --list | wc -l)"
        echo "Tamanho: $(du -h "$DBIN_DIR/busybox" | cut -f1)"
        echo "Use: dls, dps, dgrep, etc."
    else
        echo "❌ Falha ao baixar BusyBox"
        exit 1
    fi
}

# ============================================
# FUNÇÃO: Modo RESCUE (só usa pendrive, NÃO copia)
# ============================================
rescue_mode() {
    echo "🆘 MODO RESGATE - Usando backup seguro"
    echo "Assumindo sistema possivelmente corrompido"
    echo ""
    
    if [ ! -f "$BACKUP_FLAG" ]; then
        echo "❌ AVISO: Pendrive não tem backup seguro!"
        echo ""
        echo "Opções:"
        echo "   1) Se sistema atual está SAUDÁVEL: $0 $PENDRIVE backup"
        echo "   2) Instalar BusyBox universal: $0 $PENDRIVE busybox"
        echo "   3) Usar Live USB limpo para criar backup"
        exit 1
    fi
    
    echo "✅ Backup seguro detectado"
    if [ -f "$DBIN_DIR/.backup_source" ]; then
        echo "Fonte: $(cat "$DBIN_DIR/.backup_source")"
    fi
    if [ -f "$DBIN_DIR/.backup_date" ]; then
        echo "Data: $(cat "$DBIN_DIR/.backup_date")"
    fi
    echo ""
    
    # Configura PATH
    export PATH="$DBIN_DIR:$PATH"
    
    # Verificar se é BusyBox ou binários separados
    if [ -f "$DBIN_DIR/busybox" ]; then
        echo "📦 Tipo: BusyBox estático"
        echo "Comandos disponíveis:"
        "$DBIN_DIR/busybox" --list | sort | column
    else
        echo "💾 Tipo: Binários separados"
        echo "Comandos disponíveis:"
        ls "$DBIN_DIR"/d* 2>/dev/null | xargs -n1 basename | sort | column
    fi
    
    echo ""
    echo "🚀 Para usar agora: dls, dps, dgrep, etc."
    echo "💡 Adicione ao PATH: export PATH=\"$DBIN_DIR:\$PATH\""
}

# ============================================
# FUNÇÃO: Modo AUTO (detecta automaticamente)
# ============================================
auto_mode() {
    if [ -f "$BACKUP_FLAG" ]; then
        echo "✅ Pendrive já tem backup seguro"
        echo "Usando modo RESCUE (não copia do sistema)"
        rescue_mode
    else
        echo "⚠️  Pendrive vazio ou sem backup seguro"
        echo ""
        echo "Opções disponíveis:"
        echo "   1) backup   - Copiar binários atuais (se sistema 100% saudável)"
        echo "   2) busybox  - Instalar BusyBox estático (universal/seguro)"
        echo "   3) rescue   - Sair (não fazer nada)"
        echo ""
        read -p "Escolha (1-3): " ESCOLHA
        
        case "$ESCOLHA" in
            1)
                backup_mode
                ;;
            2)
                busybox_mode
                ;;
            *)
                echo "Cancelado."
                exit 0
                ;;
        esac
    fi
}

# ============================================
# FUNÇÃO: Modo FORCE (sobrescreve - PERIGOSO)
# ============================================
force_mode() {
    echo "💀 MODO FORÇADO - SOBRESCREVENDO BACKUP EXISTENTE"
    echo "⚠️  ⚠️  ⚠️  PERIGO: Isso apagará backup existente! ⚠️ ⚠️ ⚠️"
    echo ""
    
    if [ -f "$BACKUP_FLAG" ]; then
        echo "Backup atual será APAGADO:"
        if [ -f "$DBIN_DIR/.backup_source" ]; then
            echo "  Fonte: $(cat "$DBIN_DIR/.backup_source")"
        fi
        if [ -f "$DBIN_DIR/.backup_date" ]; then
            echo "  Data: $(cat "$DBIN_DIR/.backup_date")"
        fi
    fi
    
    echo ""
    read -p "Digite 'CONFIRMO-SOBRESCREVER-PERIGO': " CONFIRM
    if [ "$CONFIRM" != "CONFIRMO-SOBRESCREVER-PERIGO" ]; then
        echo "Cancelado por segurança."
        exit 1
    fi
    
    rm -rf "$DBIN_DIR"
    backup_mode
}

# ============================================
# EXECUÇÃO PRINCIPAL
# ============================================
case "$MODO" in
    backup|Backup|BACKUP)
        backup_mode
        ;;
    rescue|Rescue|RESCUE)
        rescue_mode
        ;;
    busybox|BusyBox|BUSYBOX)
        busybox_mode
        ;;
    auto|Auto|AUTO|"")
        auto_mode
        ;;
    force|Force|FORCE)
        force_mode
        ;;
    *)
        echo "Modo inválido: $MODO"
        echo "Use: backup, rescue, busybox, auto ou force"
        exit 1
        ;;
esac
