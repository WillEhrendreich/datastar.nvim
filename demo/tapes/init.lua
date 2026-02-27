-- Minimal init for VHS demo recording
-- Load datastar.nvim from the repo
vim.opt.rtp:prepend('/mnt/c/Code/Repos/datastar.nvim')
require('datastar').setup()
vim.cmd('set number')
vim.cmd('set signcolumn=no')
vim.cmd('set laststatus=0')
vim.cmd('set cmdheight=1')
vim.cmd('set shortmess+=F')
