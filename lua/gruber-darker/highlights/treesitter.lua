---Neovim tree-sitter highlights sourced from
---https://github.com/nvim-treesitter/nvim-treesitter/blob/master/CONTRIBUTING.md#highlights
---@type GruberDarkerProvider
return function(c, opts)
	return {
		-- Misc

		---Line and block comments
		["@comment"] = { link = "Comment" },
		---Comments documenting code
		["@comment.documentation"] = { fg = c.green, italic = opts.italic.comments },
		["@comment.luadoc"] = { link = "@comment.documentation" },
		---Syntax/parser errors
		["@error"] = {},
		---Completely disable the highlight
		["@none"] = { fg = c.none, bg = c.none },
		---Various preprocessor directives & shebangs
		["@preproc"] = { link = "PreProc" },
		---Preprocessor definition directives
		["@define"] = { link = "Define" },
		---Symbolic operators (e.g. `+` / `*`)
		["@operator"] = { link = "Operator" },

		-- Punctuation

		---Delimiters (e.g. `;` / `.` / `,`)
		["@punctuation.delimiter"] = { link = "Delimiter" },
		---Brackets (e.g. `()` / `{}` / `[]`)
		["@punctuation.bracket"] = { link = "GruberDarkerWisteria" },
		---Special symbols (e.g. `{}` in string interpolation)
		["@punctuation.special"] = { link = "GruberDarkerBrown" },

		-- Literals

		---String literals
		["@string"] = { link = "String" },
		---String documenting code (e.g. Python docstrings)
		["@string.documentation"] = { link = "String" },
		---Regular expressions
		["@string.regex"] = { link = "Constant" },
		---Escape sequences
		["@string.escape"] = { link = "Constant" },
		---Other special strings (e.g dates)
		["@string.special"] = { link = "Constant" },

		---Character literals
		["@character"] = { link = "Character" },
		---Special characters (e.g. wildcards)
		["@character.special"] = { link = "Constant" },

		---Boolean literals
		["@boolean"] = { link = "Boolean" },
		---Numeric literals
		["@number"] = { link = "Number" },
		---Floating-point number literals
		["@float"] = { link = "Float" },

		-- Functions

		---Function definitions
		["@function"] = { link = "Function" },
		---Built-in functions
		["@function.builtin"] = { link = "GruberDarkerYellow" },
		---Function calls
		-- ["@function.call"] = {},
		---Preprocessor macros
		["@function.macro"] = { link = "Macro" },

		---Method definitions
		["@method"] = { link = "Function" },
		---Method calls
		-- ["@method.call"] = {},

		---constructor calls and definitions
		["@constructor"] = { link = "Function" },
		---parameters of a function
		["@parameter"] = { link = "Identifier" },

		-- Keywords

		---various keywords
		["@keyword"] = { link = "Keyword" },
		---keywords related to coroutines (e.g. `go` in Go, `async/await` in Python)
		-- ["@keyword.coroutine"] = {},
		---keywords that define a function (e.g. `func` in Go, `def` in Python)
		-- ["@keyword.function"] = {},
		---operators that are English words (e.g. `and` / `or`)
		-- ["@keyword.operator"] = {},
		---keywords like `return` and `yield`
		-- ["@keyword.return"] = {},

		---keywords related to conditionals (e.g. `if` / `else`)
		["@conditional"] = { fg = c.yellow },
		---ternary operator (e.g. `?` / `:`)
		["@conditional.ternary"] = {},

		---keywords related to loops (e.g. `for` / `while`)
		["@repeat"] = { link = "Repeat" },
		---keywords related to debugging
		["@debug"] = { link = "Debug" },
		---GOTO and other labels (e.g. `label:` in C)
		["@label"] = { link = "Label" },
		---keywords for including modules (e.g. `import` / `from` in Python)
		-- ["@include"] = {},
		---keywords related to exceptions (e.g. `throw` / `catch`)
		-- ["@exception"] = {},

		-- Types

		---type or class definitions and annotations
		["@type"] = { link = "Type" },
		---built-in types
		["@type.builtin"] = { link = "GruberDarkerYellow" },
		---type definitions (e.g. `typedef` in C)
		["@type.definition"] = { link = "Typedef" },
		---type qualifiers (e.g. `const`)
		-- ["@type.qualifier"] = {},

		---modifiers that affect storage in memory or life-time
		["@storageclass"] = { link = "StorageClass" },
		---attribute annotations (e.g. Python decorators)
		-- I don't think this is supported anymore...
		-- ["@attribute"] = { link = "GruberDarkerBrown" },
		---object and struct fields
		["@field"] = { link = "GruberDarkerNiagara" },
		---similar to `@field`
		["@property"] = { link = "GruberDarkerDarkNiagara" },

		-- Identifiers

		---various variable names
		["@variable"] = { link = "Identifier" },
		---built-in variable names (e.g. `this`)
		["@variable.builtin"] = { link = "GruberDarkerYellow" },

		---constant identifiers
		["@constant"] = { link = "Constant" },
		---built-in constant values
		["@constant.builtin"] = { link = "GruberDarkerYellow" },
		---constants defined by the preprocessor
		["@constant.macro"] = { link = "Define" },

		---modules or namespaces
		-- ["@namespace"] = {},
		---symbols or atoms
		-- ["@symbol"] = {},

		-- Text (mainly for markup languages)

		---non-structured text
		["@text"] = { link = "Normal" },
		---bold text
		["@text.strong"] = { link = "Bold" },
		---text with emphasis
		["@text.emphasis"] = { link = "Italic" },
		---underlined text
		["@text.underline"] = { link = "Underlined" },
		---strikethrough text
		["@text.strike"] = { strikethrough = true },
		---text that is part of a title
		["@text.title"] = { link = "Title" },
		---literal or verbatim text (e.g., inline code)
		["@text.literal"] = { link = "Constant" },
		---text quotations
		-- ["@text.quote"] = {},
		---URIs (e.g. hyperlinks)
		["@text.uri"] = { fg = c.niagara, underline = opts.underline },
		---math environments (e.g. `$ ... $` in LaTeX)
		-- ["@text.math"] = { link = "Special" },
		---text environments of markup languages
		-- ["@text.environment"] = {},
		---text indicating the type of an environment
		-- ["@text.environment.name"] = {},
		---text references, footnotes, citations, etc.
		["@text.reference"] = { link = "GruberDarkerYellowBold" },

		---todo notes
		["@text.todo"] = { link = "Todo" },
		---info notes
		["@text.note"] = { link = "Comment" },
		---warning notes
		["@text.warning"] = { link = "WarningMsg" },
		---danger/error notes
		["@text.danger"] = { link = "ErrorMsg" },

		---added text (for diff files)
		["@text.diff.add"] = { link = "DiffAdd" },
		---deleted text (for diff files)
		["@text.diff.delete"] = { link = "DiffDelete" },
		["@text.diff.change"] = { link = "DiffChange" },

		-- Tags (used for XML-like tags)

		---XML tag names
		["@tag"] = { link = "Tag" },
		---XML tag attributes
		["@tag.attribute"] = { link = "@field" },
		---XML tag delimiters
		["@tag.delimiter"] = { link = "Delimiter" },
	}
end
