-- 1. Instala o gerenciador de plugins (lazy.nvim) automaticamente
-- 
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 2. Configura os plugins
require("lazy").setup({
  -- A barrinha lateral (File Explorer)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
    end
  },

  -- A tela inicial personalizada
  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    config = function()
      require('dashboard').setup({
        theme = 'hyper', -- Um tema bonito e moderno
        config = {
          header = { 'NEOVIM' }, -- Você pode colocar uma arte ASCII aqui
          shortcut = {
            { desc = '󰊄 Arquivos Recentes', group = '@property', action = 'Telescope oldfiles', key = 'r' },
            { desc = '󰈞 Buscar Arquivo', group = 'Label', action = 'Telescope find_files', key = 'f' },
          },
        },
      })
    end,
    dependencies = { {'nvim-tree/nvim-web-devicons'}}
  }
})

-- 3. Atalhos rápidos
vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>') -- Abre/fecha a barra com Ctrl + n
