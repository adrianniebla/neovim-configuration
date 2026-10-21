return {
	{
		"hardhackerlabs/theme-vim",
		name = "hardhacker",
		lazy = false,
		priority = 1000,
		config = function()
			vim.g.hardhacker_darker = 0
			vim.g.hardhacker_hide_tilde = 1
			vim.g.hardhacker_keyword_italic = 1
			-- vim.cmd.colorscheme("hardhacker")
		end,
	},
	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("kanagawa").setup({
				-- Plain (non-italic, non-bold) comments and language keywords;
				-- italics show up as a box in this terminal
				commentStyle = { italic = false },
				keywordStyle = { italic = false },
				statementStyle = { bold = false },
				colors = {
					theme = {
						all = {
							ui = {
								bg_gutter = "none",
							},
						},
					},
				},
				overrides = function(colors)
					local theme = colors.theme
					-- Language keywords (if, return, const, static, this, def, self, ...)
					-- in one neutral color, no italic/bold
					local keyword = { fg = colors.palette.springViolet1, italic = false, bold = false }
					local keyword_groups = {}
					for _, group in ipairs({
						"Keyword", "Statement", "Conditional", "Repeat", "Label", "Exception", "StorageClass",
						"@keyword", "@keyword.return", "@keyword.function", "@keyword.operator",
						"@keyword.import", "@keyword.conditional", "@keyword.conditional.ternary",
						"@keyword.repeat", "@keyword.exception", "@keyword.modifier", "@keyword.type",
						"@keyword.coroutine", "@keyword.storage", "@variable.builtin",
					}) do
						keyword_groups[group] = keyword
					end
					return vim.tbl_extend("force", keyword_groups, {
						-- stronger visual selection (default waveBlue1 is hard to see on the background)
						Visual = { bg = colors.palette.waveBlue2 },

						-- modern telescope ui
						TelescopeTitle = { fg = theme.ui.special, bold = true },
						TelescopePromptNormal = { bg = theme.ui.bg_p1 },
						TelescopePromptBorder = { fg = theme.ui.bg_p1, bg = theme.ui.bg_p1 },
						TelescopeResultsNormal = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m1 },
						TelescopeResultsBorder = { fg = theme.ui.bg_m1, bg = theme.ui.bg_m1 },
						TelescopePreviewNormal = { bg = theme.ui.bg_dim },
						TelescopePreviewBorder = { bg = theme.ui.bg_dim, fg = theme.ui.bg_dim },

						-- nicer floating windows
						NormalFloat = { bg = "none" },
						FloatBorder = { bg = "none" },
						FloatTitle = { bg = "none" },

						-- Save an hlgroup with dark background and dimmed foreground
						-- so that you can use it where your still want darker windows.
						-- E.g.: autocmd TermOpen * setlocal winhighlight=Normal:NormalDark
						NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },

						-- Popular plugins that open floats will link to NormalFloat by default;
						-- set their background accordingly if you wish to keep them dark and borderless
						LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
						MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },

						-- popup menu
						Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 }, -- add `blend = vim.o.pumblend` to enable transparency
						PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
						PmenuSbar = { bg = theme.ui.bg_m1 },
						PmenuThumb = { bg = theme.ui.bg_p2 },
					})
				end,
			})
			vim.cmd("colorscheme kanagawa")
		end,
	},
}
