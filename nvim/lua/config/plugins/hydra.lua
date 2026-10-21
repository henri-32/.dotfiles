local M = {}

function M.setup()
	local Hydra = require("hydra")

	vim.api.nvim_set_hl(0, "HydraHint", { link = "NormalFloat" })
	vim.api.nvim_set_hl(0, "HydraBorder", { link = "FloatBorder" })


	-- ------------------------------------------------------------------
	-- Bookmark Hydra
	-- ------------------------------------------------------------------

	Hydra({
		name = "bookmarks",
		mode = "n",
		body = "<leader>b",
		config = {
			invoke_on_body = true,
			hint = {
				position = "bottom",
				float_opts = {
					border = "rounded",
				},
			},
		},

		hint = [[
  ^ ^  Bookmarks
  ^
  _m_: Mark           _d_: Add Description
  _n_: Go to Next     _p_: Go to Previous
  _l_: Bookmark List  _t_: Bookmark Tree
  _c_: Bookmark Commands
  ^
]],

		heads = {
			{ "m",     "<cmd>BookmarksMark<cr>",     { exit = true, silent = true } },
			{ "d",     "<cmd>BookmarksDesc<cr>",     { exit = true, silent = true } },
			{ "n",     "<cmd>BookmarksGotoNext<cr>", { exit = true, silent = true } },
			{ "p",     "<cmd>BookmarksGotoPrev<cr>", { exit = true, silent = true } },
			{ "l",     "<cmd>BookmarksLists<cr>",    { exit = true, silent = true } },
			{ "t",     "<cmd>BookmarksTree<cr>",     { exit = true, silent = true } },
			{ "c",     "<cmd>BookmarksCommands<cr>", { exit = true, silent = true } },
			{ "<Esc>", nil,                          { exit = true, nowait = true } },
		},
	})

	-- ------------------------------------------------------------------
	-- Window Helper
	-- ------------------------------------------------------------------

	local function has_win(direction)
		return vim.fn.winnr(direction) ~= vim.fn.winnr()
	end

	local function smart_resize_width(amount)
		if has_win("l") then
			vim.cmd("vertical resize " .. (amount > 0 and "+" or "-") .. math.abs(amount))
		else
			vim.cmd("vertical resize " .. (amount > 0 and "-" or "+") .. math.abs(amount))
		end
	end

	local function smart_resize_height(amount)
		if has_win("j") then
			-- Wenn unten ein Fenster ist, vergrößert '+' das obere (aktuelle) Fenster
			vim.cmd("resize " .. (amount > 0 and "+" or "-") .. math.abs(amount))
		else
			-- Wenn wir ganz unten sind, vergrößert '-' das untere (aktuelle) Fenster nach oben
			vim.cmd("resize " .. (amount > 0 and "-" or "+") .. math.abs(amount))
		end
	end

	-- ------------------------------------------------------------------
	-- Window Resize Hydra
	-- ------------------------------------------------------------------

	Hydra({
		name = "Window Management",
		mode = "n",
		body = "<leader>-",
		config = {
			invoke_on_body = true,
			hint = {
				position = "bottom",
				float_opts = {
					border = "rounded",
				},
			},
		},
		hint = [[
  ^ ^    Fenster anpassen
  ^
  _h_: Breite verkleinern   _k_: Höhe verkleinern
  _l_: Breite vergrößern   _j_: Höhe vergrößern
  _=_: Layout ausgleichen
  ^
  ^                              _<Esc>_: Beenden
]],
		heads = {
			-- Breite: l vergrößert immer (+2), h verkleinert immer (-2)
			{ "l",     function() smart_resize_width(1) end,   { silent = true } },
			{ "h",     function() smart_resize_width(-1) end,  { silent = true } },

			-- Höhe: k vergrößert immer (+1), j verkleinert immer (-2)
			{ "j",     function() smart_resize_height(1) end,  { silent = true } },
			{ "k",     function() smart_resize_height(-1) end, { silent = true } },

			-- Zusatzfunktionen (Die Splits 's' und 'v' wurden in den Hint aufgenommen)
			{ "=",     "<C-w>=",                               { silent = true } },

			{ "<Esc>", nil,                                    { exit = true, nowait = true } },
		},
	})

    local work = function() vim.wait(100) end

	Hydra({
		name = "DAP Management",
		mode = "n",
		body = "<leader>d",
		config = {
			invoke_on_body = true,
			on_key = work,
			hint = {
				position = "bottom",
				float_opts = {
					border = "rounded",
				},
			},
		},
		hint = [[
		^^    DAP
		^
		_t_: dapui toggle            _c_: continue
		_o_: step out                _i_: step into
		_n_: step over               _bb_: toggle breakpoint
		_u_: frame up 				 _d_: frame down
		_q_: terminate               _e_: eval
		_bl_: logpoint               _bc_: conditional breakpoint
		_bh_: hit breakpoint         
		
		]],
		heads = {
			{ "t",  require("dapui").toggle,          { silent = true } },
			{ "c",  require("dap").continue,          { silent = true, exit_before = true} },
			{ "o",  require("dap").step_out,          { silent = true } },
			{ "i",  require("dap").step_into,         { silent = true } },
			{ "n",  require("dap").step_over,         { silent = true } },
			{ "bb", require("dap").toggle_breakpoint, { silent = true } },
			{ "u",  require("dap").up,                { silent = true } },
			{ "d",  require("dap").down,              { silent = true } },
			{ "q",  require("dap").terminate,         { silent = true, exit = true } },
			{ "e",  require("dapui").eval,            { silent = true } },
			{ "bl", function()
				vim.ui.input({ prompt = "Log: " }, function(log)
					require("dap").set_breakpoint(
						nil,
						nil,
						log
					)
				end)
			end,
				{ silent = true, exit_before = true } },

			{ "bc", function()
				vim.ui.input({ prompt = "Condition: " }, function(condition)
					require("dap").set_breakpoint(
						condition,
						nil,
						nil
					)
				end)
			end,
				{ silent = true, exit_before = true } },
			{ "bh", function()
				vim.ui.input({ prompt = "On hit: " }, function(hit)
					require("dap").set_breakpoint(
						nil,
						hit,
						nil
					)
				end)
			end,
				{ silent = true, exit_before = true } }

		}
	})
end

return M
