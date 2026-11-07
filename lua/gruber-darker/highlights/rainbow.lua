---`rainbow-delimiters.nvim` highlights
---@type GruberDarkerProvider
return function(c, opts)
	return {
		RainbowDelimiterRed = { fg = c["red+1"] },
		RainbowDelimiterOrange = { fg = c.brown },
		RainbowDelimiterYellow = { fg = c.yellow },
		RainbowDelimiterGreen = { fg = c.green },
		RainbowDelimiterBlue = { fg = c.niagara },
		RainbowDelimiterViolet = { fg = c.wisteria },
		RainbowDelimiterCyan = { fg = c.quartz },
	}
end
