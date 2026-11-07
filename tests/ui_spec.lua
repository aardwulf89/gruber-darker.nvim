local h = require("helpers")

---@param name string
---@param expected table
local function check(name, expected)
	h.eq(h.strip_cterm(h.hl(name)), expected, name)
end

return {
	["javaScript and htmlCssDefinition are plain"] = function()
		h.reload()
		check("javaScript", { link = "Normal" })
		check("htmlCssDefinition", { link = "Normal" })
	end,

	["popup thumb visible"] = function()
		h.reload()
		check("PmenuThumb", { bg = 0x52494e })
		check("PmenuSbar", { bg = 0x181818 })
	end,

	["fold column has no bg"] = function()
		h.reload()
		check("FoldColumn", { fg = 0xcc8c3c })
	end,

	["visual-multi groups"] = function()
		h.reload()
		check("VM_Cursor", { fg = 0x000000, bg = 0xffdd33 })
		check("VM_Insert", { fg = 0x000000, bg = 0xffdd33 })
		check("VM_Extend", { link = "Visual" })
		check("VM_Mono", { link = "ErrorMsg" })
	end,

	["DiffText distinct"] = function()
		h.reload()
		check("DiffText", { fg = 0xffdd33, bg = 0x453d41, bold = true })
		check("DiffChange", { fg = 0xffdd33 })
	end,

	["guicursor append is idempotent"] = function()
		h.reload()
		h.reload()
		vim.cmd.colorscheme("gruber-darker")
		local _, n = vim.o.guicursor:gsub("a:Cursor/lCursor", "")
		h.eq(n, 1, vim.o.guicursor)
	end,
}
