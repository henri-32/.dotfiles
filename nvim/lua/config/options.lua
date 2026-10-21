local M = {}

function M.setup()
	local state = require("config.state")

    vim.o.paste = false
    vim.o.number = true
    vim.o.relativenumber = true
    vim.o.timeoutlen = 300
    vim.o.ttimeout = true
    vim.o.ttimeoutlen = 0
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
	vim.o.autocomplete = state.text_completion_enabled
	vim.opt.complete = { ".", "b" }
	vim.opt.completeopt = { "menu", "menuone", "noselect", "popup" }
    vim.cmd("filetype indent off")
end

return M
