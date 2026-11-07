---vim-visual-multi highlights
---@type GruberDarkerProvider
return function(c, _)
	return {
		VM_Cursor = { fg = c.black, bg = c.yellow },
		VM_Insert = { fg = c.black, bg = c.yellow },
		VM_Extend = { link = "Visual" },
		VM_Mono = { link = "ErrorMsg" },
	}
end
