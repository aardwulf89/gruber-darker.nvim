local M = {}

---@alias GruberDarkerProvider fun(c: table<string, string>, opts: GruberDarkerOpts): table<string, vim.api.keyset.highlight>

---@class GruberDarkerProviderEntry
---@field name string
---@field fn GruberDarkerProvider

---Provider modules under `gruber-darker.highlights`, in application order
local PROVIDERS = { "colorscheme", "vim", "lsp", "treesitter", "cmp", "telescope", "rainbow", "compile-mode" }

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

---Set every highlight group and the terminal colours
---@param opts GruberDarkerOpts
function M.apply(opts)
	local c = M.resolve_palette(opts)
	local groups = M.build(c, opts)
	-- Evaluate user code before touching any group so a failure cannot leave the theme half-applied
	local overrides = opts.overrides
	if type(overrides) == "function" then
		overrides = overrides(c, opts)
	end
	for name, spec in pairs(groups) do
		vim.api.nvim_set_hl(0, name, spec)
	end
	require("gruber-darker.highlights.terminal")(c)
	if not opts.semantic_tokens then
		-- Semantic highlights would otherwise override tree-sitter; see :h lsp-semantic-highlight
		for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
			vim.api.nvim_set_hl(0, group, {})
		end
		-- clangd marks inactive preprocessor regions as comments
		for _, ft in ipairs(CLANGD_FILETYPES) do
			vim.api.nvim_set_hl(0, "@lsp.type.comment." .. ft, { link = "Comment" })
		end
	end
	for name, spec in pairs(overrides or {}) do
		vim.api.nvim_set_hl(0, name, spec)
	end
	vim.opt.guicursor:append("a:Cursor/lCursor")
end

return M
