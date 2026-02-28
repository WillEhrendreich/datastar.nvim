-- Demo init for VHS recording
-- Loads the user's full config, then applies demo-friendly overrides
dofile(vim.fn.stdpath("config") .. "/init.lua")

-- Demo overrides: clean UI for recording
vim.opt.signcolumn = "no"
vim.opt.laststatus = 0
vim.opt.cmdheight = 1
vim.opt.shortmess:append("F")
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.swapfile = false
