return {
    {
        "mikesmithgh/kitty-scrollback.nvim",
        enabled = true,
        lazy = true,
        cmd = { "KittyScrollbackGenerateKittens", "KittyScrollbackCheckHealth" },
        event = { "User KittyScrollbackLaunch" },
        config = function()
            require("kitty-scrollback").setup({
                -- Ensure the paste window uses the correct register
                paste_window = {
                    yank_register_enabled = true, -- Enable yanking to paste window
                    yank_register = "+", -- Use system clipboard register
                },
                -- Keymaps (these are defaults, shown for clarity)
                keymaps_enabled = true,
                -- Visual feedback that operations succeeded
                visual_selection_highlight_mode = "nvim",
            })

            -- Force OSC 52 clipboard when inside kitty-scrollback
            -- This ensures "+y works correctly
            vim.g.clipboard = {
                name = "OSC 52 (kitty-scrollback)",
                copy = {
                    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
                    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
                },
                paste = {
                    ["+"] = function()
                        return {}
                    end,
                    ["*"] = function()
                        return {}
                    end,
                },
            }
        end,
    },
}
