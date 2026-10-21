local M = {}

function M.setup()
	local treesitter = require("nvim-treesitter")
	local languages = { "c", "cpp", "lua", "vim", "vimdoc", "query" }

	treesitter.setup()

	local function start_highlighting(buf)
		if not vim.api.nvim_buf_is_valid(buf) then
			return
		end

		if vim.list_contains(languages, vim.bo[buf].filetype) then
			-- A parser may still be installing during the first startup.
			pcall(vim.treesitter.start, buf)
		end
	end

	-- Highlighting is provided by Neovim and must be enabled explicitly with
	-- the rewritten nvim-treesitter API.
	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("treesitter-highlight", { clear = true }),
		pattern = languages,
		callback = function(args)
			start_highlighting(args.buf)
			vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
			vim.wo.foldmethod = "expr"
			vim.wo.foldlevel = 99
		end,
	})

	-- install() is asynchronous and skips parsers that are already installed.
	-- Start highlighting for already-open buffers once a first-time install is
	-- complete.
	treesitter.install(languages):await(function(err)
		vim.schedule(function()
			if err then
				vim.notify("Failed to install Tree-sitter parsers: " .. tostring(err), vim.log.levels.ERROR)
				return
			end

			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				start_highlighting(buf)
			end
		end)
	end)
end

return M
