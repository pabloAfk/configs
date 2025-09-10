-- =========================
-- Init.lua Hacker Tryhard
-- =========================

-- Bootstrapping do Packer
vim.cmd [[packadd packer.nvim]]

require('packer').startup(function(use)
  -- Gerenciador de plugins
  use 'wbthomason/packer.nvim'

  -- Tema hacker
  use 'EdenEast/nightfox.nvim'

  -- Linha de status
  use 'nvim-lualine/lualine.nvim'

  -- Ícones
  use 'nvim-tree/nvim-web-devicons'

  -- Auto pares () [] {}
  use 'windwp/nvim-autopairs'

  -- File explorer com preview
  use 'kyazdani42/nvim-tree.lua'

  -- Abas estilo GUI
  use 'akinsho/bufferline.nvim'

  -- LSP e completions
  use { 'neovim/nvim-lspconfig' }
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'L3MON4D3/LuaSnip'

  -- Highlight de sintaxe avançado
  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}

  -- Greeter inicial
  use 'goolord/alpha-nvim'
end)

-- =========================
-- Configurações Gerais
-- =========================

vim.o.termguicolors = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.showmode = false

-- Tema
vim.cmd('colorscheme nightfox')

-- Lualine
require('lualine').setup {
  options = {
    theme = 'nightfox',
    section_separators = '',
    component_separators = ''
  }
}

-- Bufferline
require('bufferline').setup {
  options = {
    diagnostics = "nvim_lsp",
    separator_style = "slant"
  }
}

-- Nvim-tree
require('nvim-tree').setup {
  view = { width = 30 },
  renderer = { icons = { show = { file = true, folder = true } } }
}

-- Auto-pares
require('nvim-autopairs').setup{}

-- Treesitter
require('nvim-treesitter.configs').setup {
  highlight = { enable = true },
  ensure_installed = { "lua", "python", "javascript", "html", "css", "bash" }
}

-- LSP Setup (exemplo com pyright)
local lspconfig = require('lspconfig')
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
})

lspconfig.pyright.setup{}

-- =========================
-- Alpha (Greeter Hacker)
-- =========================
local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

-- ASCII art hacker
dashboard.section.header.val = {
  [[                                                     ]],
  [[   ███╗   ██╗███████╗██╗   ██╗██╗███╗   ███╗         ]],
  [[   ████╗  ██║██╔════╝██║   ██║██║████╗ ████║         ]],
  [[   ██╔██╗ ██║█████╗  ██║   ██║██║██╔████╔██║         ]],
  [[   ██║╚██╗██║██╔══╝  ╚██╗ ██╔╝██║██║╚██╔╝██║         ]],
  [[   ██║ ╚████║███████╗ ╚████╔╝ ██║██║ ╚═╝ ██║         ]],
  [[   ╚═╝  ╚═══╝╚══════╝  ╚═══╝  ╚═╝╚═╝     ╚═╝         ]],
  [[                                                     ]],
}

-- Botões de atalho
dashboard.section.buttons.val = {
  dashboard.button("e", "  Novo arquivo", ":ene <BAR> startinsert <CR>"),
  dashboard.button("f", "󰈞  Procurar arquivo", ":Telescope find_files<CR>"),
  dashboard.button("r", "󰄉  Recentes", ":Telescope oldfiles<CR>"),
  dashboard.button("q", "󰅚  Sair", ":qa<CR>"),
}

-- Mensagem no rodapé
dashboard.section.footer.val = "🚀 Bem-vindo ao seu Neovim"

alpha.setup(dashboard.opts)
