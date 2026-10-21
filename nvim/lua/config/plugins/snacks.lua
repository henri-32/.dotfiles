local M = {}

function M.setup()
	require("snacks").setup({
		picker = {
			enabled = true,
		},
		input = {
			enabled = true,
		},
		notifier = {
			enabled = true,
			timeout = 2000,
			style = "minimal",
		},
	})
end

return M
