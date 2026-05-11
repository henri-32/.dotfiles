local M = {}

function M.setup()
    local cmp = require("cmp")
    local state = require("config.state")
    local timer = vim.loop.new_timer()
    local delay = 800

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
        if not state.autocomplete_enabled then
            return
        end
        if not should_trigger_completion() then
            return
        end

        cmp.complete()
    end

    local function schedule_completion()
        if not state.autocomplete_enabled then
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
end

return M
