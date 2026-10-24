return {
    {
        'nvim-telescope/telescope.nvim',
        dependencies = {
            {'nvim-lua/popup.nvim'},
            {'nvim-lua/plenary.nvim'},
            {'nvim-telescope/telescope-fzf-native.nvim', build = 'make'},
        },
        config = function()
            local actions = require('telescope.actions')
            local action_state = require('telescope.actions.state')
            local keys = require("custom_keys")
            -- same as Telescope's default <Tab>
            local mark = actions.toggle_selection + actions.move_selection_worse

            -- <CR> opens the file in place of the current buffer tab (see
            -- lua/open_in_place.lua); <C-t> opens it as a new tab instead.
            -- Entries selected with <Tab> each open as their own tab
            -- (Telescope's default only opens the entry under the cursor).
            local function open_selected(prompt_bufnr)
                local multi = action_state.get_current_picker(prompt_bufnr):get_multi_selection()
                if #multi == 0 then
                    local entry = action_state.get_selected_entry()
                    if entry and entry.bufnr then
                        -- Buffers picker: just switch, don't close anything
                        return actions.select_default(prompt_bufnr)
                    end
                    return require("open_in_place").run(function()
                        actions.select_default(prompt_bufnr)
                    end)
                end
                actions.close(prompt_bufnr)
                for _, entry in ipairs(multi) do
                    local path = entry.path or entry.filename
                    if entry.bufnr and not path then
                        vim.cmd.buffer(entry.bufnr)
                    elseif path then
                        vim.cmd.edit(vim.fn.fnameescape(path))
                        if entry.lnum then
                            pcall(vim.api.nvim_win_set_cursor, 0, { entry.lnum, math.max((entry.col or 1) - 1, 0) })
                        end
                    end
                end
            end

            -- Page the results like <C-d>/<C-u> in a file: the list scrolls a
            -- full window and the selection keeps its row on screen. At the
            -- first/last result the list stops (no scrolling into empty space)
            -- and the selection moves to that result instead.
            local function move_page(direction)
                return function(prompt_bufnr)
                    local picker = action_state.get_current_picker(prompt_bufnr)
                    local win = picker.results_win
                    -- In normal mode a count pages that many times (e.g. 12<C-u>)
                    local count = vim.api.nvim_get_mode().mode == "n" and math.max(vim.v.count, 1) or 1
                    local height = vim.api.nvim_win_get_height(win)
                    local offset = picker:get_selection_row() + 1 - vim.fn.line("w0", win)

                    picker:move_selection(direction * height * count)

                    -- Buffer lines holding results (descending puts them at the bottom)
                    local count = math.min(picker.manager:num_results(), picker.max_results)
                    local first, last
                    if picker.sorting_strategy == "ascending" then
                        first, last = 1, count
                    else
                        first, last = picker.max_results - count + 1, picker.max_results
                    end
                    local line = picker:get_selection_row() + 1
                    -- Lowest/highest allowed top line. With fewer results than fit,
                    -- both are where Telescope normally shows them (no scrolling).
                    local highest = math.max(last - height + 1, 1)
                    local lowest = math.min(first, highest)
                    local top = math.min(math.max(line - offset, lowest), highest)
                    vim.api.nvim_win_call(win, function()
                        vim.fn.winrestview({ topline = top, lnum = line, col = 0 })
                    end)
                end
            end

            require'telescope'.setup{
                defaults = {
                    -- Stop at the first/last result instead of wrapping around
                    scroll_strategy = "limit",
                    -- <C-d>/<C-u> move the selection a full page (default: scroll preview)
                    -- <C-j>/<C-k> move the selection down/up
                    mappings = {
                        i = {
                            ["<C-d>"] = move_page(1),
                            ["<C-u>"] = move_page(-1),
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                            -- first <C-c> leaves the prompt to normal mode, like <Esc>
                            ["<C-c>"] = function() vim.cmd("stopinsert") end,
                            [keys.telescope_mark] = mark,
                            ["<CR>"] = open_selected,
                            ["<C-t>"] = actions.select_default, -- open as a new tab
                            ["<M-CR>"] = actions.select_default, -- Alt-Enter: same as <C-t>
                        },
                        n = {
                            ["<C-d>"] = move_page(1),
                            ["<C-u>"] = move_page(-1),
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                            -- second <C-c> (now in normal mode) closes the search
                            ["<C-c>"] = actions.close,
                            [keys.telescope_mark] = mark,
                            ["<CR>"] = open_selected,
                            ["<C-t>"] = actions.select_default, -- open as a new tab
                            ["<M-CR>"] = actions.select_default, -- Alt-Enter: same as <C-t>
                        },
                    },
                    -- Lua patterns for paths to hide from all pickers
                    file_ignore_patterns = {
                        "^%.git/", "/%.git/",
                        "^node_modules/", "/node_modules/",
                        "^%.venv/", "/%.venv/",
                        "^__pycache__/", "/__pycache__/",
                        "^dist/", "/dist/",
                        -- build/ and any build-*/ folder
                        "^build/", "/build/",
                        "^build%-[^/]*/", "/build%-[^/]*/",
                        "%.DS_Store$",
                    },
                },
                extensions = {
                    fzf = {
                        -- always match regardless of case (default "smart_case"
                        -- turns case-sensitive once the query has a capital)
                        case_mode = "ignore_case",
                    },
                },
            }
            require'telescope'.load_extension('fzf')

            -- Relative numbers in the results list, so counts like 12k / 12<C-u>
            -- (after <Esc> to normal mode) are easy to read off
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "TelescopeResults",
                callback = function()
                    vim.opt_local.number = true
                    vim.opt_local.relativenumber = true
                end,
            })

            local option = {noremap = true, silent = true }

            local builtin = require('telescope.builtin')
            vim.keymap.set('n', keys.find_files, builtin.find_files, option)
            vim.keymap.set('n', keys.find_files_case, function()
                builtin.find_files({
                    sorter = require'telescope'.extensions.fzf.native_fzf_sorter({ case_mode = "respect_case", fuzzy = true }),
                })
            end, option)
            -- later rg flags override earlier ones, so these win over rg's default --smart-case
            vim.keymap.set('n', keys.live_grep, function()
                builtin.live_grep({ additional_args = { "--ignore-case" } })
            end, option)
            vim.keymap.set('n', keys.live_grep_case, function()
                builtin.live_grep({ additional_args = { "--case-sensitive" } })
            end, option)
            vim.keymap.set('n', keys.search_cursor, builtin.grep_string, option)
            vim.keymap.set('n', keys.find_buffer, builtin.buffers, option)
        end,
    },
}
