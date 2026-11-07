local M = {}

---@alias GruberDarkerProvider fun(c: table<string, string>, opts: GruberDarkerOpts): table<string, vim.api.keyset.highlight>

---@class GruberDarkerProviderEntry
---@field name string
---@field fn GruberDarkerProvider

---Provider modules under `gruber-darker.highlights`, in application order
local PROVIDERS = {
	"colorscheme",
	"vim",
	"lsp",
	"treesitter",
	"cmp",
	"telescope",
	"rainbow",
	"compile-mode",
	"visual-multi",
}

---@return GruberDarkerProviderEntry[]
local function default_providers()
	local list = {}
	for _, name in ipairs(PROVIDERS) do
		table.insert(list, { name = name, fn = require("gruber-darker.highlights." .. name) })
	end
	return list
end

---Resolve the palette used to build highlights: the base palette merged with `opts.palette`
---@param opts GruberDarkerOpts
---@return table<string, string>
function M.resolve_palette(opts)
	local c = vim.deepcopy(require("gruber-darker.palette"))
	for key, value in pairs(opts.palette or {}) do
		if type(value) ~= "string" or (value ~= "NONE" and not value:match("^#%x%x%x%x%x%x$")) then
			error(('gruber-darker: invalid palette color "%s": %s'):format(key, vim.inspect(value)))
		end
		c[key] = value
	end
	return c
end

---Merge every provider's groups into one table, rejecting duplicate group names
---@param c table<string, string> resolved palette
---@param opts GruberDarkerOpts
---@param providers? GruberDarkerProviderEntry[] defaults to the built-in providers
---@return table<string, vim.api.keyset.highlight>
function M.build(c, opts, providers)
	providers = providers or default_providers()
	local groups = {}
	-- lower-cased group name -> provider name; Neovim group names are case-insensitive
	local owners = {}
	for _, provider in ipairs(providers) do
		for name, spec in pairs(provider.fn(c, opts)) do
			local key = name:lower()
			if owners[key] then
				error(
					string.format("gruber-darker: duplicate highlight group %s in %s and %s", name, owners[key], provider.name)
				)
			end
			owners[key] = provider.name
			groups[name] = spec
		end
	end
	return groups
end

---Filetypes whose language server reports inactive preprocessor regions as `comment` semantic tokens
local CLANGD_FILETYPES = { "c", "cpp", "objc", "objcpp", "cuda" }

---@class GruberDarkerPlan
---@field opts GruberDarkerOpts
---@field c table<string, string>
---@field groups table<string, vim.api.keyset.highlight>
---@field overrides table<string, vim.api.keyset.highlight>

---Set one override group, naming it in any error
---@param ns integer
---@param name string
---@param spec vim.api.keyset.highlight
local function set_override(ns, name, spec)
	local ok, err = pcall(vim.api.nvim_set_hl, ns, name, spec)
	if not ok then
		error(('gruber-darker: invalid override "%s": %s'):format(name, tostring(err)), 0)
	end
end

---Resolve the palette, build every group and evaluate the overrides without touching any highlight
---@param opts GruberDarkerOpts
---@return GruberDarkerPlan
function M.prepare(opts)
	local c = M.resolve_palette(opts)
	local groups = M.build(c, opts)
	local overrides = opts.overrides
	if type(overrides) == "function" then
		overrides = overrides(c, opts)
	end
	overrides = overrides or {}
	local scratch = vim.api.nvim_create_namespace("gruber-darker-validate")
	for name, spec in pairs(overrides) do
		set_override(scratch, name, spec)
		vim.api.nvim_set_hl(scratch, name, {})
	end
	return { opts = opts, c = c, groups = groups, overrides = overrides }
end

---Set every highlight group and the terminal colours from a prepared plan
---@param plan GruberDarkerPlan
function M.commit(plan)
	for name, spec in pairs(plan.groups) do
		vim.api.nvim_set_hl(0, name, spec)
	end
	require("gruber-darker.highlights.terminal")(plan.c)
	if not plan.opts.semantic_tokens then
		-- Semantic highlights would otherwise override tree-sitter; see :h lsp-semantic-highlight
		for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
			vim.api.nvim_set_hl(0, group, {})
		end
		-- clangd marks inactive preprocessor regions as comments
		for _, ft in ipairs(CLANGD_FILETYPES) do
			vim.api.nvim_set_hl(0, "@lsp.type.comment." .. ft, { link = "Comment" })
		end
	end
	for name, spec in pairs(plan.overrides) do
		set_override(0, name, spec)
	end
	if not vim.o.guicursor:find("a:Cursor/lCursor", 1, true) then
		vim.opt.guicursor:append("a:Cursor/lCursor")
	end
end

---Set every highlight group and the terminal colours
---@param opts GruberDarkerOpts
function M.apply(opts)
	M.commit(M.prepare(opts))
end

return M
