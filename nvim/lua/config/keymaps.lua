local M = {}

function M.setup()
    local telescope = require("telescope.builtin")
    local state = require("config.state")
	
	-- ========= REGISTER DEFAULTS ==============
	-- Öffnet mir die { so dass ich direkt schreiben kann (\x1b) ist Esc
	vim.fn.setreg("u", "a{\n\n}\x1bki  ")
	vim.fn.setreg("m", ":wall\n:make \n:make test run_test\n")

    -- ========= COMPLETION =========
    vim.keymap.set("n", "<leader>cc", function()
		vim.o.autocomplete = not vim.o.autocomplete
		print("autocomplete: " .. tostring(vim.o.autocomplete))
    end)

    -- ========= LSP: NAVIGATION =========
	vim.keymap.set("n", "gf", vim.lsp.buf.signature_help)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
    vim.keymap.set("n", "K", vim.lsp.buf.hover)
    vim.keymap.set("n", "gr", vim.lsp.buf.references)

    -- ========= LSP: ACTIONS =========
    vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
    vim.keymap.set("n", "<leader>lr", ":LspRestart<CR>")
    vim.keymap.set("n", "<leader>f", function()
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

    -- ========= DIAGNOSTICS =========
    vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float)
    vim.keymap.set("n", "<leader>do", vim.diagnostic.setloclist)
    vim.keymap.set("n", "<leader>dd", vim.diagnostic.goto_prev)
    vim.keymap.set("n", "<leader>DD", vim.diagnostic.goto_next)

	-- ========= DEBUGGER =========
	local dap = require("dap")
	local dapui = require("dapui")

	vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debugger: start/continue" })
	vim.keymap.set("n", "<leader>uo", dap.step_out, { desc = "Debugger: step out" })
	vim.keymap.set("n", "<leader>ub", dap.toggle_breakpoint, { desc = "Debugger: toggle breakpoint" })
	vim.keymap.set("n", "<leader>un", dap.step_over, { desc = "Debugger: step over" })
	vim.keymap.set("n", "<leader>ui", dap.step_into, { desc = "Debugger: step into" })
	vim.keymap.set("n", "<leader>uq", dap.terminate, { desc = "Debugger: terminate" })
	vim.keymap.set("n", "<leader>ud", dapui.toggle, { desc = "Debugger: toggle UI" })
	vim.keymap.set({ "n", "v" }, "<leader>ue", dapui.eval, { desc = "Debugger: evaluate" })
	vim.keymap.set("n", "<leader>ur", dap.repl.open, { desc = "Debugger: open REPL" })

    -- ========= TELESCOPE: FILES / SEARCH =========
    vim.keymap.set("n", "<leader>ff", telescope.find_files)
    vim.keymap.set("n", "<leader>fg", telescope.live_grep)
    vim.keymap.set("n", "<leader>fb", telescope.buffers)
    vim.keymap.set("n", "<leader>fd", telescope.lsp_document_symbols)
    vim.keymap.set("n", "<leader>fl", telescope.lsp_workspace_symbols)
    vim.keymap.set("n", "<leader>fw", function()
        local word = vim.fn.expand("<cword>")
        telescope.live_grep({
            default_text = word,
        })
    end)

    -- ========= TELESCOPE: SPLIT WORKFLOWS =========
    vim.keymap.set("n", "<leader>fs", function()
        vim.cmd("split")
        telescope.find_files()
    end)
    vim.keymap.set("n", "<leader>fv", function()
        vim.cmd("vsplit")
        telescope.find_files()
    end)
    vim.keymap.set("n", "<leader>gs", function()
        vim.cmd("split")
        telescope.live_grep()
    end)
    vim.keymap.set("n", "<leader>gv", function()
        vim.cmd("vsplit")
        telescope.live_grep()
    end)

    -- ========= HARPOON =========
    local harpoon = require("harpoon")
    vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
	vim.keymap.set("n", "<leader>s", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
	vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end)
	vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end)
	vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end)
	vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end)



    -- ========= WINDOWS =========
    vim.keymap.set("n", "<leader>h", "<C-w>h")
    vim.keymap.set("n", "<leader>j", "<C-w>j")
    vim.keymap.set("n", "<leader>k", "<C-w>k")
    vim.keymap.set("n", "<leader>l", "<C-w>l")
    vim.keymap.set("n", "<leader>wv", "<C-w>v")
    vim.keymap.set("n", "<leader>ws", "<C-w>s")
    vim.keymap.set("n", "<leader>ww", "<C-w>o")
	vim.keymap.set("n", "<leader>x", "<C-w>c")
	vim.keymap.set("n", "<leader>m", "<cmd>Maximize<CR>")
	vim.keymap.set("n", "<C-j>", "<C-d>")
	vim.keymap.set("n", "<C-k>", "<C-u>")

    -- ========= TERMINAL =========
    vim.keymap.set("i", "<Esc>", "<Esc>", { nowait = true, silent = true })
    vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { nowait = true, silent = true })
    vim.keymap.set("n", "<leader>t", function()
        vim.cmd("term")
    end)
    vim.keymap.set("n", "<leader>tt", function()
        vim.cmd("split")
        vim.cmd("term")
    end)

    -- ========= QUICKFIX =========
    vim.keymap.set("n", "<leader>n", "<cmd>cnext<CR>")
    vim.keymap.set("n", "<leader>N", "<cmd>cprev<CR>")
    vim.keymap.set("n", "<leader>q", function()
		require("quicker").toggle()
	end)

    -- hiermit kann ich gtest ergebnisse in eine datei schreiben und die in die
	-- quickfixlist laden 
    vim.keymap.set("n", "<leader>qf", function()
        vim.cmd("cfile neovim_utils/quickfix_list.txt")
        vim.cmd("copen")
    end)

	-- ========= LOCLIST =========
	vim.keymap.set("n", "<leader>ll", function()
		require("quicker").toggle({loclist = true})
	end)
	vim.keymap.set("n", "<C-u>", "<cmd>lnext<CR>")
	vim.keymap.set("n", "<C-i>", "<cmd>lprev<CR>")

    -- ========= EDITOR NAVIGATION =========
    vim.keymap.set("n", "<leader>o", "<C-o>", { desc = "Jump back in jumplist" })
    vim.keymap.set("n", "<leader>i", "<C-i>", { desc = "Jump forward in jumplist" })
    vim.keymap.set("n", "j", "gj", { noremap = true, silent = true })
    vim.keymap.set("n", "k", "gk", { noremap = true, silent = true })
    vim.keymap.set("n", "<Esc>", function()
        vim.cmd("nohlsearch")
    end)
	vim.keymap.set("n", "<leader>e", "<cmd>e .<CR>")
	vim.keymap.set("n", "<leader>ee", function ()
		vim.cmd("split")
		vim.cmd("e .")
	end)
	
	vim.keymap.set("n", "<leader>fr", function()
		vim.cmd("edit")
		vim.notify("File refreshed")
	end)

    -- ========= FILE PATH COPYING =========
    vim.keymap.set("n", "<leader>fcy", function()
        vim.fn.setreg("+", vim.fn.expand("%:p"))
        vim.notify("absolute path copied to clipboard")
    end)
    vim.keymap.set("n", "<leader>fy", function()
        vim.fn.setreg("+", vim.fn.expand("%"))
        vim.notify("relative path copied to clipboard")
    end)

    -- ========= SAVE / QUIT =========
    vim.keymap.set("n", "<leader>w", function()
        vim.cmd("w")
    end)
	vim.keymap.set("n", "<leader>wa", function()
		vim.cmd("wall")
	end)
    vim.keymap.set("n", "<leader>wq", function()
        vim.cmd("w")
        vim.cmd("q")
    end)
end

return M
