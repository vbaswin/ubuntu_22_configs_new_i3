local wezterm = require("wezterm")

local module = {}

function module.setup(config)
	config.font = wezterm.font("JetBrains Mono")
	config.color_scheme = 'Catppuccin Mocha'
	config.use_fancy_tab_bar = false
end

wezterm.on('update-status', function(window, pane)
  -- Grab the current workspace name
  local workspace = window:active_workspace()

  -- Use a specific Catppuccin Mocha color (Mauve: #cba6f7)
  -- You can also use other Mocha colors like Lavender (#b4befe) or Rosewater (#f5e0dc)
  local workspace_color = '#cba6f7'
  
  -- (Optional) If you want a different color for the 'default' workspace
  if workspace == 'default' then
    workspace_color = '#f5e0dc' -- Mocha Rosewater
  end

  -- Set the text on the left side of the tab bar
  window:set_left_status(wezterm.format({
    { Foreground = { Color = workspace_color } },
    { Attribute = { Intensity = 'Bold' } },
    { Text = '  [' .. workspace .. ']  ' },
  }))
end)

return module
