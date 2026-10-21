local M = {}

function M.setup()
	if vim.fn.exists(":LspInfo") == 0 then
		vim.api.nvim_create_user_command("LspInfo", "checkhealth vim.lsp", {})
	end

	if vim.fn.exists(":LspRestart") == 0 then
		vim.api.nvim_create_user_command(
			"LspRestart",
			function(info)
				local names = info.fargs

				if #names == 0 then
					names = vim
						.iter(vim.lsp.get_clients())
						:map(function(client)
							return client.name
						end)
						:totable()
				end

				for _, name in ipairs(names) do
					vim.lsp.enable(name, false)
					for _, client in ipairs(vim.lsp.get_clients({ name = name })) do
						client:stop(info.bang)
					end
				end

				vim.defer_fn(function()
					for _, name in ipairs(names) do
						vim.lsp.enable(name)
					end
				end, 500)
			end,
			{ nargs = "*", bang = true }
		)
	end

	vim.api.nvim_create_user_command(
		"DebugUnitTests",
		function()
			vim.cmd("split")
			vim.cmd("terminal gdb build_test/unit_tests")
		end,
		{}
	)

	vim.api.nvim_create_user_command(
		"CommitMessage",
		function()
			local buf = vim.api.nvim_get_current_buf()
			local buftype = vim.api.nvim_get_option_value(
				"buftype",
				{ buf = buf }
			)
			if buftype == "terminal" then
				local job_id = vim.b.terminal_job_id
				vim.fn.chansend(job_id, ("./commitmessage"))
				vim.fn.chansend(job_id, "\n")
				vim.cmd("startinsert")
			else
				local buf = vim.api.nvim_create_buf(false, true)
				vim.cmd("botright split")
				local win = vim.api.nvim_get_current_win()
				vim.api.nvim_win_set_buf(win, buf)
				vim.fn.termopen("bash")
				local job_id = vim.b.terminal_job_id
				vim.fn.chansend(job_id, ("./commitmessage"))
				vim.fn.chansend(job_id, "\n")
				vim.cmd("startinsert")
			end
		end,
		{}
	)

	------------------------------------ ZEILENMARKIERUNG -----------------------------------------
	-- 1. Eigene Farbe für die markierte Zeile definieren (z. B. ein schöner, dezenter Hintergrund)
	-- Du kannst 'bg' durch jede beliebige Hex-Farbe ersetzen, die zu deinem Theme passt.
	vim.api.nvim_set_hl(0, "DapUiLocalMarker", { bg = "#DB8190", fg = "#ffffff", bold = true })

	-- Variable zum Merken der Markierung (bufferlokal)
	local dap_marker_id = nil

	-- 2. Den permanenten Befehl :DapMark erstellen
	vim.api.nvim_create_user_command("MarkProblem", function()
		if dap_marker_id then
			-- Wenn bereits eine Zeile markiert ist, lösche das Highlight
			pcall(vim.fn.matchdelete, dap_marker_id)
			dap_marker_id = nil
		else
			-- Ermittle die Zeilennummer unter dem Cursor
			local line_num = vim.fn.line(".")
			-- Setze das Highlight exakt auf diese Zeile
			dap_marker_id = vim.fn.matchadd("DapUiLocalMarker", [[\%]] .. line_num .. [[l]])
		end
	end, {})
end

return M
