---`telescope.nvim` highlights
---@type GruberDarkerProvider
return function(c, opts)
	return {
		TelescopeNormal = { link = "GruberDarkerFg0" },
		TelescopeMatching = { link = "GruberDarkerYellowBold" },
		TelescopeBorder = { link = "FloatBorder" },
		TelescopePromptPrefix = { link = "GruberDarkerNiagara" },
		TelescopeTitle = { fg = c.white },
		TelescopeSelection = { fg = c["fg+2"], bg = c["bg+1"] },
		TelescopeMultiSelection = { link = "CursorLine" },
		TelescopeSelectionCaret = { link = "GruberDarkerYellow" },
	}
end
