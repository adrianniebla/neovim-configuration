local keys = require("custom_keys")
local opts = require("custom_opts")

-- Setup keymapping
local function set_keymap()
	local map = vim.keymap.set
	local option = { noremap = true, silent = true }

	map("n", keys.jump_left_window, "<C-W>h", option)
	map("n", keys.jump_down_window, "<C-W>j", option)
	map("n", keys.jump_up_window, "<C-W>k", option)
	map("n", keys.jump_right_window, "<C-W>l", option)

	vim.cmd([[
    " press esc to cancel search highlight
    nnoremap <silent> <Esc> :nohlsearch<CR>:echo<CR>
	]])

	-- for markdown file
	vim.cmd([[
    " optimized up and down move when set wrap for markdown file
    autocmd FileType markdown noremap <buffer> j gj
    autocmd FileType markdown noremap <buffer> k gk
	autocmd FileType markdown setlocal wrap
	]])

	-- Supported by bufdelete
	vim.cmd([[
	cnoreabbrev bdelete Bdelete
	cnoreabbrev bdelete! Bdelete!
	cnoreabbrev bwipeout Bwipeout
	cnoreabbrev bwipeout! Bwipeout!
	]])

	-- Supported by bufferline
	map("n", keys.pick_tab, ":BufferLinePick<CR>", option)
	for i = 1, 9 do
		map("n", keys.goto_tab .. i, "<Cmd>BufferLineGoToBuffer " .. i .. "<CR>", option)
	end
	-- Close the current tab and show the next one (Bdelete alone goes back
	-- to the previously viewed buffer). Refuses if there are unsaved changes.
	local function close_tab()
		local buf = vim.api.nvim_get_current_buf()
		if vim.bo[buf].modified then
			vim.notify("Unsaved changes: :w first, or :Bdelete! to discard", vim.log.levels.ERROR)
			return
		end
		for _, win in ipairs(vim.fn.win_findbuf(buf)) do
			vim.api.nvim_win_call(win, function()
				vim.cmd("BufferLineCycleNext")
			end)
		end
		vim.cmd("Bdelete " .. buf)
	end
	map("n", keys.close_tab, close_tab, option)
	map("n", keys.close_tab_alt, close_tab, option)
	map("n", keys.next_tab, ":BufferLineCycleNext<CR>", option)
	map("n", keys.prev_tab, ":BufferLineCyclePrev<CR>", option)
	map("n", keys.next_tab_alt, ":BufferLineCycleNext<CR>", option)
	map("n", keys.prev_tab_alt, ":BufferLineCyclePrev<CR>", option)
	map("n", keys.last_tab, "<C-^>", option)

	-- <C-d>/<C-u> scroll 75% of the window instead of half
	local function scroll_lines()
		return math.max(math.floor(vim.api.nvim_win_get_height(0) * 0.75), 1)
	end
	map({ "n", "x" }, "<C-d>", function() return scroll_lines() .. "<C-d>" end, { expr = true, silent = true })
	map({ "n", "x" }, "<C-u>", function() return scroll_lines() .. "<C-u>" end, { expr = true, silent = true })

	-- Supported by nvim-tree
	map("n", keys.file_explorer, ":Neotree position=left source=filesystem action=show toggle=true<CR>", option)
	-- Same as above, but moves the cursor into the explorer
	map("n", keys.file_explorer_alt, ":Neotree position=left source=filesystem action=focus toggle=true<CR>", option)
	map("n", keys.git_status, ":Neotree position=float source=git_status action=show toggle=true<CR>", option)

	-- Supported by aerial
	map("n", keys.outline, ":AerialToggle! right<CR>", option)

	-- Supported by diffview
	map("n", keys.diff_open, ":DiffviewOpen<CR>", option)
	map("n", keys.diff_close, ":DiffviewClose<CR>", option)

	-- Supported by toggleterm
	-- float terminal
	local float_terminal_default = require("toggleterm.terminal").Terminal:new({
		direction = "float",
		on_open = function(term)
			-- forced to change the working dir for terminal
			-- This will solve the problem of not updating the directory when switching sessions.
			local cwd = vim.fn.getcwd()
			if cwd ~= term.dir then
				term:change_dir(cwd)
			end
			-- when float term opened, disable bottom terminal
			vim.api.nvim_del_keymap("t", keys.terminal_bottom)
			vim.cmd("startinsert!")
		end,
		on_close = function(t, job, exit_code, name)
			-- when float term closed, enable bottom terminal
			map("t", keys.terminal_bottom, "<C-\\><C-n>:lua _bottom_term_toggle()<CR>", option)
		end,
	})
	function _float_term_toggle()
		float_terminal_default:toggle()
	end

	-- bottom terminal
	local bottom_terminal_default = require("toggleterm.terminal").Terminal:new({
		direction = "horizontal",
		on_open = function(term)
			-- forced to change the working dir for terminal
			-- This will solve the problem of not updating the directory when switching sessions.
			local cwd = vim.fn.getcwd()
			if cwd ~= term.dir then
				term:change_dir(cwd)
			end

			-- set keymapping
			local opts = { buffer = 0 }
			vim.api.nvim_buf_set_keymap(
				term.bufnr,
				"t",
				"<C-h>",
				[[<Cmd>wincmd h<CR>]],
				{ noremap = true, silent = true }
			)
			vim.api.nvim_buf_set_keymap(
				term.bufnr,
				"t",
				"<C-j>",
				[[<Cmd>wincmd j<CR>]],
				{ noremap = true, silent = true }
			)
			vim.api.nvim_buf_set_keymap(
				term.bufnr,
				"t",
				"<C-k>",
				[[<Cmd>wincmd k<CR>]],
				{ noremap = true, silent = true }
			)
			vim.api.nvim_buf_set_keymap(
				term.bufnr,
				"t",
				"<C-l>",
				[[<Cmd>wincmd l<CR>]],
				{ noremap = true, silent = true }
			)
			vim.cmd("startinsert!")
		end,
		on_exit = function(t, job, exit_code, name)
			vim.cmd("quit!")
		end,
	})
	function _bottom_term_toggle()
		bottom_terminal_default:toggle()
	end

	map("n", keys.terminal_float, ":lua _float_term_toggle()<CR>", option)
	map("t", keys.terminal_float, "<C-\\><C-n>:lua _float_term_toggle()<CR>", option)
	map("n", keys.terminal_bottom, ":lua _bottom_term_toggle()<CR>", option)
	map("t", keys.terminal_bottom, "<C-\\><C-n>:lua _bottom_term_toggle()<CR>", option)

	vim.cmd([[
    command! Termfloat :lua _float_term_toggle()
    ]])
	vim.cmd([[cnoreabbrev terminal Termfloat]])

	-- Supported by nvim-session-manager
	map("n", keys.switch_session, ":SessionManager load_session<CR>", option)
end

-- Set up transparency
local function set_transparency()
	local transparency = opts.window_transparency
	-- Setup global transparency for float window.
	vim.api.nvim_command(string.format("autocmd FileType * set winblend=%d", transparency))
	-- Setup global transparency for popup menu.
	vim.o.pumblend = transparency
end

-- Set up auto command
local function set_autocmd()
	local current_colorscheme = vim.g.colors_name
	vim.api.nvim_create_autocmd("VimEnter", {
		-- nested: fire ColorScheme so plugins (e.g. bufferline) re-apply their highlights
		nested = true,
		callback = function()
			vim.cmd("colorscheme" .. " " .. current_colorscheme)
		end,
	})
end

set_keymap()
set_transparency()
set_autocmd()
