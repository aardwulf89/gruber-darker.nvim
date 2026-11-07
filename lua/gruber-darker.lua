local config = require("gruber-darker.config")

local M = {}

---`winhighlight` applied to sidebar-like windows (quickfix, help)
M.SIDEBAR_WINHIGHLIGHT = "Normal:NormalSB,SignColumn:SignColumnSB"

---Delete GruberDarker autocmds when the
---theme changes to something else
---@package
function M.on_colorscheme()
	vim.cmd([[autocmd! GruberDarker]])
	vim.cmd([[augroup! GruberDarker]])
end

local function create_autocmds()
	local gruber_darker_group = vim.api.nvim_create_augroup("GruberDarker", { clear = true })
	vim.api.nvim_create_autocmd("ColorSchemePre", {
		group = gruber_darker_group,
		pattern = "*",
		callback = function()
			require("gruber-darker").on_colorscheme()
		end,
	})

	vim.api.nvim_create_autocmd("FileType", {
		group = gruber_darker_group,
		pattern = "qf,help",
		callback = function()
			vim.cmd.setlocal("winhighlight=" .. M.SIDEBAR_WINHIGHLIGHT)
		end,
	})
end

---Clear current highlights, set Neovim global `colors_name` and apply the theme
function M.load()
	if vim.g.colors_name then
		vim.cmd.hi("clear")
	end

	vim.opt.termguicolors = true
	vim.g.colors_name = "gruber-darker"

	require("gruber-darker.highlights").apply(config.get())

	create_autocmds()
end

---GruberDarker configuration bootstrapper
---@param opts? GruberDarkerOpts
function M.setup(opts)
	config.setup(opts)
end

return M
