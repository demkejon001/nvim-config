--[[
I feel like typing () is not working

When there is a C error with a function fn(a, ), I can't type ctrl+k to see the function definition.


How to check signature in middle of function?
How to do snippets, i.e. go to next piece.

]]



-- =====================================================================
-- LEADER KEY
-- =====================================================================
-- Set this first before any keymaps are defined
vim.g.mapleader = " "

-- =====================================================================
-- GENERAL OPTIONS
-- =====================================================================
vim.opt.ignorecase = true             -- Case insensitive search
vim.opt.smartcase = true              -- Case sensitive if uppercase in search
vim.opt.hlsearch = true               -- Don't highlight search results permanently
vim.opt.incsearch = true              -- Show matches as you type

vim.opt.clipboard:append("unnamedplus") -- Use system clipboard
vim.opt.undofile = true               -- Persistent undo history
vim.opt.termguicolors = true          -- True color support

-- Editor layout & formatting
vim.opt.number = true                 -- Absolute line numbers
vim.opt.relativenumber = true         -- Relative line numbers
vim.opt.tabstop = 4                   -- Tab width
vim.opt.shiftwidth = 4                -- Indentation width
vim.opt.expandtab = false             -- Use tabs, not spaces
vim.opt.smartindent = true            -- Smart auto-indenting
vim.opt.signcolumn = 'yes:1'          -- Fixed gutter for git signs/diagnostics
vim.opt.splitright = true             -- Force all vertical splits to open on the right

-- Native Autocompletion Options (Neovim 0.11+)
vim.opt.complete = ".,o"              -- Include buffer and omnifunc sources
vim.opt.completeopt = "fuzzy,menuone,noselect,noinsert" -- The unified setting!
vim.opt.autocomplete = true           -- Enable native autocompletion trigger
vim.opt.autocompletedelay = 250       -- Delay to prevent flickering
vim.opt.pumheight = 10                -- Limit autocomplete menu to 10 items

-- =====================================================================
-- UI & FOLDING
-- =====================================================================
vim.opt.foldlevel = 99                -- Start with all folds open
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.lsp.foldexpr()"

_G.custom_fold_text = function()
    local start_line = vim.fn.getline(vim.v.foldstart)
    local line_count = vim.v.foldend - vim.v.foldstart + 1
    return start_line .. " {} // " .. line_count .. " lines folded"
end
vim.opt.foldtext = "v:lua.custom_fold_text()"


-- =====================================================================
-- PACKAGE MANAGEMENT & PLUGINS
-- =====================================================================
vim.pack.add({
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/stevearc/conform.nvim" },
    { src = "https://github.com/lewis6991/gitsigns.nvim" },
    { src = "https://github.com/nvim-tree/nvim-web-devicons" },
    { src = "https://github.com/nvim-mini/mini.icons" },
    { src = "https://github.com/stevearc/oil.nvim" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/nvim-telescope/telescope.nvim" },
    { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	{ src = "https://github.com/folke/todo-comments.nvim" },
    { src = "https://github.com/echasnovski/mini.pairs" },
})

-- Initialize basic plugins

vim.cmd.colorscheme("catppuccin")
-- vim.api.nvim_create_autocmd("ColorScheme", {
--     group = vim.api.nvim_create_augroup("custom_todo_highlight", { clear = true }),
--     pattern = "*",
--     callback = function()
--         vim.api.nvim_set_hl(0, "@comment.todo", { fg = "#0000ff", bold = true })
--     end,
-- })
--
-- -- Now you can load your colorscheme safely
-- vim.cmd.colorscheme("catppuccin")

require("mini.icons").setup()
require("nvim-web-devicons").setup()
require("oil").setup({ default_file_explorer = true })
require('mini.pairs').setup()

-- Gemini says this no longer needs to be true
-- require('nvim-treesitter').install({ 'vim', 'vimdoc', 'query', 'rust', 'python', 'lua', 'c', 'latex', 'markdown', 'markdown_inline' })

require("conform").setup({
    formatters_by_ft = { c = { "clang_format" }, cpp = { "clang_format" } },
    format_on_save = { timeout_ms = 500, lsp_fallback = true },
})

-- =====================================================================
-- TREESITTER & PARSER INSTALLATION
-- =====================================================================
local ensure_installed = { 
    "c", "cpp", "lua", "vim", "vimdoc", "query", 
    "rust", "python", "latex", "markdown", "markdown_inline" 
}

-- Diff against already installed parsers to prevent rebuilding on every startup
local already_installed = require('nvim-treesitter.config').get_installed()
local missing_parsers = vim.iter(ensure_installed)
    :filter(function(parser) return not vim.tbl_contains(already_installed, parser) end)
    :totable()

if #missing_parsers > 0 then
    require('nvim-treesitter').install(missing_parsers)
end

-- Enable Neovim's native tree-sitter highlighting 
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("treesitter_highlight", { clear = true }),
    callback = function()
        pcall(vim.treesitter.start)
    end,
})

-- =====================================================================
-- TREESITTER TEXTOBJECTS
-- =====================================================================
-- `set_jumps` is one of the few config options left in the setup table
require('nvim-treesitter-textobjects').setup({
    move = { set_jumps = true }
})

local ts_move = require('nvim-treesitter-textobjects.move')

-- You must now use native keymaps for all textobject motions
vim.keymap.set({ "n", "x", "o" }, "]m", function()
    ts_move.goto_next_start("@function.outer", "textobjects")
end, { desc = "Next function start" })

vim.keymap.set({ "n", "x", "o" }, "]]", function()
    ts_move.goto_next_start("@class.outer", "textobjects")
end, { desc = "Next class start" })

vim.keymap.set({ "n", "x", "o" }, "[m", function()
    ts_move.goto_previous_start("@function.outer", "textobjects")
end, { desc = "Previous function start" })

vim.keymap.set({ "n", "x", "o" }, "[[", function()
    ts_move.goto_previous_start("@class.outer", "textobjects")
end, { desc = "Previous class start" })


-- =====================================================================
-- COMMENT HIGHLIGHTING (e.g. TODO)
-- =====================================================================
require("todo-comments").setup({
    signs = false,      -- Show icons in the sign column
    sign_priority = 8, -- Sign priority
    keywords = {
        FIX = {
            color = "error", -- can be a hex color, or a named color
            alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
        },
        TODO = { color = "info", alt = {"todo"} },
        HACK = { color = "warning" },
        WARN = { color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { color = "hint", alt = { "INFO" } },
    },
	highlight = {
        multiline = false,
        keyword = "bg",
        pattern = [=[.*<(KEYWORDS)\s*[:(]]=],
    },
    search = {
        command = "rg",
        args = {
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
        },
        pattern = [=[\b(KEYWORDS)\s*[:(]]=],
    },
})


-- =====================================================================
-- AUTOCOMMANDS
-- =====================================================================
-- No auto continue comments on new line
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("no_auto_comment", { clear = true }),
    callback = function()
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
})

-- Restore cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
    group = vim.api.nvim_create_augroup("restore_cursor", { clear = true }),
    callback = function(args)
        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        local line_count = vim.api.nvim_buf_line_count(args.buf)
        if mark[1] > 0 and mark[1] <= line_count then
            vim.api.nvim_win_set_cursor(0, mark)
            vim.schedule(function() vim.cmd("normal! zz") end)
        end
    end,
})

-- =====================================================================
-- 6. GENERAL KEYMAPS
-- =====================================================================
vim.keymap.set("i", "jk", "<Esc>", { desc = "Escape insert mode" })
vim.keymap.set('n', '<Esc>', ':nohlsearch<CR>', { silent = true })

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { silent = true })
vim.keymap.set('n', '<C-j>', '<C-w>j', { silent = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { silent = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { silent = true })

-- Buffer navigation
vim.keymap.set('n', '<S-l>', ':bnext<CR>', { silent = true })
vim.keymap.set('n', '<S-h>', ':bprevious<CR>', { silent = true })
vim.keymap.set('n', '<leader>bd', ':bdelete<CR>', { silent = true })

-- Recentering helpers
vim.keymap.set("n", "<C-o>", "<C-o>zz", { desc = "Jump back and center screen" })
vim.keymap.set("n", "<C-i>", "<C-i>zz", { desc = "Jump forward and center screen" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result, center, open fold" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev search result, center, open fold" })

-- Quickfix list navigation
vim.keymap.set('n', '<leader>cn', ':cnext<CR>', { silent = true })
vim.keymap.set('n', '<leader>cp', ':cprevious<CR>', { silent = true })
vim.keymap.set('n', '<leader>co', ':copen<CR>', { silent = true })

-- Formatting
vim.keymap.set({ "n", "v" }, "<leader>f", function()
    require("conform").format({ lsp_fallback = true, timeout_ms = 500 })
end, { desc = "Format file or range" })

-- Telescope
local telescope = require("telescope.builtin")
vim.keymap.set('n', '<leader>ff', telescope.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', telescope.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', telescope.buffers, { desc = 'Telescope buffers' })

-- Terminal
vim.keymap.set('t', 'jk', '<C-\\><C-n>', { silent = true })

-- Autocomplete Menu Navigation (Using Tab and Shift-Tab)
vim.keymap.set('i', '<Tab>',   [[pumvisible() ? "\<C-n>" : "\<Tab>"]],   { expr = true })
vim.keymap.set('i', '<S-Tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true })
-- Smart Enter Key
vim.keymap.set('i', '<CR>', function()
    -- 1. Autocomplete menu is open
    if vim.fn.pumvisible() == 1 then
        if vim.fn.complete_info({ 'selected' }).selected ~= -1 then
            return "<C-y>" -- Accept selection
        else
            return "<C-e><CR>" -- Cancel menu and add newline
        end
    end
    -- 2. Menu is closed: Let mini.pairs handle the Enter key for braces
    if _G.MiniPairs then
        return _G.MiniPairs.cr()
    end
    -- 3. Fallback to normal Enter
    return "<CR>"
end, { expr = true, replace_keycodes = true })


-- =====================================================================
-- NATIVE SNIPPETS (Function Argument Expansion)
-- =====================================================================
-- When you accept a completion for a function (e.g., `my_func(arg1, arg2)`),
-- the LSP inserts "snippet markers". These mappings let you jump between them!
vim.keymap.set({ 'i', 's' }, '<C-l>', function()
    if vim.snippet.active({ direction = 1 }) then
        return '<cmd>lua vim.snippet.jump(1)<CR>'
    end
end, { expr = true, silent = true, desc = "Jump to next snippet variable" })

vim.keymap.set({ 'i', 's' }, '<C-h>', function()
    if vim.snippet.active({ direction = -1 }) then
        return '<cmd>lua vim.snippet.jump(-1)<CR>'
    end
end, { expr = true, silent = true, desc = "Jump to previous snippet variable" })


-- =====================================================================
-- LSP CONFIGURATION
-- =====================================================================
vim.diagnostic.config({
    signs = true,
    underline = true,
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    virtual_text = false,
})

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
    callback = function(event)
        local opts = { buffer = event.buf, silent = true }
        local client = vim.lsp.get_client_by_id(event.data.client_id)

        -- Enable native LSP autocompletion and snippet injection!
        if client then
            vim.lsp.completion.enable(true, client.id, event.buf, {
                autotrigger = true,
            })
        end

        -- LSP Keymaps
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = event.buf, desc = 'Go to declaration' })
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = event.buf, desc = 'Go to definition' })
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = event.buf, desc = 'Go to implementation' })
        vim.keymap.set('n', 'gr', telescope.lsp_references, { buffer = event.buf, desc = "Telescope Go to References" })
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = event.buf, desc = "Hover info" })
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = event.buf, desc = "Rename symbol" })
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = event.buf, desc = "Code action" })

        vim.keymap.set('n', '<leader>e', function() vim.diagnostic.open_float({ scope = 'line' }) end, opts)
        vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
    end,
})

-- Start LSP Servers
vim.lsp.config('basedpyright', {
    settings = {
        basedpyright = {
            analysis = {
                diagnosticSeverityOverrides = {
                    reportUnknownParameterType = 'none',
                    reportMissingParameterType = 'none',
                    reportUnknownArgumentType = 'none',
                },
            },
        },
    },
})

vim.lsp.enable({ 'basedpyright', 'clangd' })



-- =====================================================================
-- Text File Formatting
-- =====================================================================
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "text", "markdown", "tex" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true

    vim.keymap.set("n", "j", "gj", { buffer = true })
    vim.keymap.set("n", "k", "gk", { buffer = true })
    vim.keymap.set("n", "0", "g0", { buffer = true })
    vim.keymap.set("n", "$", "g$", { buffer = true })
  end,
})


-- =====================================================================
-- ":" Commands
-- =====================================================================
vim.api.nvim_create_user_command("Run", "vsplit | terminal ./run.sh", {})
vim.api.nvim_create_user_command("HotReload", "!./hot_reload.sh", {})

-- Create smart lowercase abbreviations (run -> Run, hot -> HotReload)
vim.cmd([[
  cnoreabbrev <expr> run (getcmdtype() == ':' && getcmdline() == 'run') ? 'Run' : 'run'
  cnoreabbrev <expr> hot (getcmdtype() == ':' && getcmdline() == 'hot') ? 'HotReload' : 'hot'
]])

vim.keymap.set('n', '<leader>run', ':vsplit | terminal ./run.sh<CR>', { noremap = true, silent = true, desc = 'run the run.sh script' })
vim.keymap.set('n', '<leader>hot', ':!./hot_reload.sh<CR>', { noremap = true, silent = true, desc = 'Hot Reload script' })

-- -- =====================================================================
-- -- 9. ASYNC BUILD SYSTEM
-- -- =====================================================================
-- local function async_make()
--     local makeprg = vim.api.nvim_get_option_value("makeprg", { buf = 0 })
--     if not makeprg or makeprg == "" then return end
--
--     local cmd = vim.fn.expandcmd(makeprg)
--     local lines = {""}
--
--     local function on_event(_, data, event)
--         if event == "stdout" or event == "stderr" then
--             if data then vim.list_extend(lines, data) end
--         elseif event == "exit" then
--             vim.fn.setqflist({}, " ", {
--                 title = cmd,
--                 lines = lines,
--                 efm = vim.api.nvim_get_option_value("errorformat", { buf = 0 })
--             })
--             vim.api.nvim_command("doautocmd QuickFixCmdPost")
--             print("Async build completed: " .. cmd)
--         end
--     end
--
--     vim.fn.jobstart(cmd, {
--         on_stdout = on_event,
--         on_stderr = on_event,
--         on_exit = on_event,
--         stdout_buffered = true,
--         stderr_buffered = true,
--     })
--     print("Building asynchronously...")
-- end
--
-- vim.keymap.set('n', '<leader>m', async_make, { desc = "Run async make" })
--
--
