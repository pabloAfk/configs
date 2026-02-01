IMPORTANTE!! O ESPAÇO É ENTRE 50-59, E NÃO MAIS 27

Cripto.sh - Sistema de Criptografia Alfabética com Chaves
📋 Visão Geral

cripto.sh é um script Bash que implementa um sistema de criptografia simbólica com sistema de duas chaves, convertendo texto em números e vice-versa. A arquitetura utiliza modificadores de bloco e um sistema de chaves para adicionar uma camada de proteção.
🎯 NOVAS CARACTERÍSTICAS

✅ Sistema de 2 chaves (key1 e key2, 0-99 cada)
✅ Criptografia por paridade: key1 para pares, key2 para ímpares
✅ Flags de controle: dígito extra identifica origem (par/ímpar)
✅ Módulo 100: wrap-around seguro (00-99)
🔐 Sistema de Chaves
Como funciona:
text

Texto → Números básicos → Aplicar chaves → Números criptografados

Regras:

    key1 (0-99): Soma aos números PARES (terminam em 0,2,4,6,8)

    key2 (0-99): Soma aos números ÍMPARES (terminam em 1,3,5,7,9)

    Formato final: [valor_criptografado][flag_paridade]

        Flag 0 = veio de número par

        Flag 1 = veio de número ímpar

🔢 Exemplo Completo com Chaves
Entrada: "fi"
Sem chaves: 1609
text

16 (par, termina em 6) + key1(10) = 26 → "260"
09 (ímpar, termina em 9) + key2(2) = 11 → "111"

Resultado com chaves: "260111"
Formato detalhado:
text

26  0  11  1
│  │  │   │
│  │  │   └─ Flag 1 (veio de ímpar: 09)
│  │  └──── Valor criptografado (09+2=11)
│  └─────── Flag 0 (veio de par: 16)
└────────── Valor criptografado (16+10=26)

📊 Esquema de Codificação Original
Caracteres Básicos (a-z)
text

01 = a, 02 = b, ..., 26 = z, 27 = espaço

Pontuação
text

28 = ,    29 = ?    31 = (    32 = )
33 = !    34 = .    35 = :    36 = ;
37 = -    38 = "

Modificadores de Bloco
Código	Função	Comportamento
90	Maiúsculas	Ativa/desativa modo maiúsculas
91	Números	Ativa/desativa modo numérico
92	Acentuados	Ativa/desativa modo acentuado
🔍 Como Funciona a Codificação
1. Primeira fase (texto → números básicos)
text

"Oi" → "90151990"
  90 = abre maiúsculas
  15 = O (maiúsculo)
  09 = i (minúsculo)
  90 = fecha maiúsculas

2. Segunda fase (aplicar chaves)
text

Números básicos: "90151990"
key1 = 10, key2 = 2

90 (par) + 10 = 100 → 00 (módulo 100) → "000"
15 (ímpar) + 2 = 17 → "171"
09 (ímpar) + 2 = 11 → "111"
90 (par) + 10 = 100 → 00 → "000"

Resultado: "000171111000"

🎮 Comandos Disponíveis
Comando	Função
c, -c	Criptografar (texto → números criptografados)
d, -d	Descriptografar (números criptografados → texto)
h, -h, help	Mostrar ajuda
q, -q, quit	Sair
💻 Exemplos de Uso
Criptografar:
text

? c
> fi
Números sem chaves: 1609
key1 (0-99): 10
key2 (0-99): 2
cript: 260111

Descriptografar:
text

? d
> 260111
key1 (0-99): 10
key2 (0-99): 2
decript: fi

🔧 Arquitetura Técnica
Novas Funções:
bash

solicitar_chaves()          # Pede key1 e key2 (0-99)
criptografar_com_chaves()   # Aplica sistema de chaves
descriptografar_com_chaves()# Remove sistema de chaves

Fluxo de Criptografia:

    texto → criptografar_sem_chaves() → números básicos

    Números básicos → criptografar_com_chaves() → números criptografados

Fluxo de Descriptografia:

    Números criptografados → descriptografar_com_chaves() → números básicos

    Números básicos → descriptografar_sem_chaves() → texto

⚙️ Algoritmo de Aplicação de Chaves
Criptografia:
text

Para cada par de 2 dígitos:
  Se último dígito ∈ {0,2,4,6,8}:
    valor = (par + key1) % 100
    resultado += format("%02d", valor) + "0"
  Senão:
    valor = (par + key2) % 100
    resultado += format("%02d", valor) + "1"

Descriptografia:
text

Para cada grupo de 3 dígitos (2 valor + 1 flag):
  Se flag = "0":
    original = (valor_cript - key1) ajusta(0-99)
  Senão:
    original = (valor_cript - key2) ajusta(0-99)

📝 Regras e Limitações
Novas Regras:

    Módulo 100: valores circulam de 99 para 00

    Flags obrigatórias: cada valor criptografado tem flag (0 ou 1)

    Tamanho aumenta: 2 dígitos → 3 dígitos por elemento

Validações:

    Entrada criptografada: múltiplo de 3 dígitos

    Chaves: 0-99 (inclusive)

    Flags: apenas "0" ou "1"

🛡️ Considerações de Segurança
Vantagens:

    Duas chaves independentes

    Paridade preservada via flags

    Módulo 100 previne valores inválidos

    Não determinístico sem as chaves corretas

Limitações:

    Não é criptografia forte (apenas ofuscação)

    Chaves numéricas limitadas (0-99)

    Padrão preservado para mesmo texto com mesmas chaves

🔄 Casos de Borda
Wrap-around:
text

90 + 15 = 105 → 105 % 100 = 05 → "050"

Valores negativos na descriptografia:
text

05 - 15 = -10 → -10 + 100 = 90 → "90"

Chaves extremas:

    key1=0, key2=0: equivalente a não usar chaves

    key1=99, key2=99: máximo deslocamento

📈 Performance
Expansão de tamanho:

    Sem chaves: N caracteres → ~2N dígitos

    Com chaves: N caracteres → ~3N dígitos

Complexidade:

    Tempo: O(n) para criptografia e descriptografia

    Espaço: 50% maior com sistema de chaves

❓ FAQ

P: Posso usar chaves maiores que 99?
R: Não, o sistema usa módulo 100 (00-99).

P: O que acontece se usar chaves erradas?
R: A descriptografia produzirá texto incorreto.

P: É possível reverter sem as chaves?
R: Sim, mas requer análise do padrão de flags.

P: Posso usar o mesmo script sem chaves?
R: Sim, use key1=0 e key2=0.

P: É seguro para dados sensíveis?
R: NÃO. É apenas ofuscação, não criptografia real.
🎨 Exemplo Completo
Texto: "Python é (MUUito) foda tlg? tip0 muuitoooo!!"
Sem chaves: 901690252008151427920501922731901321219009201532270615040127201207292720091691009127132121092015151515333338
Com chaves (10,2): 000171181018161629180703191800171323231018191734181617140519180022091313191800131018191100191191151323231131018171171171171351351480
📚 Versões
Versão	Mudanças
1.0	Sistema básico com blocos
2.0	NOVO: Sistema de 2 chaves com flags de paridade
