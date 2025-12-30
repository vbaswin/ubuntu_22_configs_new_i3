local wezterm = require("wezterm")

local module = {}

function module.setup(config)
	config.font = wezterm.font("JetBrains Mono")
	config.color_scheme = 'Catppuccin Mocha'
	config.use_fancy_tab_bar = false
end

wezterm.on('update-status', function(window, pane)
  local workspace = window:active_workspace() or 'default'
  wezterm.log_info('Updating status for: ' .. workspace)
  
  local workspace_color = '#cba6f7'
  if workspace == 'default' then
    workspace_color = '#f5e0dc'
  end
  
  window:set_left_status(wezterm.format({
    { Foreground = { Color = workspace_color } },
    { Attribute = { Intensity = 'Bold' } },
    { Text = ' [' .. workspace .. '] ' },
  }))
end)

return module
