local M = {}

function M.setup()
    require("quicker").setup({
        keys = {
            {
                ">",
                function()
                    require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
                end,
            },
            {
                "<",
                function()
                    require("quicker").collapse()
                end,
            },
        },
    })
end

return M
