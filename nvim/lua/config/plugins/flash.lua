local M = {}

function M.setup()
	local flash = require("flash")

	flash.setup({
		modes = {
			char = {
				enabled = true,
				jump_labels = true,
			},
			search = {
				enabled = false,
			},
		},
	})

	vim.keymap.set({ "n", "x", "o" }, "s", function()
		flash.jump()
	end, { desc = "Flash jump" })

	vim.keymap.set({ "n", "x", "o" }, "S", function()
		flash.treesitter()
	end, { desc = "Flash Treesitter" })

	vim.keymap.set("o", "r", function()
		flash.remote()
	end, { desc = "Remote Flash" })

	vim.keymap.set({ "o", "x" }, "R", function()
		flash.treesitter_search()
	end, { desc = "Treesitter search" })

	vim.keymap.set("c", "<C-s>", function()
		flash.toggle()
	end, { desc = "Toggle Flash search" })
end

return M
