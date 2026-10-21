local M = {}

function M.setup()
	local function setup_plugin()
		require("bookmarks").setup({
			picker = {
				picker_backend = "snacks",
			},
		})
	end

	-- Native start packages source plugin/bookmarks.lua after init.lua. Defer
	-- setup so that its global declarations cannot overwrite our config.
	if vim.v.vim_did_enter == 1 then
		setup_plugin()
	else
		vim.api.nvim_create_autocmd("VimEnter", {
			once = true,
			callback = setup_plugin,
		})
	end
end

return M
