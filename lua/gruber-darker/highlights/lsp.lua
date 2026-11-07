---LSP and diagnostic highlights
---@type GruberDarkerProvider
return function(c, opts)
	return {
		DiagnosticError = { link = "GruberDarkerRedBold" },
		DiagnosticSignError = { link = "GruberDarkerRedSign" },
		DiagnosticUnderlineError = { link = "GruberDarkerRedUnderline" },

		DiagnosticWarn = { link = "GruberDarkerYellowBold" },
		DiagnosticSignWarn = { link = "GruberDarkerYellowSign" },
		DiagnosticUnderlineWarn = { link = "GruberDarkerYellowUnderline" },

		DiagnosticInfo = { link = "GruberDarkerGreenBold" },
		DiagnosticSignInfo = { link = "GruberDarkerGreenSign" },
		DiagnosticUnderlineInfo = { link = "GruberDarkerGreenUnderline" },

		DiagnosticHint = { link = "GruberDarkerWisteria" },
		DiagnosticSignHint = { link = "GruberDarkerWisteriaSign" },
		DiagnosticUnderlineHint = { link = "GruberDarkerWisteriaUnderline" },

		DiagnosticUnnecessary = { link = "Comment" },

		---LspSaga floating windows
		SagaNormal = { link = "NormalFloat" },
		SagaBorder = { link = "FloatBorder" },

		---Used for highlighting "text" references
		-- LspReferenceText = {},
		---Used for highlighting "read" references
		-- LspReferenceRead = {},
		---Used for highlighting "write" references
		-- LspReferenceWrite = {},
		---Used to color the virtual text of the codelens.
		-- LspCodeLens = {},
		---Used to color the separator between two or more code lenses.
		-- LspCodeLensSeparator = {},
		---Used to highlight the active parameter in the signature help.
		-- LspSignatureActiveParameter = {},

		-- ["@lsp.type.class"] = {},
		-- ["@lsp.type.decorator"] = {},
		-- ["@lsp.type.enum"] = {},
		-- ["@lsp.type.enumMember"] = {},
		-- ["@lsp.type.function"] = {},
		-- ["@lsp.type.interface"] = {},
		-- ["@lsp.type.macro"] = {},
		-- ["@lsp.type.method"] = {},
		-- ["@lsp.type.namespace"] = {},
		-- ["@lsp.type.parameter"] = {},
		-- ["@lsp.type.property"] = {},
		-- ["@lsp.type.struct"] = {},
		-- ["@lsp.type.type"] = {},
		-- ["@lsp.type.typeParameter"] = {},
		-- ["@lsp.type.variable"] = {},
	}
end
