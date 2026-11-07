---Set Neovim terminal colors
---@param c table<string, string> resolved palette
return function(c)
	-- terminal colors adapted from
	-- https://github.com/drsooch/gruber-darker-vim/blob/master/colors/GruberDarker.vim#L202
	vim.g.terminal_color_0 = c["bg+1"]
	vim.g.terminal_color_8 = c["bg+1"]

	vim.g.terminal_color_1 = c["red+1"]
	vim.g.terminal_color_9 = c["red+1"]

	vim.g.terminal_color_2 = c.green
	vim.g.terminal_color_10 = c.green

	vim.g.terminal_color_3 = c.yellow
	vim.g.terminal_color_11 = c.yellow

	vim.g.terminal_color_4 = c.niagara
	vim.g.terminal_color_12 = c.niagara

	vim.g.terminal_color_5 = c.wisteria
	vim.g.terminal_color_13 = c.wisteria

	vim.g.terminal_color_6 = c.niagara
	vim.g.terminal_color_14 = c.niagara

	vim.g.terminal_color_7 = c.fg
	vim.g.terminal_color_15 = c.fg

	vim.g.terminal_color_background = c["bg+1"]
	vim.g.terminal_color_foreground = c.white
end
