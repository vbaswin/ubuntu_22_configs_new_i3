return {
    {
        "nvim-mini/mini.files",
        keys = {
            {
                "gc",
                false,
            },
            {
                "gC",
                function()
                    local MiniFiles = require("mini.files")

                    local buf_name = vim.api.nvim_buf_get_name(0)

                    local path = vim.fn.filereadable(buf_name) == 1 and buf_name or nil
                    vim.notify("Opening Mini files...", vim.log.levels.INFO)
                    local new_cmd = MiniFiles.get_fs_entry().path()
                    vim.notify("Opening Mini files...", vim.log.levels.INFO)
                    vim.notify("new_cwd: " .. new_cmd)
                    vim.fn.chdir(new_cmd)

                    MiniFiles.open(new_cmd, true)
                end,
                desc = "Open Mini Files (Buffer Directory)",
            },
            init = function()
                vim.schedule(function()
                    pcall(vim.keymap.del, "n", "<leader>gc")
                end)
            end,
        },
    },
}
