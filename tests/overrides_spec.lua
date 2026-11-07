local h = require("helpers")

return {
	["palette override flows into dependents"] = function()
		h.reload({ palette = { niagara = "#123456" } })
		h.eq(vim.api.nvim_get_hl(0, { name = "Function", link = false }).fg, 0x123456, "Function via GruberDarkerNiagara")
	end,

	["overrides table replaces spec"] = function()
		h.reload({ overrides = { LineNr = { fg = "#ffdd33" } } })
		h.eq(h.hl("LineNr"), { fg = 0xffdd33 }, "LineNr")
	end,

	["overrides function receives resolved palette"] = function()
		local got
		h.reload({
			palette = { yellow = "#abcdef" },
			overrides = function(c)
				got = c.yellow
				return { LineNr = { fg = c.yellow } }
			end,
		})
		h.eq(got, "#abcdef", "c.yellow")
		h.eq(h.hl("LineNr").fg, 0xabcdef, "LineNr fg")
	end,

	["override replaces spec and dependents follow"] = function()
		h.reload({ overrides = { GruberDarkerNiagara = { fg = "#010203" } } })
		h.eq(vim.api.nvim_get_hl(0, { name = "Function", link = false }).fg, 0x010203, "Function follows")
	end,

	["invalid palette value errors with key name"] = function()
		local okk, err = pcall(h.reload, { palette = { yellow = "#fff" } })
		h.ok(not okk and tostring(err):find('invalid palette color "yellow"', 1, true), tostring(err))
	end,

	["overrides fn cannot mutate defaults"] = function()
		-- setup() never called: get() must not hand out DEFAULTS itself
		h.reload()
		local config = require("gruber-darker.config")
		require("gruber-darker.highlights").apply(vim.tbl_extend("force", {}, config.get(), {
			overrides = function(_, opts)
				opts.bold = false
				return {}
			end,
		}))
		h.eq(config.DEFAULTS.bold, true, "DEFAULTS.bold after apply with raw opts")
		config.get().bold = false
		h.eq(config.DEFAULTS.bold, true, "DEFAULTS.bold after mutating get() result")
		-- setup() called: opts passed to the function is the resolved copy
		h.reload({
			overrides = function(_, opts)
				opts.bold = false
				return {}
			end,
		})
		h.eq(require("gruber-darker.config").DEFAULTS.bold, true, "DEFAULTS.bold after setup path")
	end,
}
