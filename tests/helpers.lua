local M = {}

---Reload the plugin from scratch and apply the colorscheme
---@param opts? GruberDarkerOpts passed to `setup()` when given
function M.reload(opts)
	for name in pairs(package.loaded) do
		if name:match("^gruber%-darker") then
			package.loaded[name] = nil
		end
	end
	vim.cmd.hi("clear")
	vim.g.colors_name = nil
	if opts then
		require("gruber-darker").setup(opts)
	end
	vim.cmd.colorscheme("gruber-darker")
end

---Unresolved highlight definition of a group
---@param name string
---@return table
function M.hl(name)
	return vim.api.nvim_get_hl(0, { name = name })
end

---@param actual any
---@param expected any
---@param msg string
function M.eq(actual, expected, msg)
	if not vim.deep_equal(actual, expected) then
		error(string.format("%s: expected %s, got %s", msg, vim.inspect(expected), vim.inspect(actual)), 2)
	end
end

---@param cond any
---@param msg string
function M.ok(cond, msg)
	if not cond then
		error(msg, 2)
	end
end

return M
