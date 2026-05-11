local M = {}

function M.setup()
    local actions = require("telescope.actions")

    require("telescope").setup({
        defaults = {
            mappings = {
                i = {
                    ["<M-l>"] = actions.send_to_loclist + actions.open_loclist,
                    ["<C-l>"] = actions.send_selected_to_loclist + actions.open_loclist,
                    ["<C-l>a"] = actions.add_selected_to_loclist + actions.open_loclist,
                },
            },
        },
    })
end

return M
