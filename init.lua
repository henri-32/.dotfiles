-- ========= CORE: LEADER & KEYMAPS =========
vim.g.mapleader = " "
require("config.keymaps").keymaps()

-- ========= OPTIONS =========
-- Performance-Modus (roh tippen)
vim.o.paste = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.timeoutlen = 300
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.clipboard = "unnamedplus"
vim.o.lazyredraw = true
vim.o.smartindent = false
vim.o.cindent = false
vim.o.autoindent = false
vim.o.formatoptions = ""
vim.o.foldmethod = "marker"
vim.o.foldmarker = "{{{,}}}"
vim.o.foldcolumn = "1"
vim.cmd("filetype indent off")


-- ========= telescope.actions======== 
local actions = require("telescope.actions")
require("telescope").setup({
	defaults = {
		mappings = {
			i = {         
				["<M-l>"] = actions.send_to_loclist
					+ actions.open_loclist,

				["<C-l>"] = actions.send_selected_to_loclist
					+ actions.open_loclist, 
	
				["<C-l>a"] = actions.add_selected_to_loclist
					+ actions.open_loclist,


			},
		},
	},
})
-- ========= quicker.nvim ============
require("quicker").setup({
	keys = {
		{
		  ">", 
		  function()
			require("quicker").expand({before = 2, after = 2, add_to_existing = true})
		  end
		},
		{
		  "<", 
		  function()
			require("quicker").collapse()
		  end 
		}
	},
})

-- ========= UI: THEME =========
require("catppuccin").setup({
    flavour = "macchiato",
})
vim.cmd.colorscheme("catppuccin")

-- ========= AUTOCMDS: FILETYPE OPTIONS =========
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

-- ========= CMP: SETUP =========
local cmp = require("cmp")
autocomplete_enabled = true

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
    end,
})

-- ========= LSP: BASE CONFIG =========
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

-- ========= LSP: SERVERS =========
vim.lsp.config("clangd", vim.tbl_deep_extend("force", base_config, {
    cmd = {
        "clangd",
        "--query-driver=/usr/bin/avr-g++",
        "--query-driver=/usr/bin/avr-gcc",
        "--query-driver=/usr/bin/g++",
        "--background-index=true",
        "--clang-tidy=false",
        "--all-scopes-completion=false",
        "--limit-results=10",
        "--completion-style=bundled",
        "--header-insertion=never",
    },
}))
vim.lsp.enable("clangd")

vim.lsp.config("pyright", vim.tbl_deep_extend("force", base_config, {
    on_attach = function(client)
        client.server_capabilities.documentFormattingProvider = false
    end,
}))
vim.lsp.enable("pyright")

vim.lsp.config("ruff", vim.tbl_deep_extend("force", base_config, {
    cmd = { "ruff", "server" },
    flags = {
        debounce_text_changes = 400,
    },
}))
vim.lsp.enable("ruff")

-- ========= LSP: DIAGNOSTICS =========
vim.diagnostic.config({
    update_in_insert = false,
    virtual_text = false,
    underline = false,
    severity_sort = true,
})

-- ========= AUTOCMDS: PASTE-MODE =========
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
