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

			-- In the file panel (tree view), list each C/C++ header right before its
			-- source file (foo.h before foo.cpp in the same folder); everything else
			-- stays alphabetical. <Tab>/<S-Tab> follow the same order. Same rule as
			-- `git diff` (~/.local/bin/diff-headers-first).
			local Node = require("diffview.ui.models.file_tree.node").Node
			local header_ext = { h = true, hh = true, hpp = true, hxx = true, ["h++"] = true }
			local source_ext = { c = true, cc = true, cpp = true, cxx = true, ["c++"] = true, m = true, mm = true }
			local function split(node)
				if node:has_children() then
					return nil
				end
				local stem, ext = node.name:match("^(.*)%.([^.]+)$")
				if not stem then
					return nil
				end
				ext = ext:lower()
				return stem, header_ext[ext] and "header" or source_ext[ext] and "source" or nil
			end

			local sort = Node.sort
			function Node:sort()
				sort(self) -- sorts the children (and, through this method, their children)

				local headers, has_source = {}, {}
				for _, child in ipairs(self.children) do
					local stem, kind = split(child)
					if kind == "header" then
						headers[stem] = headers[stem] or {}
						table.insert(headers[stem], child)
					elseif kind == "source" then
						has_source[stem] = true
					end
				end

				local order, placed = {}, {}
				for _, child in ipairs(self.children) do
					local stem, kind = split(child)
					if kind == "source" and headers[stem] then
						for _, header in ipairs(headers[stem]) do
							if not placed[header] then
								placed[header] = true
								table.insert(order, header)
							end
						end
					end
					if not (kind == "header" and has_source[stem]) and not placed[child] then
						placed[child] = true
						table.insert(order, child)
					end
				end
				-- children is also keyed by name; only the list part is reordered
				for i, child in ipairs(order) do
					self.children[i] = child
				end
			end
		end,
	},
}
