return {
	{
		"lewis6991/gitsigns.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("gitsigns").setup({
				current_line_blame = false,
				-- changed lines share the added-line green, so give them a dashed bar
				-- (┆ is taken by untracked files)
				signs = { change = { text = "┋" } },
				signs_staged = { change = { text = "┋" } },
				preview_config = {
					border = "rounded",
				},
			})
		end,
	},

	{
		"sindrets/diffview.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			-- Diffview always puts the old version (a) on the left and the current one (b) on the
			-- right, with no option to swap them. Re-create its side-by-side layout with the
			-- current version on the left; it's otherwise the same as diff_2_hor.lua upstream.
			local async = require("diffview.async")
			local Window = require("diffview.scene.window").Window
			local Diff2Hor = require("diffview.scene.layouts.diff_2_hor").Diff2Hor
			local api = vim.api

			Diff2Hor.create = async.void(function(self, pivot)
				self:create_pre()

				pivot = pivot or self:find_pivot()
				assert(api.nvim_win_is_valid(pivot), "Layout creation requires a valid window pivot!")

				for _, win in ipairs(self.windows) do
					if win.id ~= pivot then
						win:close(true)
					end
				end

				-- each split opens left of the pivot, so the window made first ends up leftmost
				for _, side in ipairs({ "b", "a" }) do
					api.nvim_win_call(pivot, function()
						vim.cmd("aboveleft vsp")
						local curwin = api.nvim_get_current_win()
						if self[side] then
							self[side]:set_id(curwin)
						else
							self[side] = Window({ id = curwin })
						end
					end)
				end

				api.nvim_win_close(pivot, true)
				self.windows = { self.a, self.b }
				async.await(self:create_post())
			end)
		end,
	},
}
