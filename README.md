# gruber-darker.nvim

_A modern Neovim port of a deftheme [adaptation][gruber-darker-theme] of an Emacs
[port][gruber-darker] of a BBEdit [colorscheme][gruber-dark]_

> **Note**
> This is a work in progress, but fairly stable

![image](https://user-images.githubusercontent.com/9439488/229402983-b27a2fc4-d938-4ed0-8f7f-7711f73aa985.png)

## Installation

Requires Neovim >= 0.10.

### Native Package Manager (Neovim >= 0.12.0)

```lua
vim.pack.add({ src = "https://github.com/aardwulf89/gruber-darker.nvim" })
```

### Lazy (recommended)

```lua
{ "aardwulf89/gruber-darker.nvim" }
```

### Packer

```lua
use "aardwulf89/gruber-darker.nvim"
```

### Plug

```vim
Plug 'aardwulf89/gruber-darker.nvim'
```

Then, somewhere in your `init.lua`, set the colorscheme

```lua
vim.cmd.colorscheme("gruber-darker")
```

## Configuration

### Defaults

```lua
{
  bold = true,
  invert = {
    signs = false,
    tabline = false,
    visual = false,
  },
  italic = {
    strings = true,
    comments = true,
    operators = false,
    folds = true,
  },
  undercurl = true,
  underline = true,
  palette = {}, -- override base palette colors by name
  overrides = {}, -- replace highlight groups; a table or a function
  semantic_tokens = false, -- true keeps Neovim's default LSP semantic highlights
}
```

### With updated preferences

Change configuration options by calling `setup()`
prior to loading the colorscheme. Your preferences
will be merged with the defaults.

For example, with [Lazy](https://github.com/folke/lazy.nvim.git)...

```lua
{
  "aardwulf89/gruber-darker.nvim",
  opts = {
    bold = false,
    italic = {
      strings = false,
    },
  },
}
```

### Semantic tokens

By default (`semantic_tokens = false`) LSP semantic highlights are hidden so
tree-sitter highlighting wins, except clangd inactive regions
(`@lsp.type.comment.{c,cpp,objc,objcpp,cuda}`), which are dimmed as `Comment`.
Set `semantic_tokens = true` to keep Neovim's default `@lsp` to tree-sitter links.

### Overriding colors

`palette` replaces base colors by name (hex `#rrggbb` strings, or `"NONE"`).
Every highlight group built from a color follows the change.

```lua
require("gruber-darker").setup({
  palette = { niagara = "#5f87af" },
})
```

`overrides` replaces the spec of individual highlight groups. It is applied
last, so it wins over everything else. For example, to change `LineNr`:

```lua
require("gruber-darker").setup({
  overrides = {
    LineNr = { fg = "#ffdd33" },
  },
})
```

It can also be a function that receives the resolved palette and the
resolved options, and returns the table of groups:

```lua
require("gruber-darker").setup({
  overrides = function(c, opts)
    return {
      LineNr = { fg = c.yellow },
    }
  end,
})
```

The overrides function runs before the theme's highlights are applied, so use
`c` and `opts` rather than reading existing groups with `nvim_get_hl`, and treat
`opts` as read-only.

`require("gruber-darker.palette")` returns the base palette as hex strings.

### Upgrading

- `require("gruber-darker.palette")` values are now hex strings; `:to_string()` is gone.
- Removed: `M.colorscheme()`, `config.get_opts()`, `highlights.setup()` and the
  providers' `.highlights` object tables.
- Requires Neovim >= 0.10.

## Development

Run the tests and the highlight snapshot guard:

```sh
nvim --headless --clean -l tests/run.lua
nvim --headless --clean -l tests/snapshot.lua check
```

## Credits

These repositories were great knowledge sources and their
inspiration helped immensely with the development of this plugin.

- [rexim/gruber-darker-theme][gruber-darker-theme]
- [folke/tokyonight.nvim][tokyonight]
- [drsooch/gruber-darker-vim][gruber-darker-vim]

[gruber-darker-theme]: https://github.com/rexim/gruber-darker-theme
[gruber-darker]: https://jblevins.org/projects/emacs-color-themes/gruber-darker-theme.el.html
[gruber-dark]: http://daringfireball.net/projects/bbcolors/schemes/
[tokyonight]: https://github.com/folke/tokyonight.nvim
[gruber-darker-vim]: https://github.com/drsooch/gruber-darker-vim
