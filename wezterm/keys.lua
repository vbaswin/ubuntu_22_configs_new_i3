local wezterm = require("wezterm")
local act = wezterm.action
local sessions = require("sessions")

local module = {}

function module.setup(config)
	config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 }
	-- =========================================================
	-- KEYBINDINGS
	-- =========================================================
	config.keys = {
		-- 1. TMUX-LIKE PANE MANAGEMENT
		-- Split vertical (like Tmux %)
		{
			key = "%",
			mods = "LEADER|SHIFT",
			action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
		},
		-- Split horizontal (like Tmux ")
		{
			key = '"',
			mods = "LEADER|SHIFT",
			action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
		},
		-- Alternative splits: - and |
		{
			key = "-",
			mods = "LEADER",
			action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
		},
		{
			key = "|",
			mods = "LEADER|SHIFT",
			action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
		},
		-- Zoom pane (like Tmux z)
		{
			key = "z",
			mods = "LEADER",
			action = act.TogglePaneZoomState,
		},
		-- Close pane (like Tmux x)
		{
			key = "x",
			mods = "LEADER",
			action = act.CloseCurrentPane({ confirm = true }),
		},
		{
			key = "&",
			mods = "LEADER|SHIFT",
			action = act.CloseCurrentTab({ confirm = true }),
		},

		-- 2. TMUX-LIKE WINDOW/TAB MANAGEMENT
		-- Create new window (tab)
		{
			key = "c",
			mods = "LEADER",
			action = act.SpawnTab("CurrentPaneDomain"),
		},
		-- Next/Prev window (n/p)
		{
			key = "n",
			mods = "LEADER",
			action = act.ActivateTabRelative(1),
		},
		{
			key = "p",
			mods = "LEADER",
			action = act.ActivateTabRelative(-1),
		},
		-- Switch to specific tabs (1-9)
		{ key = "1", mods = "LEADER", action = act.ActivateTab(0) },
		{ key = "2", mods = "LEADER", action = act.ActivateTab(1) },
		{ key = "3", mods = "LEADER", action = act.ActivateTab(2) },
		{ key = "4", mods = "LEADER", action = act.ActivateTab(3) },
		{ key = "5", mods = "LEADER", action = act.ActivateTab(4) },

		-- 3. NAVIGATION (Vim-style h/j/k/l)
		-- Move between panes
		{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
		{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
		{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
		{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

		-- Resize panes (resize mode not needed, just hold shift)
		{ key = "h", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
		{ key = "j", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
		{ key = "k", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
		{ key = "l", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },

		-- Move tab left
		{
			key = "H",
			mods = "CTRL|SHIFT",
			action = wezterm.action.MoveTabRelative(-1),
		},

		-- Move tab right
		{
			key = "L",
			mods = "CTRL|SHIFT",
			action = wezterm.action.MoveTabRelative(1),
		},

		-- resize mode
		{
			key = "r",
			mods = "LEADER",
			action = act.ActivateKeyTable({
				name = "resize_pane",
				one_shot = false,
			}),
		},

		-- resurrect plugin
		{
			key = "s",
			mods = "LEADER",
			action = sessions.save_state,
		},
		-- action =sessions.save_current_ws, },
		{
			key = "r",
			mods = "LEADER",
			action = sessions.restore_state,
		},
		-- action =sessions.load_ws_with_fuzzy, },
		--[[
	{
    key = "d",
    mods = "LEADER",
    action = sessions.delete_sessionr  },
		--]]
	}
	config.key_tables = {
		resize_pane = {
			{ key = "h", action = act.AdjustPaneSize({ "Left", 5 }) },
			{ key = "j", action = act.AdjustPaneSize({ "Down", 5 }) },
			{ key = "k", action = act.AdjustPaneSize({ "Up", 5 }) },
			{ key = "l", action = act.AdjustPaneSize({ "Right", 5 }) },
			{ key = "Escape", action = "PopKeyTable" },
		},
	}
end

return module
