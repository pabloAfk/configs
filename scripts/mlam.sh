#chmod 700
#!/bin/bash
clear
font="italic"

# As frases
frases=(
"moon tell me if i could"
"send up my heart to you"
"so when i die wich i must do"
"could it shine down here with you"
"cause my love is mine all mine"
"my love mine mine mine"
"nothing in the world belongs to me"
"but my love mine all mine all mine"
)

# Tempo de exibição pra cada frase (em segundos)
delays=(3.7 3.7 3.7 4.5 4.2 4.3 4.3 4)

# Loop com índice pra usar o delay correspondente
for ((i=0; i<${#frases[@]}; i++)); do
 #clear
  frase="${frases[i]}"
  delay="${delays[i]}"
  
  # Mostra a frase em figlet, tenta italic e se não existir usa slant
  figlet -f "$font" "$frase" 2>/dev/null || figlet -f slant "$frase"
  
  echo ""  # espaço visual
  echo ""
  echo ""
  echo "" 
  echo ""
  sleep "$delay"
done
