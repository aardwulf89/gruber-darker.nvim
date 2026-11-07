---`compile-mode.nvim` highlights
---@type GruberDarkerProvider
return function(c, opts)
	return {
		CompileModeMessageRow = { link = "GruberDarkerYellow" },
		CompileModeMessageCol = { link = "GruberDarkerGreen" },

		CompileModeError = { link = "GruberDarkerRed" },
		CompileModeWarning = { link = "GruberDarkerBrown" },
		CompileModeInfo = { link = "GruberDarkerGreen" },

		CompileModeCommandOutput = { link = "GruberDarkerNiagara" },
		CompileModeDirectoryMessage = { link = "GruberDarkerNiagara" },
		CompileModeOutputFile = { link = "GruberDarkerYellowBold" },
		CompileModeCheckResult = { link = "GruberDarkerWisteriaBold" },
		CompileModeCheckTarget = { link = "GruberDarkerWisteriaBold" },
	}
end
