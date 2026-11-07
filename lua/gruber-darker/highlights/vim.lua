---Standard Vim highlights
---@type GruberDarkerProvider
return function(c, opts)
	return {
		---Any comment
		Comment = { fg = c.brown, italic = opts.italic.comments },
		---Used for the columns set with 'colorcolumn'
		ColorColumn = { bg = c["bg+2"] },
		---Placeholder characters substituted for concealed text (see 'conceallevel')
		Conceal = { fg = c.fg, bg = c.bg },
		---Character under the cursor
		Cursor = { bg = c.yellow },
		---The character under the cursor when |language-mapping| is used (see 'guicursor')
		lCursor = { fg = c.none, bg = c.yellow },
		---Like Cursor, but used when in IME mode |CursorIM|
		CursorIM = { fg = c.none, bg = c.yellow },
		---Screen-column at the cursor, when 'cursorcolumn' is set.
		CursorColumn = { bg = c["bg+2"] },
		---Screen-line at the cursor, when 'cursorline' is set.  Low-priority if foreground (ctermfg OR guifg) is not set.
		CursorLine = { bg = c["bg+1"] },
		---Directory names (and other special names in listings)
		Directory = { link = "GruberDarkerNiagaraBold" },

		---Diff mode: Added line |diff.txt|
		DiffAdd = { fg = c.green, bg = c.none },
		---Diff mode: Changed line |diff.txt|
		DiffChange = { fg = c.yellow, bg = c.none },
		---Diff mode: Deleted line |diff.txt|
		DiffDelete = { fg = c["red+1"], bg = c.none },
		---Diff mode: Changed text within a changed line |diff.txt|
		DiffText = { fg = c.yellow, bg = c["bg+2"], bold = opts.bold },

		---Fugitive highlights; might need separate provider for git related plugins
		diffAdded = { link = "DiffAdd" },
		diffRemoved = { link = "DiffDelete" },
		diffLine = { link = "DiffChange" },

		---Gitsigns highlights
		GitSignsAdd = { link = "DiffAdd" },
		GitSignsChange = { link = "DiffChange" },
		GitSignsDelete = { link = "DiffDelete" },

		---Filler lines (~) after the end of the buffer.  By, this is highlighted like |hl-NonText|.
		EndOfBuffer = { fg = c["bg+4"], bg = c.none },
		---Cursor in a focused terminal
		TermCursor = { bg = c.yellow },
		---TermCursorNC= { }, ---cursor in an unfocused terminal

		---Error messages on the command line
		ErrorMsg = { fg = c.white, bg = c.red },
		---The column separating vertically split windows
		VertSplit = { fg = c["fg+2"], bg = c["bg+1"] },
		---The column separating vertically split windows
		WinSeparator = { fg = c["bg+2"], bold = opts.bold },
		---Line used for closed folds
		Folded = { fg = c.brown, bg = c["bg+2"], italic = opts.italic.folds },
		---'foldcolumn'
		FoldColumn = { fg = c.brown, bg = c.none },
		---column where |signs| are displayed
		SignColumn = { fg = c["bg+2"], bg = c.none },
		---column where |signs| are displayed in sidebar windows
		SignColumnSB = { fg = c["bg+2"], bg = c.none },
		---Substitute = { bg = c.red, fg = c.black }, ---|:substitute| replacement text highlighting
		---Line number for ":number" and ":#" commands, and when 'number' or 'relativenumber' option is set.
		LineNr = { fg = c["bg+4"] },
		---Like LineNr when 'cursorline' or 'relativenumber' is set for the cursor line.
		CursorLineNr = { fg = c.yellow },
		---The character under the cursor or just before it, if it is a paired bracket, and its match. |pi_paren.txt|
		MatchParen = { fg = c.fg, bg = c.wisteria },
		---'showmode' message (e.g., "---INSERT ---")
		ModeMsg = { link = "GruberDarkerFg2" },
		---Area for messages and cmdline
		-- MsgArea = { fg = c.fg_dark },
		---Separator for scrolled messages, `msgsep` flag of 'display'
		-- MsgSeparator = {},
		---|more-prompt|
		MoreMsg = { fg = c["fg+2"] },
		---'@' at the end of the window, characters from 'showbreak' and other characters that do not really exist in the text (e.g., ">" displayed when a double-wide character doesn't fit at the end of the line). See also |hl-EndOfBuffer|.
		NonText = { link = "EndOfBuffer" },
		---Normal text
		Normal = { fg = c.fg, bg = c.bg },
		---Normal text in non-current windows
		NormalNC = { fg = c.fg, bg = c.bg },
		---Normal text in sidebar
		NormalSB = { fg = c.fg, bg = c["bg-1"] },
		---Normal text in floating windows.
		NormalFloat = { fg = c.fg, bg = c["bg+1"] },
		FloatBorder = { fg = c["bg+4"], bg = c.none },

		-- Popup

		---Popup menu: normal item.
		Pmenu = { fg = c.fg, bg = c["bg+1"] },
		---Popup menu: selected item.
		PmenuSel = { fg = c.fg, bg = c["bg+2"] },
		---Popup menu: scrollbar.
		PmenuSbar = { bg = c.bg },
		---Popup menu: Thumb of the scrollbar.
		PmenuThumb = { bg = c["bg+4"] },

		---|hit-enter| prompt and yes/no questions
		Question = { fg = c.niagara },
		---Current |quickfix| item in the quickfix window. Combined with |hl-CursorLine| when the cursor is there.
		QuickFixLine = { bg = c["bg+2"], bold = opts.bold },

		-- Search

		---Last search pattern highlighting (see 'hlsearch').  Also used for similar items that need to stand out.
		Search = { fg = c["niagara-1"], bg = c["fg+1"] },
		---'incsearch' highlighting; also used for the text replaced with ":s///c"
		IncSearch = { fg = c.black, bg = c["fg+2"] },
		CurSearch = { link = "IncSearch" },

		---Unprintable characters: text displayed differently from what it really is.  But not 'listchars' whitespace. |hl-Whitespace|
		SpecialKey = { fg = c["fg+2"] },

		-- Spell

		---Word that is not recognized by the spellchecker. |spell| Combined with the highlighting used otherwise.
		SpellBad = { link = "GruberDarkerRedUnderline" },
		---Word that should start with a capital. |spell| Combined with the highlighting used otherwise.
		SpellCap = { undercurl = opts.undercurl },
		---Word that is recognized by the spellchecker as one that is used in another region. |spell| Combined with the highlighting used otherwise.
		SpellLocal = { undercurl = opts.undercurl },
		---Word that is recognized by the spellchecker as one that is hardly ever used.  |spell| Combined with the highlighting used otherwise.
		SpellRare = { undercurl = opts.undercurl },

		-- Statusline

		---Status line of current window
		StatusLine = { fg = c.white, bg = c["bg+1"] },
		---Status lines of not-current windows Note: if this is equal to "StatusLine" Vim will use "^^^" in the status line of the current window.
		StatusLineNC = { fg = c.quartz, bg = c["bg+1"] },

		-- Tabline

		---Tab pages line, not active tab page label
		TabLine = { bg = c.none },
		---Tab pages line, where there are no labels
		TabLineFill = { fg = c["bg+4"], bg = c["bg+1"] },
		---Tab pages line, active tab page label
		TabLineSel = { fg = c.yellow, bg = c.none, bold = opts.bold },

		---Titles for output from ":set all", ":autocmd" etc.
		Title = { link = "GruberDarkerQuartz" },
		---Visual mode selection
		Visual = { bg = c["bg+2"], reverse = opts.invert.visual },
		---Visual mode selection when vim is "Not Owning the Selection".
		VisualNOS = { link = "GruberDarkerRed" },
		---Warning messages
		WarningMsg = { link = "GruberDarkerRed" },
		---"nbsp", "space", "tab" and "trail" in 'listchars'
		Whitespace = { fg = c["bg+4"], bg = c.none },
		---Current match in 'wildmenu' completion
		WildMenu = { fg = c.black, bg = c.yellow },
		---These groups are not listed as vim groups,
		---but they are defacto standard group names for syntax highlighting.
		---commented out groups should chain up to their "preferred" group by
		--,
		---Uncomment and edit if you want more specific syntax highlighting.

		---(preferred) any constant
		Constant = { link = "GruberDarkerQuartz" },
		---A string constant: "this is a string"
		String = { fg = c.green, italic = opts.italic.strings },
		---A character constant: 'c', '\n'
		Character = { fg = c.green, italic = opts.italic.strings },
		---A number constant: 234, 0xff
		Number = { link = "GruberDarkerWisteria" },
		---A boolean constant: TRUE, false
		Boolean = { link = "GruberDarkerYellowBold" },
		---A floating point constant: 2.3e10
		Float = { link = "GruberDarkerWisteria" },
		---(preferred) any variable name
		Identifier = { link = "GruberDarkerFg1" },
		---Function name (also: methods for classes)
		Function = { link = "GruberDarkerNiagara" },
		---(preferred) any statement
		Statement = { fg = c.yellow },
		---If, then, else, endif, switch, etc.
		Conditional = { link = "GruberDarkerYellowBold" },
		---For, do, while, etc.
		Repeat = { link = "GruberDarkerYellowBold" },
		---Case,, etc.
		Label = { link = "GruberDarkerYellowBold" },
		---"sizeof", "+", "*", etc.
		Operator = { fg = c.fg, italic = opts.italic.operators },
		---Any other keyword
		Keyword = { link = "GruberDarkerYellowBold" },
		---Try, catch, throw
		Exception = { link = "GruberDarkerYellowBold" },
		---(preferred) generic Preprocessor
		PreProc = { link = "GruberDarkerQuartz" },
		---Preprocessor #include
		Include = { link = "GruberDarkerQuartz" },
		---Preprocessor #define
		Define = { link = "GruberDarkerQuartz" },
		---Same as Define
		Macro = { link = "GruberDarkerQuartz" },
		---Preprocessor #if, #else, #endif, etc.
		PreCondit = { link = "GruberDarkerQuartz" },
		---(preferred) int, long, char, etc.
		Type = { link = "GruberDarkerQuartz" },
		---Static, register, volatile, etc.
		StorageClass = { link = "GruberDarkerYellowBold" },
		---Struct, union, enum, etc.
		Structure = { link = "GruberDarkerYellowBold" },
		---A typedef
		Typedef = { link = "GruberDarkerYellowBold" },
		---(preferred) any special symbol
		Special = { link = "GruberDarkerYellow" },
		--- special character in a constant
		SpecialChar = { link = "GruberDarkerYellow" },
		---You can use CTRL-] on this
		Tag = { link = "GruberDarkerYellow" },
		---Character that needs attention
		Delimiter = { link = "GruberDarkerFg0" },
		---Special things inside a comment
		SpecialComment = { link = "GruberDarkerWisteriaBold" },
		---Debugging statements
		Debug = { link = "GruberDarkerFg2" },

		---(preferred) text that stands out, HTML links
		Underlined = { fg = c.wisteria, underline = opts.underline },
		Bold = { bold = opts.bold },
		Italic = { italic = true },
		---("Ignore", below, may be invisible...)
		---Ignore = { }, ---(preferred) left blank, hidden  |hl-Ignore|

		---Error = { fg = c.error }, ---(preferred) any erroneous construct

		---(preferred) anything that needs extra attention; mostly the keywords TODO FIXME and XXX
		Todo = { fg = c.bg, bg = c.yellow },

		-- Markdown

		markdownHeadingDelimiter = { fg = c.niagara, bold = opts.bold },
		markdownCode = { fg = c.green },
		markdownCodeBlock = { fg = c.green },
		---markdownH1 = { fg = c.magenta, bold = true },
		---markdownH2 = { fg = c.blue, bold = true },
		---markdownLinkText = { fg = c.blue, underline = true },
		markdownItalic = { fg = c.wisteria, italic = true },
		markdownBold = { link = "GruberDarkerYellowBold" },
		markdownCodeDelimiter = { fg = c.brown, italic = true },
		markdownError = { fg = c.fg, bg = c["bg+1"] },

		-- Embedded languages: keep <script> bodies and inline CSS plain

		javaScript = { link = "Normal" },
		htmlCssDefinition = { link = "Normal" },
	}
end
