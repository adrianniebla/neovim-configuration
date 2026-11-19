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

			-- Also list untracked files (new files not `git add`ed yet) when a commit or
			-- branch is compared against the current files. Diffview only lists them for a
			-- plain :DiffviewOpen. Its other checks still apply: --untracked-files=no
			-- and git's status.showUntrackedFiles=no hide them.
			local GitAdapter = require("diffview.vcs.adapters.git").GitAdapter
			local RevType = require("diffview.vcs.rev").RevType
			local show_untracked = GitAdapter.show_untracked
			function GitAdapter:show_untracked(opt)
				if opt and opt.revs and opt.revs.right.type == RevType.LOCAL then
					return show_untracked(self, { dv_opt = opt.dv_opt })
				end
				return show_untracked(self, opt)
			end
		end,
	},

	{
		"isakbm/gitgraph.nvim",
		dependencies = { "sindrets/diffview.nvim" },
		-- loaded the first time keys.diff_graph (core.lua) draws the graph
		lazy = true,
		opts = {
			format = {
				timestamp = "%Y-%m-%d %H:%M",
			},
			hooks = {
				-- <CR> on a commit: the current files against it (like `git diff <commit>`)
				on_select_commit = function(commit)
					vim.cmd({ cmd = "DiffviewOpen", args = { commit.hash } })
				end,
				-- <CR> on a visual selection: the changes made from the oldest
				-- selected commit (from) through the newest one (to)
				on_select_range_commit = function(from, to)
					local before = from.hash .. "~1"
					if #from.parents == 0 then
						-- the repository's first commit has no parent: start from an empty tree
						before = vim.fn.system({ "git", "hash-object", "-t", "tree", "/dev/null" }):gsub("%s+$", "")
					end
					vim.cmd({ cmd = "DiffviewOpen", args = { before .. ".." .. to.hash } })
				end,
			},
		},
		config = function(_, opts)
			require("gitgraph").setup(opts)

			-- keys.diff_commit_only on a commit: only the changes made in that commit
			-- (like `git show <commit>`). The graph buffer gets this filetype on every draw.
			local keys = require("custom_keys")
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "gitgraph",
				callback = function(args)
					vim.keymap.set("n", keys.diff_commit_only, function()
						local row = vim.api.nvim_win_get_cursor(0)[1]
						-- the same lookup the plugin's own <CR> uses
						local commit =
							require("gitgraph.utils").get_commit_from_row(require("gitgraph.draw").graph, row)
						if commit then
							vim.cmd({ cmd = "DiffviewOpen", args = { commit.hash .. "^!" } })
						end
					end, { buffer = args.buf, desc = "Show only the changes made in this commit" })
				end,
			})
		end,
	},
}
