---@alias ItalicType
---|"strings"
---|"comments"
---|"operators"
---|"folds"

---@alias InvertType
---|"signs"
---|"tabline"
---|"visual"

---@class GruberDarkerOpts
---@field bold boolean
---@field invert table<InvertType, boolean>
---@field italic table<ItalicType, boolean>
---@field undercurl boolean
---@field underline boolean
---@field palette table<string, string> overrides for base palette colours, by name
---@field overrides table<string, vim.api.keyset.highlight>|GruberDarkerProvider replaces groups' specs, applied last
---@field semantic_tokens boolean

local M = {}

---@type GruberDarkerOpts
M.DEFAULTS = {
	bold = true,
	invert = {
		signs = false,
		tabline = false,
		visual = false,
	},
	italic = {
		strings = true,
		comments = true,
		operators = false,
		folds = true,
	},
	undercurl = true,
	underline = true,
	palette = {},
	overrides = {},
	semantic_tokens = false,
}

---@type GruberDarkerOpts|nil
local resolved = nil

---Set GruberDarker colorscheme options. Every call re-merges `opts` over the defaults.
---@param opts? GruberDarkerOpts
function M.setup(opts)
	resolved = vim.tbl_deep_extend("force", {}, M.DEFAULTS, opts or {})
end

---Get GruberDarker user preferences
---@return GruberDarkerOpts
---@nodiscard
function M.get()
	return resolved or M.DEFAULTS
end

return M
