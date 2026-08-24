#!/usr/bin/env bash

# bat.fish
echo "function bat --wraps='watch -n 1 acpi' --description 'alias bat watch -n 1 acpi'
  watch -n 1 acpi \$argv
end" > bat.fish

# checkup.fish
echo "function checkup --wraps='sudo pacman -Syu && flatpak update && paru' --description 'alias checkup'
  sudo pacman -Syu && flatpak update && paru \$argv
end" > checkup.fish

# ff.fish
echo "function ff --wraps=fastfetch --description 'alias ff fastfetch' 
  fastfetch \$argv
end" > ff.fish

# fx.fish
echo "function fx --wraps=firefox --description 'alias fx firefox'
  firefox \$argv
end" > fx.fish

# x.fish
echo "function x --wraps='nohup picom &>/dev/null &' --description 'alias x nohup picom &>/dev/null &'
  nohup picom &>/dev/null & \$argv
end" > x.fish


#exclude.fish, sb.fish, pg.fish, fx.fish, e.fish

