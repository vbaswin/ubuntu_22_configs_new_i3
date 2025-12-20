return {
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPre", "BufNewFile" },
        build = ":TSUpdate",
        branch = "master", -- [!IMPORTANT] Fixes the 'module not found' error
        config = function()
            local treesitter = require("nvim-treesitter.configs")
            treesitter.setup({
                highlight = { enable = true },
                indent = { enable = true },
                ensure_installed = {
                    "json", "javascript", "typescript", "tsx", "go", "yaml", "html", "css",
                    "python", "bash", "lua", "vim", "dockerfile", "gitignore", "c", "rust",
                    -- Added for Qt/C++:
                    "cpp", "qmljs", 
                },
            })
        end,
    },
    -- Autotag setup remains the same...
    {
        "windwp/nvim-ts-autotag",
        enabled = true,
        ft = { "html", "xml", "javascript", "typescript", "javascriptreact", "typescriptreact", "svelte" },
        config = function()
            require("nvim-ts-autotag").setup({ opts = { enable_close = true, enable_rename = true } })
        end,
    },
}
