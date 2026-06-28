local M = {}

function M.setup()
    require("catppuccin").setup({
        flavour = "macchiato",
    })
    vim.cmd.colorscheme("catppuccin")
end

return M
