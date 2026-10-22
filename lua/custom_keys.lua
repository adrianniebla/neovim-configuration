--
-- You can edit the default settings of the shortcut keys here
--
return {
	-- The default '<leader>' is the space.
	leader = " ",

	-- Use the shortcut to switch/jump window.
	jump_left_window = "<C-h>",
	jump_right_window = "<C-l>",
	jump_up_window = "<C-k>",
	jump_down_window = "<C-j>",

	-- View other usage of the plugin: https://github.com/akinsho/bufferline.nvim
	-- Use the shortcut to pick a buffer tab.
	pick_tab = "<leader>tt",
	-- Use the shortcut followed by 1-9 to go to that tab (<leader>t1 = first tab).
	goto_tab = "<leader>t",
	-- Use the shortcut to close the current buffer tab, keeping the window layout.
	close_tab = "<leader>tc",
	close_tab_alt = "<C-q>",
	-- Use the shortcut to go to the next/previous buffer tab.
	next_tab = "gt",
	prev_tab = "gb",
	next_tab_alt = "<A-l>",
	prev_tab_alt = "<A-h>",
	-- Use the shortcut to switch back and forth with the last used tab (like alt+tab).
	last_tab = "<leader><leader>",

	-- Use the shortcut to copy to / paste from the system clipboard.
	-- Copy takes the selection in visual mode, the current line in normal mode.
	clipboard_copy = "<A-y>",
	clipboard_paste = "<A-p>",

	-- View other usage of the plugin: https://github.com/chentoast/marks.nvim
	-- Marks show in the sign column; m<letter> sets one, dm<letter> deletes it.
	mark_set_next = "m,", -- set the next free lowercase mark on this line
	mark_toggle = "m;", -- toggle the next free mark on this line
	mark_next = "m]", -- go to the next mark in this file
	mark_prev = "m[", -- go to the previous mark in this file
	mark_next_alt = "<A-j>",
	mark_prev_alt = "<A-k>",
	mark_preview = "m:", -- preview a mark's line in a float
	mark_delete_line = "dm-", -- delete the marks on this line
	mark_delete_buf = "dm<space>", -- delete all marks in this file

	-- View other usage of the plugin: https://github.com/nvim-neo-tree/neo-tree.nvim
	-- Use the shortcut to open or close file explorer.
	file_explorer = "<F9>",
	file_explorer_alt = "<C-n>",
	-- Use the shortcut to open or close git status on a float window.
	git_status = "<F8>",

	-- View other usage of the plugin: https://github.com/stevearc/aerial.nvim
	-- Use the shortcut to open or close the outline, it need to call the lsp server.
	outline = "<F7>",

	-- View other usage of the plugin: https://github.com/akinsho/toggleterm.nvim
	-- Use the shortcut to open or close the terminal.
	terminal_float = "<A-u>", -- open terminal in a float window
	terminal_bottom = "<A-b>", -- open terminal at the bottom

	-- View other usage of the plugin: https://github.com/Shatur/neovim-session-manager
	-- Use the shortcut to switch a session.
	switch_session = "<leader>ss",

	-- View other usage of the plugin: https://github.com/nvim-telescope/telescope.nvim
	-- Use the shortcut to find, search files and find buffers.
	-- Lowercase ignores case; the uppercase variants are case-sensitive.
	find_files = "<leader>ff",
	find_files_case = "<leader>FF",
	live_grep = "<leader>gg",
	live_grep_case = "<leader>GG",
	search_cursor = "<leader>cc",
	find_buffer = "<leader>bb",
	-- Use the to close telescope window. <C-c> is the default setting, can't edit it here.
	-- close_telescope  = "<C-c>",

	-- View other usage of the plugin: https://github.com/sindrets/diffview.nvim
	-- Use the shortcut to open 'git diff'.
	diff_open = "<leader>df",
	-- Use the shortcut to close 'git diff'.
	diff_close = "<leader>dc",

	-- View other usage of the plugin: https://github.com/mrjones2014/smart-splits.nvim
	-- Use the shortcut to resize the window, <control + alt + hjkl>
	resize_left = "<C-A-h>",
	resize_down = "<C-A-j>",
	resize_up = "<C-A-k>",
	resize_right = "<C-A-l>",

	-- View other usage of the plugin: https://github.com/hrsh7th/nvim-cmp
	-- Move through the autocomplete menu while it's open; otherwise the keys
	-- keep their normal insert-mode behavior.
	cmp_next = "<C-j>",
	cmp_prev = "<C-k>",
	cmp_page_down = "<C-d>",
	cmp_page_up = "<C-u>",

	-- View other usage of the plugin: https://github.com/neovim/nvim-lspconfig
	-- Goto
	goto_definition = "gd",
	goto_references = "gr",
	goto_declaration = "gD",
	goto_impl = "gi",
	-- goto_back           = "<C-o>",
	-- Use the shortcut to rename the code symbols.
	lsp_rename = "<leader>re",
	-- Use the shortcut to format your codes.
	format = "<leader>vv",
}
