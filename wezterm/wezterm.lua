local wezterm = require("wezterm")
local config = wezterm.config_builder()

require("appearance").setup(config)
require("general").setup(config)
require("keys").setup(config)


return config

