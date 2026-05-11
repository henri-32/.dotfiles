local M = {}

function M.setup()
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        callback = function()
            vim.opt_local.colorcolumn = "79"
        end,
    })

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
            vim.opt_local.colorcolumn = "75"
            vim.opt_local.wrap = true
            vim.opt_local.linebreak = true
        end,
    })

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        callback = function()
            vim.opt_local.tabstop = 4
            vim.opt_local.shiftwidth = 4
            vim.opt_local.softtabstop = 4
            vim.opt_local.expandtab = true
        end,
    })
	
	vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "FileType" }, {
		callback = function()
			local ft = vim.bo.filetype
			local bt = vim.bo.buftype

			if ft == "TelescopePrompt"
				or ft == "TelescopeResults"
				or bt == "prompt"
				or bt == "nofile"
				or bt == "help"
			then
				vim.opt_local.paste = false
			else
				vim.opt_local.paste = true
			end
		end,
	})
end

return M
