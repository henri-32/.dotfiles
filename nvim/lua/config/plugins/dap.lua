local M = {}

function M.setup()
	local dap = require("dap")
	local dapui = require("dapui")

	dapui.setup()

	dap.adapters.gdb = {
		type = "executable",
		command = "gdb",
		args = {
			"--interpreter=dap",
			"--eval-command",
			"set print pretty on",
			"--eval-command", "set substitute-path . " .. vim.fn.getcwd()
		},
	}

	dap.adapters.codelldb = {
		type = "executable",
		command = "/usr/bin/codelldb",
	}

	local configurations = {
		{
			name = "Launch navigationMonitor",
			type = "gdb",
			request = "launch",
			program = "${workspaceFolder}/navigationMonitor/build-debug/navigationMonitor",
			cwd = "${workspaceFolder}",
		},
		{
			name = "Launch autopilotGateway",
			type = "gdb",
			request = "launch",
			program = "${workspaceFolder}/autopilotGateway/build-debug/autopilotGateway",
			cwd = "${workspaceFolder}",
		},
		{
			name = "Launch heatingController_UnitTests",
			type = "codelldb",
			request = "launch",
			program = "${workspaceFolder}/build_test_debug/unit_tests",
			cwd = "${workspaceFolder}",
		},
		{
			name = "Select executable",
			type = "gdb",
			request = "launch",
			program = function()
				return coroutine.create(function(dap_run_co)
					vim.ui.input({
						prompt = "Executable: ",
						default = vim.fn.getcwd() .. "/",
						completion = "file",
					}, function(path)
						coroutine.resume(
							dap_run_co,
							path and path ~= "" and path or dap.ABORT
						)
					end)
				end)
			end,
			cwd = "${workspaceFolder}",
		},
		{
			name = "Attach to running process",
			type = "gdb",
			request = "attach",
			pid = require("dap.utils").pick_process,
		},
	}

	dap.configurations.c = configurations
	dap.configurations.cpp = configurations

	vim.fn.sign_define("DapBreakpoint", {
		text = "●",
		texthl = "DiagnosticError",
	})
	vim.fn.sign_define("DapStopped", {
		text = "▶",
		texthl = "DiagnosticWarn",
		linehl = "Visual",
	})

	dap.listeners.before.attach.dapui_config = function()
		dapui.open()
	end
	dap.listeners.before.launch.dapui_config = function()
		dapui.open()
	end
	dap.listeners.before.event_terminated.dapui_config = function()
		dapui.close()
	end
	dap.listeners.before.event_exited.dapui_config = function()
		dapui.close()
	end
end

return M
