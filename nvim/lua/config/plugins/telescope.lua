local M = {}

function M.setup()
    local actions = require("telescope.actions")

    require("telescope").setup({
        defaults = {
            mappings = {
                i = {
                    ["<C-l>"] = actions.send_to_loclist + actions.open_loclist,
					["<C-l>a"] = actions.add_to_loclist + actions.open_loclist,
                    ["<C-L>"] = actions.send_selected_to_loclist + actions.open_loclist,
                    ["<C-L>a"] = actions.add_selected_to_loclist + actions.open_loclist,
                },
            },
        },
    })
end

return M
