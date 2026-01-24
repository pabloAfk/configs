# 🛡️ DYSTOOLS - Resgate de Binários

**Backup portátil de binários busybox com prefixo 'd' para diagnóstico e recuperação após infecção**

## 🚀 RESUMO RÁPIDO

### **Para quem é isso?**
imagine que um invasor altere os binários estáticos do seu busybox, ou seja:
- `ls` não mostra todos os arquivos
- `ps` não mostra processos suspeitos  
-  binários do sistema foram trocados

### **O que faz?**
1. **modo Backup**: Copia `ls`, `ps`, `grep` etc do sistema SAUDÁVEL para pendrive (como `dls`, `dps`, `dgrep`)
2. **modo Resgate**: Quando sistema está corrompido, troca o PATH e o computador usa os binários SEGUROS criados com o backup  que estão no pendrive
3. **você pode fazer uma Reparação**: Restaurar binários corrompidos usando cópias limpas

## 🎯 MODOS DE USO
1. **backup - Cria backup (sistema LIMPO)**

sudo ./dystools.sh /caminho/até/o/pendrive backup

Quando usar: Sistema 100% confiável, primeira vez
O que faz: Copia binários do sistema → pendrive
CUIDADO: Não use se suspeita de infecção!

2. **rescue - Modo resgate (sistema CORROMPIDO)**

sudo ./dystools.sh /caminho/até/o/pendrive rescue

Quando usar: Sistema estranho, possivelmente infectado
O que faz: Configura PATH para usar binários do pendrive
SEGURO: Não copia NADA do sistema, apenas faz o sistema usar os binários saudáveis do pendrive
ps: pra voltar a usar os do sistema é só fechar o terminal e abir outro

3. **busybox - BusyBox universal**

sudo ./dystools.sh /caminho/até/o/pendrive busybox

Quando usar: Não confia no sistema OU quer algo pequeno/universal
O que faz: Baixa BusyBox estático (1MB, funciona em qualquer Linux)**
