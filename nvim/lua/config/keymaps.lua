-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>yf", function()
  local file = vim.fn.expand("%:p")
  vim.fn.setreg("+", file)
  vim.notify("Copied file path")
end, { desc = "Copy file path" })

vim.keymap.set("n", "<leader>yF", function()
  local dir = vim.fn.expand("%:p:h")
  vim.fn.setreg("+", dir)
  vim.notify("Copied file directory")
end, { desc = "Copy file directory" })

vim.keymap.set("n", "<leader>yrf", function()
  local file = vim.fn.expand("%:p")
  local rel = vim.fn.fnamemodify(file, ":.")
  vim.fn.setreg("+", rel)
  vim.notify("Copied file path (relative)")
end, { desc = "Copy file path (relative to CWD)" })

vim.keymap.set("n", "<leader>yrF", function()
  local dir = vim.fn.expand("%:p:h")
  local rel = vim.fn.fnamemodify(dir, ":.")
  vim.fn.setreg("+", rel)
  vim.notify("Copied file directory (relative)")
end, { desc = "Copy file directory (relative to CWD)" })
