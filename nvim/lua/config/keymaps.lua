local M = {}
function M.setup()
	local state     = require("config.state")
	local telescope = require("telescope.builtin")

	-- ========= REGISTER DEFAULTS ==============
	-- Öffnet mir die { so dass ich direkt schreiben kann (\x1b) ist Esc
	vim.fn.setreg("u", "a{\n\n}\x1bki  ")
	vim.fn.setreg("m", ":wall\n:make \n:make test run_test\n")

	-- ========= COMPLETION =========
	local function set_text_completion(enabled)
		state.text_completion_enabled = enabled
		vim.go.autocomplete = enabled

		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_loaded(buf) then
				vim.bo[buf].autocomplete = enabled
			end
		end
	end

	local function set_lsp_completion(enabled)
		state.lsp_completion_enabled = enabled
		local targets = {}

		for _, client in ipairs(vim.lsp.get_clients()) do
			if client:supports_method("textDocument/completion") then
				for buf in pairs(client.attached_buffers) do
					table.insert(targets, { client_id = client.id, bufnr = buf })
				end
			end
		end

		-- Recreate the native completion handler because changing autotrigger on
		-- an already-enabled buffer does not update its InsertCharPre autocmd.
		for _, target in ipairs(targets) do
			vim.lsp.completion.enable(false, target.client_id, target.bufnr)
		end
		for _, target in ipairs(targets) do
			vim.lsp.completion.enable(true, target.client_id, target.bufnr, {
				autotrigger = enabled,
			})
		end
	end

	vim.keymap.set("n", "<leader>cc", function()
		if state.text_completion_enabled then
			set_text_completion(false)
			vim.notify("Text completion OFF")
		else
			set_text_completion(true)
			vim.notify("Text completion ON")
		end
	end)

	vim.keymap.set("n", "<leader>cl", function()
		if state.lsp_completion_enabled then
			set_lsp_completion(false)
			vim.notify("LSP completion OFF")
		else
			set_lsp_completion(true)
			vim.notify("LSP completion ON")
		end
	end)

	vim.keymap.set("i", "<C-c>", vim.lsp.completion.get, {
		desc = "Trigger LSP completion",
	})

	vim.keymap.set("i", "<Tab>", function()
		if vim.fn.pumvisible() == 1 then
			local selected = vim.fn.complete_info({ "selected" }).selected
			return selected == -1 and "<C-n><C-y>" or "<C-y>"
		end
		return "<Tab>"
	end, { expr = true, desc = "Confirm completion or insert tab" })

	-- ========= LSP: NAVIGATION =========
	vim.keymap.set("n", "<leader>lf", vim.lsp.buf.signature_help)
	vim.keymap.set("n", "L", vim.lsp.buf.definition)
	vim.keymap.set("n", "<leader>ld", vim.lsp.buf.declaration)
	vim.keymap.set("n", "K", vim.lsp.buf.hover)
	vim.keymap.set("n", "<leader>lR", vim.lsp.buf.references)

	-- ========= LSP: ACTIONS =========
	vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename)
	vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action)
	vim.keymap.set("n", "<leader>lr", ":LspRestart<CR>")
	vim.keymap.set("n", "<leader>lf", function()
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
	 vim.keymap.set("n", "<leader>le", vim.diagnostic.open_float)
	-- vim.keymap.set("n", "<leader>do", vim.diagnostic.setloclist)
	-- vim.keymap.set("n", "<leader>dd", vim.diagnostic.goto_prev)
	-- vim.keymap.set("n", "<leader>DD", vim.diagnostic.goto_next)

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
		require("quicker").toggle({ loclist = true })
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
	vim.keymap.set("n", "<leader>ö", "o<Esc>")
	vim.keymap.set("n", "<leader>Ö", "O<Esc>")
	vim.keymap.set("n", "<leader>e", "<cmd>e .<CR>")
	vim.keymap.set("n", "<leader>ee", function()
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
end

return M
