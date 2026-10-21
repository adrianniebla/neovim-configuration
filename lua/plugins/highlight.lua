return {
	-- Syntax highlighting
	{
		"nvim-treesitter/nvim-treesitter",
		-- 'main' is an incompatible rewrite without nvim-treesitter.configs
		branch = "master",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				indent = {
					enable = true,
					disable = {},
				},
				ensure_installed = { "markdown", "markdown_inline", "regex" },
				sync_install = false,
				auto_install = true,
				ignore_install = {},

				highlight = {
					enable = true,
					disable = {},
					disable = function(lang, buf)
						local max_filesize = 100 * 1024 -- 100 KB
						local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
						if ok and stats and stats.size > max_filesize then
							return true
						end
					end,
					additional_vim_regex_highlighting = false,
				},
			})

			-- let it to use 'markdown' parser for mdx filetype.
			vim.treesitter.language.register('markdown', 'mdx')
		end,
	},

	-- Highlight other uses of the word under the cursor (LSP, then Treesitter, then regex)
	{
		"RRethy/vim-illuminate",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("illuminate").configure({
				delay = 200,
				large_file_cutoff = 10000,
				filetypes_denylist = {
					"alpha",
					"neo-tree",
					"aerial",
					"toggleterm",
					"TelescopePrompt",
					"lazy",
					"mason",
				},
			})
		end,
	},

	-- Colors highlighting
	{
		"NvChad/nvim-colorizer.lua",
		config = function(plun)
			require("colorizer").setup({
				user_default_options = {
					names = false,
				},
			})
		end,
	},
}
