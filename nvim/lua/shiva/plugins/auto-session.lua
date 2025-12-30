return {
  "rmagatti/auto-session",
  lazy = false, -- Must be false to load the session immediately on startup
  opts = {
    -- 1. The Core "Invisible" Workflow
    auto_session_enabled = true,
    auto_save_enabled = true,
    auto_restore_enabled = true,

    -- 2. Suppress specific directories to prevent "garbage" sessions
    -- (You don't want a session for your Home or Downloads folder)
    auto_session_suppress_dirs = { "~/", "~/Downloads", "~/Documents", "/" },

    -- 3. Explicitly disable the Telescope/FZF picker component
    session_lens = {
      load_on_setup = false,
    },
    
    -- Optional: purely for silence
    log_level = "error", 
  },
}
