-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
--
local map = vim.keymap.set
local user_finder = require("user.finder")
local user_editor = require("user.editor")

-- -------------------------------------------------
-- Clipboard Operations
-- -------------------------------------------------
--
map("n", "<leader>yf", function()
    user_editor.copy_path("file", false)
end, { desc = "Copy absolute file path" })
map("n", "<leader>yF", function()
    user_editor.copy_path("dir", false)
end, { desc = "Copy absolute directory" })
map("n", "<leader>yrf", function()
    user_editor.copy_path("file", true)
end, { desc = "Copy relative file path" })
map("n", "<leader>yrF", function()
    user_editor.copy_path("dir", true)
end, { desc = "Copy relative directory" })

-- -------------------------------------------------
--  Interactive save
-- -------------------------------------------------

vim.keymap.set("n", "<leader>W", user_editor.interactive_save, { desc = "Interactive Save Buffers" })

-- -------------------------------------------------
-- Folder search
-- -------------------------------------------------
map("n", "<leader>fd", user_finder.find_directory, { desc = "Find Directory (Snacks)" })

-- -------------------------------------------------
-- Degugging Operations
-- -------------------------------------------------

-- Variable to store the "Last Used" configuration for this session
local last_debug_config = nil
-- dap ui
-- 1. Restart (Most used)
vim.keymap.set("n", "<leader>dr", function()
    local dap = require("dap")
    dap.restart()
    vim.notify("Restarting Debugger...", vim.log.levels.INFO)
end, { desc = "Debug: Restart Session" })

-- 2. Toggle REPL (Moved to Shift+R)
vim.keymap.set("n", "<leader>dR", function()
    dap.repl.toggle()
end, { desc = "Debug: Toggle REPL" })
