local M = {}

-- Opens a directory picker using Snacks.nvim
-- @param cwd string|nil Optional starting directory
function M.find_directory(cwd)
    if not Snacks or not Snacks.picker then
        vim.notify("Snacks.picker not available.", vim.log.levels.ERROR)
        return
    end

    local function pick_dirs(current_cwd)
        current_cwd = current_cwd or vim.fn.getcwd()

        Snacks.picker.files({
            cwd = current_cwd,
            cmd = "fd",
            args = { "--type", "d", "--hidden", "--follow", "--exclude", ".git" },

            title = " " .. vim.fn.fnamemodify(current_cwd, ":t") .. " > ",

            actions = {
                confirm = function(picker, item)
                    picker:close()
                    Snacks.picker.files({ cwd = item.file })
                end,

                open_mini = function(picker, item)
                    picker:close()
                    require("mini.files").open(item.file)
                end,

                change_root = function(picker, item)
                    picker:close()
                    vim.cmd("cd " .. item.file)
                    vim.notify("Root set to " .. item.file)
                end,
                go_up = function(picker)
                    picker:close()
                    pick_dirs(vim.fn.fnamemodify(current_cwd, ":h"))
                end,
            },

            win = {
                input = {
                    keys = {
                        ["<c-o>"] = { "open_mini", desc = "Mini Files", mode = { "i", "n" } },
                        ["<c-d>"] = { "change_root", desc = "Set Root", mode = { "i", "n" } },
                        ["<c-h>"] = { "go_up", desc = "Go Up", mode = { "i", "n" } },
                    },
                },
            },
        })
    end
    pick_dirs(cwd)
end

return M
