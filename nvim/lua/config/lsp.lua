local M = {}

function M.setup()
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

    vim.lsp.config("clangd", vim.tbl_deep_extend("force", base_config, {
        cmd = {
            "clangd",
            "--query-driver=/usr/bin/avr-g++,/usr/bin/avr-gcc,/usr/bin/g++,/usr/bin/gcc,/home/henri-32/.espressif/tools/xtensa-esp-elf/*/xtensa-esp-elf/bin/xtensa-esp32-elf-*",
            "--background-index=true",
            "--clang-tidy=false",
            "--all-scopes-completion=false",
            "--limit-results=10",
            "--completion-style=bundled",
            "--header-insertion=never",
        },
    }))
    vim.lsp.enable("clangd")

    vim.lsp.config("lua_ls", vim.tbl_deep_extend("force", base_config, {
        settings = {
            Lua = {
                diagnostics = {
                    globals = { "vim" },
                },
                workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                },
            },
        },
    }))
    vim.lsp.enable("lua_ls")

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

    vim.diagnostic.config({
        update_in_insert = false,
        virtual_text = false,
        underline = false,
        severity_sort = true,
    })
end

return M
