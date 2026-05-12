local M = {} 

function M.setup()
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
				local job_id  = vim.b.terminal_job_id
				vim.fn.chansend(job_id, ("scripts/commit_messages/" .. 
					"minimal-helperscript-for-commit-messages-" ..
					"with-openai-api/./commit_messages.py"))
				vim.fn.chansend(job_id, "\n")
				vim.cmd("startinsert")
			else 
				local buf = vim.api.nvim_create_buf(false, true)
				vim.cmd("botright split")
				local win = vim.api.nvim_get_current_win()
				vim.api.nvim_win_set_buf(win, buf)
				vim.fn.termopen("bash")
				local job_id = vim.b.terminal_job_id
				vim.fn.chansend(job_id, ("scripts/commit_messages/" .. 
					"minimal-helperscript-for-commit-messages-" ..
					"with-openai-api/./commit_messages.py"))
				vim.fn.chansend(job_id, "\n")
				vim.cmd("startinsert")
			end

		end,
		{}
	)

end 

return M
