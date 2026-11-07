---GruberDarker-specific highlights, the building blocks other providers link to
---@type GruberDarkerProvider
return function(c, opts)
	-- Highlights inspired by
	-- https://github.com/ellisonleao/gruvbox.nvim/blob/main/lua/gruvbox/groups.lua#L43
	return {
		-- Colors

		GruberDarkerFg0 = { fg = c.fg },
		GruberDarkerFg1 = { fg = c["fg+1"] },
		GruberDarkerFg2 = { fg = c["fg+2"] },

		GruberDarkerBg_1 = { fg = c["bg-1"] },
		GruberDarkerBg0 = { fg = c.bg },
		GruberDarkerBg1 = { fg = c["bg+1"] },
		GruberDarkerBg2 = { fg = c["bg+2"] },
		GruberDarkerBg3 = { fg = c["bg+3"] },
		GruberDarkerBg4 = { fg = c["bg+4"] },

		GruberDarkerDarkRed = { fg = c["red-1"] },
		GruberDarkerDarkRedBold = { fg = c["red-1"], bold = opts.bold },
		GruberDarkerRed = { fg = c.red },
		GruberDarkerRedBold = { fg = c.red, bold = opts.bold },
		GruberDarkerLightRed = { fg = c["red+1"] },
		GruberDarkerLightRedBold = { fg = c["red+1"], bold = opts.bold },

		GruberDarkerGreen = { fg = c.green },
		GruberDarkerGreenBold = { fg = c.green, bold = opts.bold },

		GruberDarkerYellow = { fg = c.yellow },
		GruberDarkerYellowBold = { fg = c.yellow, bold = opts.bold },

		GruberDarkerBrown = { fg = c.brown },
		GruberDarkerBrownBold = { fg = c.brown, bold = opts.bold },

		GruberDarkerQuartz = { fg = c.quartz },
		GruberDarkerQuartzBold = { fg = c.quartz, bold = opts.bold },

		GruberDarkerDarkestNiagara = { fg = c["niagara-2"] },
		GruberDarkerDarkestNiagaraBold = { fg = c["niagara-2"], bold = opts.bold },
		GruberDarkerDarkNiagara = { fg = c["niagara-1"] },
		GruberDarkerDarkNiagaraBold = { fg = c["niagara-1"], bold = opts.bold },
		GruberDarkerNiagara = { fg = c.niagara },
		GruberDarkerNiagaraBold = { fg = c.niagara, bold = opts.bold },

		GruberDarkerWisteria = { fg = c.wisteria },
		GruberDarkerWisteriaBold = { fg = c.wisteria, bold = opts.bold },

		-- Signs

		GruberDarkerRedSign = { fg = c.red, reverse = opts.invert.signs },
		GruberDarkerYellowSign = { fg = c.yellow, reverse = opts.invert.signs },
		GruberDarkerGreenSign = { fg = c.green, reverse = opts.invert.signs },
		GruberDarkerQuartzSign = { fg = c.quartz, reverse = opts.invert.signs },
		GruberDarkerNiagaraSign = { fg = c.niagara, reverse = opts.invert.signs },
		GruberDarkerWisteriaSign = { fg = c.wisteria, reverse = opts.invert.signs },

		-- Underlines

		GruberDarkerRedUnderline = { sp = c.red, undercurl = opts.undercurl },
		GruberDarkerYellowUnderline = { sp = c.yellow, undercurl = opts.undercurl },
		GruberDarkerGreenUnderline = { sp = c.green, undercurl = opts.undercurl },
		GruberDarkerQuartzUnderline = { sp = c.quartz, undercurl = opts.undercurl },
		GruberDarkerNiagaraUnderline = { sp = c.niagara, undercurl = opts.undercurl },
		GruberDarkerWisteriaUnderline = { sp = c.wisteria, undercurl = opts.undercurl },
	}
end
