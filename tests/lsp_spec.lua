local h = require("helpers")

return {
	["DiagnosticUnnecessary links Comment"] = function()
		h.reload()
		h.eq(h.hl("DiagnosticUnnecessary"), { link = "Comment" }, "DiagnosticUnnecessary")
	end,

	["semantic tokens off: clangd comment only"] = function()
		h.reload()
		for _, ft in ipairs({ "c", "cpp", "objc", "objcpp", "cuda" }) do
			h.eq(h.hl("@lsp.type.comment." .. ft), { link = "Comment" }, ft)
		end
		h.eq(h.hl("@lsp.type.comment"), {}, "generic comment cleared")
		h.eq(h.hl("@lsp.type.variable"), {}, "variable cleared")
	end,

	["semantic tokens on: defaults kept"] = function()
		h.reload({ semantic_tokens = true })
		h.eq(h.hl("@lsp.type.variable"), { link = "@variable" }, "default link kept")
	end,

	["override of an @lsp group survives semantic step"] = function()
		h.reload({ overrides = { ["@lsp.type.variable"] = { fg = "#123456" } } })
		h.eq(h.hl("@lsp.type.variable").fg, 0x123456, "@lsp.type.variable fg")
	end,
}
