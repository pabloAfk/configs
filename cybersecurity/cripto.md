Cripto.sh - Sistema de Criptografia Alfabética
📋 Visão Geral

cripto.sh é um script Bash que implementa um sistema de criptografia simbólica, convertendo texto em números e vice-versa. A arquitetura utiliza modificadores de bloco para representar diferentes tipos de caracteres de forma eficiente.
🎯 Características Principais

    Conversão bidirecional: texto ↔ números

    Suporte completo a acentos: á, é, í, ó, ú, ç, ñ, etc.

    Suporte a maiúsculas/minúsculas

    Suporte a números (0-9)

    Pontuação básica: espaço, vírgula, ponto, etc.

    Arquitetura baseada em blocos para economia de espaço

🔢 Esquema de Codificação
Caracteres Básicos (a-z)

    01 = a

    02 = b

    ...

    26 = z

    27 = espaço

Pontuação

    28 = ,

    29 = ?

    31 = (

    32 = )

    33 = !

    34 = .

    35 = :

    36 = ;

    37 = -

    38 = "

Modificadores de Bloco
Código	Função	Comportamento
90	Maiúsculas	Ativa/desativa modo maiúsculas
91	Números	Ativa/desativa modo numérico
92	Acentuados	Ativa/desativa modo acentuado

🔍 Como Funciona a Codificação
1. Letras Simples
text

"oi" → "1509"
  o = 15
  i = 09

2. Maiúsculas (Modo Bloco)
text

"Oi" → "90151990"
  90 = abre bloco maiúsculas
  15 = O (maiúsculo)
  09 = i (minúsculo, bloco ainda ativo)
  90 = fecha bloco maiúsculas

3. Números (Modo Bloco)
text

"123" → "91000102030991"
  91 = abre bloco numérico
  00 = 0 (zero)
  01 = 1
  02 = 2
  03 = 3
  09 = 9
  91 = fecha bloco numérico

4. Caracteres Acentuados (Modo Bloco)
text

"é" → "92050192"
  92 = abre bloco acentuado
  05 = e (letra base)
  01 = agudo (tipo de acento)
  92 = fecha bloco acentuado

5. Texto Complexo
text

"São Paulo" → "9019009201150392152730901601211509027"
  90 = abre maiúsculas
  19 = S (maiúsculo)
  90 = fecha maiúsculas
  92 = abre acentuado
  00 = a (base)
  03 = til
  19 = o (base)
  15 = agudo
  92 = fecha acentuado
  27 = espaço
  90 = abre maiúsculas
  16 = P (maiúsculo)
  90 = fecha maiúsculas
  01 = a
  21 = u
  12 = l
  15 = o
  90 = abre maiúsculas (vazio)
  27 = espaço

Comandos Disponíveis
Comando	Função
c,       -c	Criptografar (texto → números)
d,       -d	Descriptografar (números → texto)
h,       -h, help	Mostrar ajuda
q,       -q, quit	Sair

Exemplos de Uso

Criptografar:
text

? c
> Olá Mundo!
📤 901512920112039227092215211415902733

Descriptografar:
text

? d
> 901512920112039227092215211415902733
📥 Olá Mundo!

🔧 Arquitetura Técnica
Estrutura do Código
bash

# Mapeamento de acentos
mapear_acentuado()    # Converte caractere acentuado em "base acento"
acento_para_numero()  # Converte tipo de acento em código numérico
numero_para_acento()  # Converte código numérico em tipo de acento
aplicar_acento()      # Aplica acento a uma letra base

# Funções principais
criptografar()       # Converte texto em números
descriptografar()    # Converte números em texto

Algoritmo de Criptografia

    Percorre cada caractere da entrada

    Detecta o tipo de caractere (minúscula, maiúscula, número, acentuado, pontuação)

    Gerencia blocos abertos/fechados automaticamente

    Converte para a representação numérica apropriada

Estados Gerenciados

    em_maiusculas: 0/1 - Bloco de maiúsculas ativo

    em_numeros: 0/1 - Bloco numérico ativo

    em_acentuados: 0/1 - Bloco acentuado ativo

📝 Regras e Limitações
Regras de Codificação

    Blocos são simétricos: 90 abre E fecha maiúsculas

    Números em bloco: 00-09 representam dígitos 0-9

    Acentos usam 4 dígitos: 2 para letra base + 2 para tipo de acento

    Blocos são fechados automaticamente no final

Caracteres Suportados

    ✅ Todas letras do alfabeto (a-z, A-Z)

    ✅ Números (0-9)

    ✅ Acentos latinos básicos

    ✅ Pontuação comum

    ❌ Caracteres especiais (@, #, $, %, etc.) são ignorados

Validações

    Entrada de números deve ter quantidade PAR de dígitos

    Blocos acentuados requerem 4 dígitos (base + acento)

    Blocos desbalanceados geram avisos

    🎨 Exemplos Completos
Exemplo 1: Nome com acento
text

Entrada: "João"
Saída: "901010920115039292"
Decodificação:
  90 = abre maiúsculas
  10 = J
  90 = fecha maiúsculas
  92 = abre acentuado
  00 = a (base)
  03 = til
  15 = o (base)
  15 = agudo
  92 = fecha acentuado

Exemplo 2: Endereço
text

Entrada: "Rua 123, Centro"
Saída: "901809012791000102032890021514201815"

Exemplo 3: Pergunta
text

Entrada: "Como vai?"
Saída: "03151315271522010929"

🔄 Casos de Borda
Maiúsculas Isoladas
text

"A" → "90190"
  (abre maiúsculas, converte, fecha maiúsculas)

Sequência Mista
text

"Aa" → "9010190"
  (abre maiúsculas, A=01, fecha maiúsculas, a=01)

Caracteres Não Suportados
text

"a@b" → "01[AVISO]02"
  (@ é ignorado, aviso no stderr)

📈 Considerações de Performance
Vantagens

    Representação compacta: blocos reduzem repetição de códigos

    Decodificação determinística: sem ambiguidades

    Fácil implementação: apenas operações de string

Desvantagens

    Overhead para textos curtos: blocos adicionam dígitos extras

    Não criptográfico: apenas codificação, não segurança real

    ASCII apenas: suporte limitado a caracteres latinos básicos

    📚 Glossário
Termo	Definição
Bloco	Sequência delimitada por modificadores
Modificador	Código especial (90, 91, 92) que muda o estado
Letra base	Letra sem acento (a, e, i, o, u, c, n)
Tipo de acento	Classificação do diacrítico (agudo, grave, etc.)

❓ FAQ

P: É uma criptografia segura?
R: Não, é apenas uma codificação/decodificação. Não use para dados sensíveis.

P: Posso usar em outros idiomas?
R: Apenas idiomas com caracteres latinos básicos (português, espanhol, francês, etc.)

P: Como lido com erros?
R: O script mostra avisos no stderr e tenta continuar a processar.

P: Posso modificar a codificação?
R: Sim, edite os mapeamentos nas funções no início do script.
