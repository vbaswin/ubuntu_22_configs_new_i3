-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- lua/config/autocmds.lua

vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("restore_session", { clear = true }),
    nested = true,
    callback = function()
        -- Only load the session if nvim was started with no arguments
        if vim.fn.argc() == 0 then
            -- safe require in case persistence is disabled or not installed
            local ok, persistence = pcall(require, "persistence")
            if ok then
                persistence.load()
            end
        end
    end,
})
