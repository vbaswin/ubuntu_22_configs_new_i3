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
                -- Ctrl+d: Change CWD (Directory)
                ["ctrl-d"] = function(selected)
                    vim.cmd("cd " .. selected[1])
                    vim.notify("Root set to: " .. selected[1])
                end,
            },
        })
    end
    search_folders()
end, { desc = "Find Dir" })

-- selective save of buffers
-- Custom command to interactively save modified buffers
vim.api.nvim_create_user_command("SaveSelect", function()
    local bufs = vim.api.nvim_list_bufs()
    local confirmed = false

    for _, buf in ipairs(bufs) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_get_option_value("modified", { buf = buf }) then
            local name = vim.api.nvim_buf_get_name(buf)
            if name == "" then
                name = "[No Name]"
            end
            local relative_name = vim.fn.fnamemodify(name, ":~:.")

            -- Prompt user
            local choice = vim.fn.confirm("Save changes to " .. relative_name .. "?", "&Yes\n&No\n&Cancel")

            if choice == 1 then -- Yes
                vim.api.nvim_buf_call(buf, function()
                    vim.cmd("write")
                end)
            elseif choice == 3 then -- Cancel
                print("Save aborted.")
                return
            end
            -- If No (2), we just skip to the next buffer
        end
    end
    print("Interactive save complete.")
end, {})

-- Map it to <leader>W (Capital W)
vim.keymap.set("n", "<leader>W", ":SaveSelect<CR>", { desc = "Interactive Save Buffers" })

local dap = require("dap")
local dapui = require("dapui")

-- Variable to store the "Last Used" configuration for this session
local last_debug_config = nil
-- dap ui
-- 1. Restart (Most used)
vim.keymap.set("n", "<leader>dr", function()
    dap.restart()
    vim.notify("Restarting Debugger...", vim.log.levels.INFO)
end, { desc = "Debug: Restart Session" })

-- 2. Toggle REPL (Moved to Shift+R)
vim.keymap.set("n", "<leader>dR", function()
    dap.repl.toggle()
end, { desc = "Debug: Toggle REPL" })
