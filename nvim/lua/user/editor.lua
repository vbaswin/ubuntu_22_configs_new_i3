local M = {}

function M.copy_path(target, relative)
    local path
    if target == "dir" then
        path = vim.fn.expand("%:p:h")
    else
        path = vim.fn.expand("%:p")
    end

    if relative then
        path = vim.fn.fnamemodify(path, ":.")
    end

    vim.fn.setreg("+", path)
    vim.notify(string.format("Copied %s %s path", relative and "relative" or "absolute", target))
end

function M.interactive_save()
    local bufs = vim.api.nvim_list_bufs()

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
end

return M
