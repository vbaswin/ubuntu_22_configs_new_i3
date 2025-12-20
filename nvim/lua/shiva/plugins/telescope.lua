return {
	"nvim-telescope/telescope.nvim",
	branch = "master", -- using master to fix issues with deprecated to definition warnings 
    -- '0.1.x' for stable ver.
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"andrew-george/telescope-themes",
		"jvgrootveld/telescope-zoxide",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local builtin = require("telescope.builtin")
		local z_utils = require("telescope._extensions.zoxide.utils")
		
		local function fuzzy_search_folders()
		builtin.find_files({
			prompt_title = "Fuzzy CD",
		find_command = { "find", ".", "-type", "d",  "-not", "-path", "*/.*" },
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					local selection = require("telescope.actions.state").get_selected_entry()
					actions.close(prompt_bufnr)
					vim.api.nvim_set_current_dir(selection[1])
					print("CWD set to: " .. selection[1])
				end)
				return true
			end,
		})
	end

		telescope.load_extension("fzf")
		telescope.load_extension("themes")
		telescope.load_extension("zoxide")

		telescope.setup({
			defaults = {
				path_display = { "smart" },
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous,
						["<C-j>"] = actions.move_selection_next,
					},
				},
			},
			extensions = {
				themes = {
					enable_previewer = true,
					enable_live_preview = true,
					persist = {
						enabled = true,
						path = vim.fn.stdpath("config") .. "/lua/colorscheme.lua",
					},
				},
			},
			  zoxide = {
				  prompt_title = "[ Walk to Directory ]",
				  mappings = {
					default = {
					  action = function(selection)
						vim.api.nvim_set_current_dir(selection.path)
					  end,
					  after_action = function(selection)
						print("Directory changed to " .. selection.path)
					  end
					},
				  },
				},
		})

		 vim.keymap.set('n', '<leader>ff', function() builtin.find_files({ hidden = true }) end,  { desc = 'Telescope find files' })

	vim.keymap.set('n', '<leader>fg', function() 
            builtin.live_grep({ 
                additional_args = function(args) 
                    return { "--hidden" } 
                end 
            }) 
        end, { desc = 'Telescope live grep' })	  

		vim.keymap.set('n', '<leader>fb', builtin.buffers,     { desc = 'Telescope buffers' })
	  vim.keymap.set('n', '<leader>fh', builtin.help_tags,  { desc = 'Telescope help tags' })
	  -- 3. The "Fuzzy CD" (Folder only search)
		vim.keymap.set("n", "<leader>fd", fuzzy_search_folders, { desc = "Search Folders & CD" })

		-- 4. Zoxide (Jump to frequent folders)
		vim.keymap.set("n", "<leader>fz", telescope.extensions.zoxide.list, { desc = "Zoxide (Recent Folders)" })
		-- Keymaps
		vim.keymap.set("n", "<leader>pr", "<cmd>Telescope oldfiles<CR>", { desc = "Fuzzy find recent files" })
		vim.keymap.set("n", "<leader>pWs", function()
			local word = vim.fn.expand("<cWORD>")
			builtin.grep_string({ search = word })
		end, { desc = "Find Connected Words under cursor" })

		vim.keymap.set("n", "<leader>ths", "<cmd>Telescope themes<CR>", { noremap = true, silent = true, desc = "Theme Switcher" })
		-- Find symbols (functions/vars) in the CURRENT file
	vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, { desc = 'Find Symbols (Current File)' })

	-- Find symbols (functions/vars) in the WHOLE project
	vim.keymap.set('n', '<leader>fS', builtin.lsp_workspace_symbols, { desc = 'Find Symbols (Workspace)' })
    end,
}
