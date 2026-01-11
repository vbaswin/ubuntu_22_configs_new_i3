-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- ~/.config/nvim/lua/user/options.lua

local o = vim.opt

o.tabstop = 4 -- a real tab is 4 columns wide
o.shiftwidth = 4 -- indentation level for >> and autoindent
o.softtabstop = 4 -- editing: insert/delete behaves like 4
o.expandtab = true -- USE TABS (do not convert tabs to spaces)
o.wrap = false
o.textwidth = 0
