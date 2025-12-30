local module = {}

function module.setup(config)
	config.max_fps = 144
	config.front_end = 'WebGpu'
	config.webgpu_power_preference = 'HighPerformance'
	config.scrollback_lines = 10000
end

return module

