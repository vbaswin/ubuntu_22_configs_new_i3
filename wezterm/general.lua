local wezterm = require("wezterm")
local module = {}

function module.setup(config)
	-- We can mostly rely on the wrapper script for the heavy lifting (GPU selection).
	-- But we still want to lower FPS if we are on battery.

	local battery_info = wezterm.battery_info()
	local on_battery = false

	-- If battery is discharging, we are definitely on battery.
	-- If it is charging or full, we are likely plugged in.
	if battery_info then
		for _, b in ipairs(battery_info) do
			if b.state == "Discharging" then
				on_battery = true
			end
		end
	end

	if on_battery then
		config.max_fps = 60
		config.webgpu_power_preference = "LowPower"
		config.animation_fps = 1
		config.cursor_blink_rate = 0
	else
		config.max_fps = 120
		config.webgpu_power_preference = "HighPerformance"
		config.animation_fps = 60
	end

	config.front_end = "WebGpu"
end

return module
