local h = require("helpers")

-- new name -> exact unresolved spec carried over from the old capture (spec fix 4)
local RENAMED = {
	["@variable.member"] = { link = "GruberDarkerNiagara" },
	["@variable.parameter"] = { link = "Identifier" },
	["@function.method"] = { link = "Function" },
	["@keyword.conditional"] = { fg = 0xffdd33 },
	["@keyword.conditional.ternary"] = { link = "Operator" },
	["@keyword.repeat"] = { link = "Repeat" },
	["@keyword.debug"] = { link = "Debug" },
	["@keyword.modifier"] = { link = "StorageClass" },
	["@keyword.directive"] = { link = "PreProc" },
	["@keyword.directive.define"] = { link = "Define" },
	["@string.regexp"] = { link = "Constant" },
	["@number.float"] = { link = "Float" },
	["@markup.strong"] = { link = "Bold" },
	["@markup.italic"] = { link = "Italic" },
	["@markup.underline"] = { link = "Underlined" },
	["@markup.strikethrough"] = { strikethrough = true },
	["@markup.heading"] = { link = "Title" },
	["@markup.raw"] = { link = "Constant" },
	["@markup.link.url"] = { fg = 0x96a6c8, underline = true },
	["@markup.link"] = { link = "GruberDarkerYellowBold" },
	["@comment.todo"] = { link = "Todo" },
	["@comment.note"] = { link = "Comment" },
	["@comment.warning"] = { link = "WarningMsg" },
	["@comment.error"] = { link = "ErrorMsg" },
	["@diff.plus"] = { link = "DiffAdd" },
	["@diff.minus"] = { link = "DiffDelete" },
	["@diff.delta"] = { link = "DiffChange" },
	["@property"] = { link = "@variable.member" },
}

local OLD = {
	"@field",
	"@parameter",
	"@method",
	"@conditional",
	"@conditional.ternary",
	"@repeat",
	"@debug",
	"@storageclass",
	"@preproc",
	"@define",
	"@string.regex",
	"@float",
	"@text",
	"@error",
	"@text.strong",
	"@text.emphasis",
	"@text.underline",
	"@text.strike",
	"@text.title",
	"@text.literal",
	"@text.uri",
	"@text.reference",
	"@text.todo",
	"@text.note",
	"@text.warning",
	"@text.danger",
	"@text.diff.add",
	"@text.diff.delete",
	"@text.diff.change",
}

return {
	["renamed captures keep their spec"] = function()
		h.reload()
		for name, spec in pairs(RENAMED) do
			h.eq(h.strip_cterm(h.hl(name)), spec, name)
		end
	end,

	["old capture names are not defined"] = function()
		h.reload()
		for _, name in ipairs(OLD) do
			-- hlexists() is 1 for any @-prefixed name in Neovim 0.12, so check the highlight table instead
			h.eq(vim.api.nvim_get_hl(0, {})[name], nil, name)
		end
	end,
}
