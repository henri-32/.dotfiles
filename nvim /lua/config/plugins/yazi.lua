local M = {}

local function prepend_path(path)
	local current_path = vim.env.PATH or ""

	if not vim.tbl_contains(vim.split(current_path, ":", { plain = true }), path) then
		vim.env.PATH = path .. ":" .. current_path
	end
end

function M.setup(opts)
	vim.g.loaded_netrwPlugin = 1

	local source = debug.getinfo(1, "S").source:sub(2)
	local bin_dir = vim.fn.fnamemodify(source, ":p:h:h") .. "/bin"

	if vim.fn.executable(bin_dir .. "/ya") == 1 then
		prepend_path(bin_dir)
	end

	require("yazi").setup(vim.tbl_deep_extend("force", {
		open_for_directories = true,
	}, opts or {}))
end

return M
