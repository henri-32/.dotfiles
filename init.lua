-- ========= BASIC =========
-- Performance-Modus (roh tippen)
vim.o.paste = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.clipboard = "unnamedplus"
vim.o.lazyredraw = true
vim.o.smartindent = false
vim.o.cindent = false
vim.o.autoindent = false
vim.o.formatoptions = ""
vim.g.mapleader = " "
vim.cmd("filetype indent off")

-- ========= THEME =========
require("catppuccin").setup({
   flavour = "macchiato",
})

vim.cmd.colorscheme("catppuccin")

-- ========= COLORCOLUMN =========
vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
        vim.opt_local.colorcolumn = "79"
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown", 
    callback = function()
        vim.opt_local.colorcolumn = "75"
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true 
    end, 
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.softtabstop = 4
        vim.opt_local.expandtab = true
    end,
})

-- ========= CMP =========
local cmp = require("cmp")
local cmp_types = require("cmp.types")
local autocomplete_enabled = true

cmp.setup({
    completion = {
        autocomplete = false,
    },
    performance = {
        max_view_entries = 10,
    },
    sources = {
        { name = "nvim_lsp" },
    },
    mapping = {
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.confirm({ select = true })
            else
                fallback()
            end
        end, { "i", "s" }),

        ["<M-j>"] = cmp.mapping.select_next_item(),
        ["<M-k>"] = cmp.mapping.select_prev_item(),
        ["<Esc>"] = cmp.mapping.abort(),
    },
})

local timer = vim.loop.new_timer()
local delay = 800

local function should_trigger_completion()
    local col = vim.fn.col(".") - 1
    if col <= 0 then
        return true
    end

    local line = vim.fn.getline(".")
    local char_before = line:sub(col, col)

    return not char_before:match("%s")
end

local function trigger_completion()
    if vim.api.nvim_get_mode().mode ~= "i" then
        return
    end

    if not autocomplete_enabled then
        return
    end

    if not should_trigger_completion() then
        return
    end

    cmp.complete()
end

local function schedule_completion()
if not autocomplete_enabled then
return
end

timer:stop()
timer:start(delay, 0, vim.schedule_wrap(trigger_completion))
end

vim.api.nvim_create_autocmd("TextChangedI", {
callback = function()
cmp.close()
schedule_completion()
end
})

vim.keymap.set("n", "<leader>cc", function()
    autocomplete_enabled = not autocomplete_enabled
end)

-- ========= LSP BASE CONFIG =========

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.general = {
    positionEncodings = { "utf-8" },
}

local base_config = {
    capabilities = capabilities,
    flags = {
        debounce_text_changes = 400,
    },
}

-- ========= LSP =========
vim.lsp.config("clangd", vim.tbl_deep_extend("force", base_config, {
    cmd = {
        "clangd",
		"--query-driver=/usr/bin/avr-g++",
		"--query-driver=/usr/bin/avr-gcc",
-- Ob nur im Build gesucht wird oder überall
-- Kostet vllt etwas viel performance auf T520
        "--background-index=false",
        "--clang-tidy=false",
        "--all-scopes-completion=false",
        "--limit-results=10",
        "--completion-style=bundled",
        "--header-insertion=never",
    },
}))

vim.lsp.enable("clangd")

-- ---------- PYTHON LSP ----------
vim.lsp.config("pyright", vim.tbl_deep_extend("force", base_config, {
	on_attach = function(client)
		client.server_capabilities.documentFormattingProvider = false
	end,
}))

vim.lsp.enable("pyright")


-- ---------- RUFF LSP ----------
vim.lsp.config("ruff", vim.tbl_deep_extend("force", base_config, {
    cmd = { "ruff", "server" },
    flags = {
        debounce_text_changes = 400,
    },
}))
vim.lsp.enable("ruff")

-- ========= DIAGNOSTICS =========
vim.diagnostic.config({
    update_in_insert = false,
    virtual_text = false,
    underline = false,
    severity_sort = true,
})

-- ========= LSP KEYMAPS =========
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "gr", vim.lsp.buf.references)

vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
vim.keymap.set("n", "<leader>cf", function()
    vim.lsp.buf.format({
        async = false,
        filter = function(client)
            if vim.bo.filetype == "python" then
                return client.name == "ruff"
            elseif vim.bo.filetype == "cpp" then
                return client.name == "clangd"
            end
            return true
        end,
    })
end)
vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>do", vim.diagnostic.setloclist)

vim.keymap.set("n", "<leader>dd", vim.diagnostic.goto_prev)
vim.keymap.set("n", "<leader>DD", vim.diagnostic.goto_next)

-- ========= TELESCOPE =========
local telescope = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", telescope.find_files)
vim.keymap.set("n", "<leader>fg", telescope.live_grep)
vim.keymap.set("n", "<leader>fb", telescope.buffers)

-- WINDOW SPLIT Mit neuer File ===============
vim.keymap.set("n", "<leader>fs", function()
vim.cmd("split")
require("telescope.builtin").find_files()
end)
vim.keymap.set("n", "<leader>fv", function()
vim.cmd("vsplit")
require("telescope.builtin").find_files()
end)

--WINDOW SPLIT Mit Grep Treffer ================
vim.keymap.set("n", "<leader>gs", function()
	vim.cmd("split")
	require("telescope.builtin").live_grep()
end)
vim.keymap.set("n", "<leader>gv", function()
	vim.cmd("vsplit")
	require("telescope.builtin").live_grep()
end)

vim.keymap.set("n", "<leader>fd", function()
require("telescope.builtin").lsp_document_symbols()
end)
vim.keymap.set("n", "<leader>fl", function()
require("telescope.builtin").lsp_workspace_symbols()
end)
vim.keymap.set('n', '<leader>fw', function()
  local word = vim.fn.expand("<cword>")
  require('telescope.builtin').live_grep({
    default_text = word
  })
end)

-- ========= WINDOWS =========
vim.keymap.set("n", "<leader>hh", "<C-w>h")
vim.keymap.set("n", "<leader>jj", "<C-w>j")
vim.keymap.set("n", "<leader>kk", "<C-w>k")
vim.keymap.set("n", "<leader>ll", "<C-w>l")
vim.keymap.set("n", "<leader>wv", "<C-w>v")
vim.keymap.set("n", "<leader>ws", "<C-w>s")
vim.keymap.set("n", "<leader>q", "<C-w>c")
vim.keymap.set("n", "<leader>ww", "<C-w>o")

-- ========= HIGHLIGHT CLEAR =========
vim.keymap.set("n", "<Esc>", function()
    vim.cmd("nohlsearch")
end)

-- ========= AUTOCMD =========
-- paste überall außer in Prompt/Spezial-Buffern
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "FileType" }, {
    callback = function()
        local ft = vim.bo.filetype
        local bt = vim.bo.buftype

        if ft == "TelescopePrompt"
            or ft == "TelescopeResults"
            or bt == "prompt"
            or bt == "nofile"
            or bt == "help"
        then
            vim.opt_local.paste = false
        else
            vim.opt_local.paste = true
        end
    end,
})

--================= TERMINAL ======================
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]])
vim.keymap.set("n", "<leader>t", function()
	vim.cmd("split")
	vim.cmd("term")
end)

--================= QUICKFIX=======================
vim.keymap.set("n", "<leader>n", "<cmd>cnext<CR>")
vim.keymap.set("n", "<leader>N", "<cmd>cprev<CR>")
vim.keymap.set("n", "<leader>qo", "<cmd>copen<CR>")
vim.keymap.set("n", "<leader>qc", "<cmd>cclose<CR>") 

--================= NVIM OPERATIONS =======================
vim.keymap.set("n", "<leader>o", "<C-o>", { desc = "Jump back in jumplist" })
vim.keymap.set("n", "<leader>i", "<C-i>", { desc = "Jump forward in jumplist" })
vim.keymap.set("n", "j", "gj", { noremap = true, silent = true })
vim.keymap.set("n", "k", "gk", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>fcy", function()
	vim.fn.setreg("+", vim.fn.expand("%:p"))
	vim.notify("absolute path copied to clipboard")
end)
vim.keymap.set("n", "<leader>fy", function()
	vim.fn.setreg("+", vim.fn.expand("%"))
	vim.notify("relative path copied to clipboard")
end)
vim.keymap.set("n", "<leader>w", function()
	vim.cmd("write")
end)
vim.keymap.set("n", "<leader>wq", function()
	vim.cmd("w")
	vim.cmd("q")
end)
