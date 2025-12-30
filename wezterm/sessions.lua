local wezterm = require("wezterm")
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

local module = {}

module.save_state = wezterm.action_callback(function(win, pane)
    -- Get current workspace name to use as default suggestion
    local current_workspace = win:active_workspace()
    local default_name = current_workspace ~= "default" and current_workspace or ""

    -- Always prompt for session name (showing current name if not "default")
    win:perform_action(wezterm.action.PromptInputLine {
        description = wezterm.format {
            { Attribute = { Intensity = 'Bold' } },
            { Foreground = { AnsiColor = 'Fuchsia' } },
            { Text = 'Enter session name: ' },
        },
		-- initial_value = 'mera',        
		action = wezterm.action_callback(function(window, pane, line)
            local session_name
		wezterm.log_info("just checking the logs")
            
            -- If user pressed Enter without typing, use current workspace name
            if not line or line == "" then
                if default_name ~= "" then
                    -- User pressed Enter - update existing session
                    session_name = default_name
                else
                    -- No name provided and no default - do nothing
                    window:toast_notification('Wezterm', 'Save cancelled - no name provided', nil, 4000)
                    return
                end
            else
                -- User typed a new name
                session_name = line
                -- If the name is different from current workspace, rename it
                if session_name ~= current_workspace then
                    wezterm.mux.rename_workspace(current_workspace, session_name)
                end
            end
            
		wezterm.log_info("session_name: " .. session_name)

            -- Save the window state with the session name
            -- Try to get and save the window state with error handling
            local success, result = pcall(function()
				 -- Get the workspace state for the current workspace
                local workspace_state = resurrect.workspace_state.get_workspace_state()
                -- Save with the session name
                resurrect.state_manager.save_state(workspace_state, session_name)
            end)
            
            if success then
                window:toast_notification('Wezterm', 'Session saved: ' .. session_name, nil, 4000)
            else
                window:toast_notification('Wezterm', 'Error saving session: ' .. tostring(result), nil, 6000)
                wezterm.log_error('Session save error: ' .. tostring(result))
            end
        end),
    }, pane)
end)

module.restore_state = wezterm.action_callback(function(win, pane)
    resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
        -- Extract the type (workspace, window, tab)
        local type = string.match(id, "^([^/]+)")
        
        -- Extract the file name
        id = string.match(id, "([^/]+)$")
        
        -- Remove the file extension
        id = string.match(id, "(.+)%..+$")

        local opts = {
            relative = true,
            restore_text = true,
            on_pane_restore = resurrect.tab_state.default_on_pane_restore,
        }

        -- We're saving as window state, so we should restore as window state
        if type == "window" then
            local state = resurrect.state_manager.load_state(id, "window")
            resurrect.window_state.restore_window(pane:window(), state, opts)
        elseif type == "workspace" then
            -- Still support workspace restores if any exist
            local state = resurrect.state_manager.load_state(id, "workspace")
            resurrect.workspace_state.restore_workspace(state, opts)
        elseif type == "tab" then
            local state = resurrect.state_manager.load_state(id, "tab")
            resurrect.tab_state.restore_tab(pane:tab(), state, opts)
        end
    end, {
        -- Only show window states in the fuzzy finder by default
        ignore_workspaces = false,  -- Set to true if you only want window states
        ignore_tabs = true,
    })
end)

return module
