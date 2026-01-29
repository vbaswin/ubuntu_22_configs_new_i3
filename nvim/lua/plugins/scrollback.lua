return {
    {
        "mikesmithgh/kitty-scrollback.nvim",
        enabled = true,
        lazy = true,
        cmd = { "KittyScrollbackGenerateKittens", "KittyScrollbackCheckHealth" },
        event = { "User KittyScrollbackLaunch" },
        config = function()
            local ksb_api = require("kitty-scrollback.api")

            require("kitty-scrollback").setup({
                paste_window = {
                    yank_register_enabled = false,
                    yank_register = "z", -- Obscure register we never use
                },
                keymaps_enabled = false, -- Disable plugin's default keymaps
                visual_selection_highlight_mode = "nvim",

                callbacks = {
                    after_ready = function(kitty_data, opts)
                        -- Visual mode: yank to UNNAMED register, then copy via OSC52
                        vim.keymap.set({ "v", "x" }, "y", function()
                            vim.cmd("normal! y")
                            local lines = vim.fn.getreg('"', 1, true)
                            require("vim.ui.clipboard.osc52").copy("+")(lines)
                        end, {
                            buffer = true,
                            desc = "Yank to clipboard (stay in scrollback)",
                        })

                        -- Yank AND close (when you want original behavior)
                        vim.keymap.set({ "v", "x" }, "<CR>", function()
                            vim.cmd('normal! "+y')
                        end, {
                            buffer = true,
                            desc = "Yank to clipboard and close scrollback",
                        })

                        -- Normal mode: 'q' to quit
                        vim.keymap.set("n", "q", function()
                            ksb_api.close_or_quit_all()
                        end, {
                            buffer = true,
                            desc = "Close scrollback buffer",
                        })
                    end,
                },
            })

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
