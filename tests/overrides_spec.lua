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

	["throwing overrides fn applies nothing"] = function()
		h.reload()
		vim.api.nvim_set_hl(0, "Normal", { fg = "#010101" })
		require("gruber-darker").setup({
			overrides = function()
				error("boom")
			end,
		})
		local ok = pcall(require("gruber-darker.highlights").apply, require("gruber-darker.config").get())
		h.ok(not ok, "apply should fail")
		h.eq(vim.api.nvim_get_hl(0, { name = "Normal" }).fg, 0x010101, "Normal untouched")
	end,

	["invalid palette leaves previous scheme intact"] = function()
		h.reload()
		local before = h.hl("Keyword")
		require("gruber-darker").setup({ palette = { yellow = "#fff" } })
		local okk = pcall(vim.cmd.colorscheme, "gruber-darker")
		h.ok(not okk, "colorscheme should fail")
		h.eq(h.hl("Keyword"), before, "Keyword unchanged")
		h.eq(vim.g.colors_name, "gruber-darker", "colors_name kept")
	end,

	["throwing overrides fn leaves previous scheme intact"] = function()
		h.reload()
		local before = h.hl("Keyword")
		require("gruber-darker").setup({
			overrides = function()
				error("boom")
			end,
		})
		h.ok(not pcall(vim.cmd.colorscheme, "gruber-darker"), "colorscheme should fail")
		h.eq(h.hl("Keyword"), before, "Keyword unchanged")
	end,

	["invalid override names the group"] = function()
		local okk, err = pcall(h.reload, { overrides = { LineNr = { fg = "notacolor" } } })
		h.ok(not okk and tostring(err):find('invalid override "LineNr"', 1, true), tostring(err))
	end,

	["invalid override leaves previous scheme intact"] = function()
		h.reload()
		local before = h.hl("Keyword")
		require("gruber-darker").setup({ overrides = { LineNr = { fg = "notacolor" } } })
		h.ok(not pcall(vim.cmd.colorscheme, "gruber-darker"), "colorscheme should fail")
		h.eq(h.hl("Keyword"), before, "Keyword unchanged")
	end,
}
