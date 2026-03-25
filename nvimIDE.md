thats a dotfile copy im using as IDE

mkdir -p ~/.config/nvim

cd ~/.config/nvim

# 1. Clonar o repositório (estamos baixando o branch 'macos')
git clone -b macos https://github.com/pgosar/dotfiles.git /tmp/dotfiles_temp

# 2. Copiar o conteúdo da pasta nvim para o seu diretório de config
cp -rv /tmp/dotfiles_temp/config/nvim/* ~/.config/nvim/

# 3. Limpar a pasta temporária
rm -rf /tmp/dotfiles_temp
