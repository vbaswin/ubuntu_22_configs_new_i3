local M = {}

-- Opens a directory picker using Snacks.nvim
-- @param cwd string|nil Optional starting directory
function M.find_directory(cwd)
    if not Snacks or not Snacks.picker then
        vim.notify("Snacks.picker not available.", vim.log.levels.ERROR)
        return
    end

    local function pick_dirs(current_cwd)
        current_cwd = vim.fn.expand(current_cwd or vim.fn.getcwd())
        vim.notify("cwd: " .. current_cwd)

        Snacks.picker.files({
            cwd = current_cwd,
            cmd = "fd",
            args = {
                "--hidden",
                "--follow",
                "--exclude",
                ".git",
                "--type",
                "d",
            },

            title = "   " .. vim.fn.fnamemodify(current_cwd, ":~") .. " > ",

            actions = {
                confirm = function(picker, item)
                    picker:close()
                    if item then
                        local path = vim.fn.simplify(current_cwd .. "/" .. item.text)
                        if vim.fn.isdirectory(path) == 1 then
                            --Snacks.picker.files({ cwd = item.file })
                            pick_dirs(path)
                        else
                            vim.cmd("edit " .. vim.fn.fnameescape(path))
                        end
                    end
                end,

                open_mini = function(picker, item)
                    picker:close()
                    if item then
                        local path = vim.fn.simplify(current_cwd .. "/" .. item.text)
                        require("mini.files").open(path)
                    end
                end,

                change_root = function(picker, item)
                    picker:close()
                    if item then
                        local path = vim.fn.simplify(current_cwd .. "/" .. item.text)
                        vim.cmd("cd " .. path)
                        vim.notify("Root set to " .. path)
                    end
                end,
                go_up = function(picker)
                    picker:close()
                    pick_dirs(vim.fn.fnamemodify(current_cwd, ":h"))
                end,
                go_home = function(picker)
                    picker:close()
                    pick_dirs(vim.loop.os_homedir())
                end,
            },

            win = {
                input = {
                    keys = {
                        ["<c-o>"] = { "open_mini", desc = "Mini Files", mode = { "i", "n" } },
                        ["<c-d>"] = { "change_root", desc = "Set Root", mode = { "i", "n" } },
                        ["<c-h>"] = { "go_up", desc = "Go Up", mode = { "i", "n" } },
                        ["<M-h>"] = { "go_home", desc = "Go Home", mode = { "i", "n" } },
                    },
                },
            },
        })
    end
    pick_dirs(cwd)
end

return M
