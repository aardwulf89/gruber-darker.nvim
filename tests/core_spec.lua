local h = require("helpers")

return {
	["setup twice, last wins"] = function()
		h.reload()
		require("gruber-darker").setup({ bold = true })
		require("gruber-darker").setup({ bold = false })
		vim.cmd.colorscheme("gruber-darker")
		h.eq(vim.api.nvim_get_hl(0, { name = "Keyword", link = false }).bold, nil, "Keyword bold after bold=false")
	end,

	["setup after load then reapply"] = function()
		h.reload()
		require("gruber-darker").setup({ bold = false })
		vim.cmd.colorscheme("gruber-darker")
		h.eq(vim.api.nvim_get_hl(0, { name = "Keyword", link = false }).bold, nil, "reapply picks new opts")
	end,

	["switch away and back"] = function()
		h.reload()
		vim.cmd.colorscheme("default")
		h.ok(not pcall(vim.api.nvim_get_autocmds, { group = "GruberDarker" }), "augroup gone while away")
		vim.cmd.colorscheme("gruber-darker")
		h.eq(vim.g.colors_name, "gruber-darker", "colors_name")
		h.eq(
			#vim.api.nvim_get_autocmds({ group = "GruberDarker", event = "ColorSchemePre" }),
			1,
			"one ColorSchemePre autocmd"
		)
		h.eq(h.hl("Normal").bg, 0x181818, "Normal bg")
	end,

	["palette values are hex strings"] = function()
		for k, v in pairs(require("gruber-darker.palette")) do
			h.ok(v == "NONE" or v:match("^#%x%x%x%x%x%x$"), "palette." .. k .. " = " .. tostring(v))
		end
	end,

	-- fixes 2, 3
	["no dangling links"] = function()
		-- baseline: groups Neovim defines after `hi clear` with no colorscheme
		vim.cmd.hi("clear")
		local builtin = vim.api.nvim_get_hl(0, {})
		local opts = require("gruber-darker.config").get()
		local hls = require("gruber-darker.highlights")
		local built = hls.build(hls.resolve_palette(opts), opts)
		for name, spec in pairs(built) do
			if spec.link then
				h.ok(built[spec.link] or builtin[spec.link], name .. " -> missing " .. spec.link)
			end
		end
		for pair in require("gruber-darker").SIDEBAR_WINHIGHLIGHT:gmatch("[^,]+") do
			local target = pair:match(":(.+)$")
			h.ok(built[target] or builtin[target], "winhighlight -> missing " .. target)
		end
	end,

	["TelescopeNormal and CmpItemAbbrDeprecated resolve"] = function()
		h.reload()
		h.eq(h.hl("TelescopeNormal"), { link = "GruberDarkerFg0" }, "TelescopeNormal")
		h.eq(h.hl("CmpItemAbbrDeprecated"), { link = "GruberDarkerDarkestNiagara" }, "CmpItemAbbrDeprecated")
	end,

	["duplicate groups are rejected"] = function()
		local hls = require("gruber-darker.highlights")
		local p = function()
			return { Foo = { fg = "#000000" } }
		end
		local okk, err = pcall(hls.build, {}, {}, { { name = "a", fn = p }, { name = "b", fn = p } })
		h.ok(not okk and tostring(err):find("duplicate highlight group Foo in a and b", 1, true), tostring(err))
	end,

	-- fix 13
	["doc comments carry italic"] = function()
		h.reload()
		local s = h.hl("@comment.documentation")
		h.eq(s.fg, 0x73d936, "fg green")
		h.eq(s.italic, true, "italic")
		h.reload({ italic = { comments = false } })
		h.eq(h.hl("@comment.documentation").italic, nil, "italic off")
	end,
}
