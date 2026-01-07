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
end, { desc = "Copy fil< directory (relative to CWD)" })

-- directory fuzzy searching

vim.keymap.set("n", "<leader>fd", function()
    local status_fzf, fzf = pcall(require, "fzf-lua")
    if not status_fzf then
        vim.notify("Fzf-lua is not installed/loaded!", vim.log.levels.ERROR)
        return
    end

    local status_mini, mini = pcall(require, "mini.files")
    if not status_mini then
        vim.notify("Mini.files is not installed/enabled! Enable it in :LazyExtras", vim.log.levels.ERROR)
        return
    end

    local cwd = vim.fn.getcwd()
    local cmd = "fd --type d --hidden --follow -a ."
    local function search_folders()
        Snacks.debug(cwd)

        local prompt_title = "Dirs (" .. vim.fn.fnamemodify(cwd, ":~") .. ")> "

        fzf.fzf_exec(cmd, {
            prompt = prompt_title,
            cwd = cwd,
            actions = {
                ["default"] = function(selected)
                    mini.open(selected[1])
                end,
                ["ctrl-h"] = function(selected)
                    cwd = vim.env.HOME
                    search_folders()
                end,
            },
        })
    end
    search_folders()
end, { desc = "Find Dir" })
