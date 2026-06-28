local M = {}

function M.setup()
    vim.g.mapleader = " "

    require("config.options").setup()
    require("config.plugins.telescope").setup()
    require("config.plugins.quicker").setup()
    require("config.plugins.theme").setup()
    require("config.cmp").setup()
    require("config.lsp").setup()
    require("config.autocmds").setup()
    require("config.keymaps").setup()
	require("config.usercmds").setup()
	require("config.plugins.yazi").setup()
end

return M
