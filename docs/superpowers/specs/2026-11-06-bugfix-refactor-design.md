# gruber-darker.nvim: bugfix + core refactor

Date: 2026-11-06
Status: approved by owner 2026-11-06

## Intent

This is a personal fork of `blazkowolf/gruber-darker.nvim`, maintained for the owner's
own use. Nothing will be sent upstream. The goal is to fix every confirmed bug in the
theme, including those behind the open upstream issues (#5, #9, #14, #15, #17, #23, #27).
The core is also rebuilt, because the current class-based design caused five of the bugs.

The colours stay exactly as they are. A lineage study found the port drifts from its
canonical source (rexim/gruber-darker-theme at `2e9f99c`). Examples: fg `#e4e4e4` vs `#e4e4ef`,
green `#73d936` vs `#73c936`, and the Search colours are inverted. The owner has decided
**not** to correct any of that for now.

## Goals

- Fix the 14 bugs listed below.
- Rebuild the core (approach A): plain-string palette, highlight specs rebuilt on every load,
  `setup()` re-mergeable, links by group name.
- Add a user override API (`palette`, `overrides`). This closes #5 and answers #15.
- Add a headless test suite that guards each fix and catches dangling links.

## Non-goals

- No palette or mapping "drift" corrections toward rexim. That includes the fg and green hex
  values, Search, MatchParen, Visual and the italic defaults.
- No changes to `extras/`.
- No new plugin integrations beyond the four `VM_*` groups needed for #9.
- No upstream PRs, and no backward compatibility with the old Lua API.

## Anti-goals (failure even if it "works")

- Any visible colour change that isn't one of the listed fixes. The snapshot diff (see
  Testing) is the guard.
- A link to a group that nothing defines, failing silently. This is the class of bug behind
  #2 and #3.

## Constraints

- Neovim >= 0.10. This is required by the current tree-sitter capture names; the owner runs 0.12.6.
- Code style follows `.stylua.toml`: tabs, 120 columns, double quotes, always-parens.
- Public names that users already reference must keep working: `require("gruber-darker").setup()`,
  `require("gruber-darker").load()`, `:colorscheme gruber-darker`, and every `GruberDarker*`
  highlight group name (users link to e.g. `GruberDarkerNiagara`).

## Approaches considered

- **A. Rebuild the core, tokyonight-style (chosen).** Plain hex palette, providers as pure
  functions returning spec tables, re-evaluated on every load, string links, override API.
  It removes the root cause of bugs 1, 2, 3, 13 and 14. It touches every file in `lua/`,
  which is acceptable for a personal fork.
- **B. Keep the `Color`/`Highlight` classes and patch around them.** Reload modules on load,
  add `__tostring`, apply an overrides table last. A smaller diff, but object-reference links
  still fail silently on a typo.
- **C. Minimal per-bug fixes.** The least work, but options stay frozen at first require.
  That only half-fixes #14.

The owner picked A.

## Design (decided)

### Module layout

| File | Role |
|---|---|
| `colors/gruber-darker.lua` | Just `require("gruber-darker").load()`. The commented-out reload code is deleted. |
| `lua/gruber-darker.lua` | `setup(opts)` and `load()`. The empty `M.colorscheme()` stub is removed. |
| `lua/gruber-darker/config.lua` | `DEFAULTS`, `setup(opts)` and `get()`. |
| `lua/gruber-darker/palette.lua` | Returns a plain table `{ name = "#rrggbb" }` with the same keys and values as today (`fg`, `["fg+1"]`, `["bg-1"]`, `none = "NONE"`, …). |
| `lua/gruber-darker/highlights/*.lua` | Each file returns `function(c, opts) return { [group] = spec, … } end`. |
| `lua/gruber-darker/highlights/init.lua` | Builds the resolved palette, calls the providers in a fixed order and merges their tables. Calls `nvim_set_hl` for each group, then applies user overrides. |

`color.lua` and `highlight.lua` are deleted.

### Config

- `setup(opts)` sets `resolved = vim.tbl_deep_extend("force", {}, DEFAULTS, opts or {})` on
  **every** call. The "only first call counts" singleton is gone.
- Calling `setup()` does not repaint by itself. The user re-runs `:colorscheme gruber-darker`,
  same as tokyonight. Every `load()` reads config and palette fresh, so re-applying always
  reflects the latest `setup()`.
- New keys, added alongside the existing defaults, which are unchanged:
  - `palette = {}`: entries override base palette colours by name. Overridden colours flow
    into every group that uses them.
  - `overrides = {}`: either a table `{ Group = spec }` or `function(c, opts) return { … } end`.
    Here `c` is the resolved palette. Each entry *replaces* the theme's spec for that group
    (it isn't merged), and is applied last.
  - `semantic_tokens = false`: see bug 6.

### Providers and links

- Links are written `{ link = "GroupName" }`, always a string.
- Attribute plus colour combinations are written out in full, never as a link plus extra
  attributes. Neovim ignores other keys when `link` is set, which is bug 13.
- Autocmds: the `GruberDarker` augroup, its `ColorSchemePre` self-cleanup, and the qf/help
  `FileType` autocmd (`winhighlight=Normal:NormalSB,SignColumn:SignColumnSB`) stay as they
  are. The `ColorScheme` semantic-token autocmd is replaced (see fix 6).
- `SignColumnSB` is referenced by that `winhighlight` but never defined. That's the same
  dangling-reference class as bugs 2 and 3. Define it with `SignColumn`'s spec
  (fg `bg+2`, bg `none`) **[call]**. With bg `none` it takes the window's `NormalSB`
  bg, as today, so nothing visible changes. The dangling-reference test also checks the
  targets in the theme's `winhighlight` string.
- Provider order: colorscheme (the `GruberDarker*` groups), vim, lsp, treesitter, terminal,
  cmp, telescope, rainbow, compile-mode, plus a new `visual-multi` provider. If two providers
  define the same group, the test fails rather than letting one silently win.

## The 14 fixes

Each fix keeps the port's existing colours. Where a fix forces a colour choice, it's marked
**[call]**: the author made the call and the owner can veto it.

1. **Options frozen (#14).** Fixed by the config design above.
2. **`TelescopeNormal`** links to a nonexistent key. Make it `{ link = "GruberDarkerFg0" }`,
   which matches the evident intent (fg colour).
3. **`CmpItemAbbrDeprecated`** links to `darkest_niagara`, which doesn't exist. Make it
   `{ link = "GruberDarkerDarkestNiagara" }`, the group the code meant. Also fix the
   cosmetic `CmpitemKindClass` capitalisation.
4. **Pre-0.10 tree-sitter captures.** Rename each one to its current equivalent, keeping the
   spec it had:

   | Old | New |
   |---|---|
   | `@field` | `@variable.member` |
   | `@parameter` | `@variable.parameter` |
   | `@method` | `@function.method` |
   | `@conditional` | `@keyword.conditional` |
   | `@conditional.ternary` | `@keyword.conditional.ternary` → `{ link = "Operator" }` **[call]**: the old empty spec meant "plain"; Operator is plain fg |
   | `@repeat` | `@keyword.repeat` |
   | `@debug` | `@keyword.debug` |
   | `@storageclass` | `@keyword.modifier` |
   | `@preproc` | `@keyword.directive` |
   | `@define` | `@keyword.directive.define` |
   | `@string.regex` | `@string.regexp` |
   | `@float` | `@number.float` |
   | `@text.strong` / `.emphasis` / `.underline` / `.strike` | `@markup.strong` / `.italic` / `.underline` / `.strikethrough` |
   | `@text.title` | `@markup.heading` |
   | `@text.literal` | `@markup.raw` |
   | `@text.uri` | `@markup.link.url` |
   | `@text.reference` | `@markup.link` |
   | `@text.todo` / `.note` / `.warning` / `.danger` | `@comment.todo` / `.note` / `.warning` / `.error` |
   | `@text.diff.add` / `.delete` / `.change` | `@diff.plus` / `@diff.minus` / `@diff.delta` |
   | `@text`, `@error` | dropped (no current equivalent) |

   Commented-out captures (`@include`, `@exception`, `@namespace`, …) stay unset.
   `@none` and `@comment.luadoc` stay.
   **`@property` → `{ link = "@variable.member" }` (niagara) [call].** Today it's
   `#565f73`, which reads as greyed-out. The C query moved struct fields from `@field`
   (niagara) to `@property`. This restores the port's intended colour for C fields,
   which is #17's "some members grayed". Side effect: everything else captured as
   `@property` (Lua table keys, JS/CSS properties) also moves from dim slate to niagara.
5. **`DiagnosticUnnecessary` (#17).** Make it `{ link = "Comment" }`, Neovim's own default.
   Unused code then shows dimmed instead of with a wisteria undercurl.
6. **Semantic tokens wiped.** Replace the `ColorScheme` autocmd with a step inside `load()`
   that runs after the base highlights and before user overrides.
   - When `semantic_tokens = false` (the default), clear every `@lsp*` group, then set
     `@lsp.type.comment.{c,cpp,objc,objcpp,cuda}` to `{ link = "Comment" }`, so clangd's
     inactive `#if` regions are dimmed (#17) **[call]**. Neovim applies per-filetype
     semantic groups (`@lsp.type.<type>.<ft>`).
     - The generic `@lsp.type.comment` stays cleared. Other servers (rust-analyzer for
       doc comments, possibly lua_ls on `---` lines) also send `comment` tokens. A global
       link would turn their doc comments brown and hide `@comment.todo` etc., which is
       a visible change the anti-goal forbids.
   - When `true`, clear nothing and leave Neovim's default `@lsp` → tree-sitter links in place.
7. **JS in HTML (#23).** Set `javaScript` and `htmlCssDefinition` to `{ link = "Normal" }`.
   This stops Vim's `html.vim` from painting the whole `<script>` / `style=""` body as Special.
8. **Invisible popup scrollbar.** `PmenuSbar` keeps bg `bg`. `PmenuThumb` gets bg `bg+4`
   **[call]**: `bg+4` is the palette's lightest neutral that contrasts with the `bg+1` menu.
9. **FoldColumn (#27).** bg becomes `none`, matching `SignColumn`. fg stays `brown`.
10. **vim-visual-multi (#9).** New provider:
    - `VM_Cursor = { fg = c.black, bg = c.yellow }` and `VM_Insert = { fg = c.black, bg = c.yellow }`.
      These match the real cursor and `WildMenu` **[call]**.
    - `VM_Extend = { link = "Visual" }` and `VM_Mono = { link = "ErrorMsg" }`.

    This works because VM only defines these with `hi default link`, unless the user sets
    `g:VM_theme` (verified in VM's source).
11. **`DiffText` indistinguishable.** Make it `{ fg = c.yellow, bg = c["bg+2"], bold = opts.bold }`
    **[call]**. `DiffChange` stays yellow with no bg, and `bg+2` is already used for
    ColorColumn and QuickFixLine.
12. **`guicursor` grows on every load.** Only append `a:Cursor/lCursor` when it isn't already
    present.
13. **Doc-comment italics ignored.** `@comment.documentation = { fg = c.green, italic = opts.italic.comments }`.
    `@comment.luadoc` links to it.
14. **Unpadded hex.** This goes away with the `Color` class. The test asserts every resolved
    palette value (base and user-overridden) matches `^#%x%x%x%x%x%x$` or is `"NONE"`.
    `load()` raises a clear error naming any user palette entry that doesn't match.

## Testing

- `tests/run.lua`, run with `nvim --headless --clean -l tests/run.lua`. It exits non-zero on
  any failure. It has no external test framework, just a tiny assert helper.
- **Regression checks**, one per fix, plus:
  - `setup()` twice, then `:colorscheme` again: the second options win.
  - Switch to `default` and back: no errors, and the theme reapplies.
  - Palette and override API: a colour override changes every dependent group, and the
    function form receives the resolved palette.
  - In a `c` buffer `@lsp.type.comment.c` links to `Comment`, while `@lsp.type.comment` and
    other `@lsp*` groups are empty (fix 6).
  - Every `link` target the theme defines resolves to a non-empty group (theme-defined or
    a Neovim built-in).
  - No old capture name from the table in fix 4 is defined.
- **Snapshot guard.** Before the refactor, a script records the resolved attributes
  (`nvim_get_hl(…, { link = false })`) of every group the current theme defines, saved to
  `tests/snapshot-before.json`. After the refactor, the same dump is diffed against it.
  Every difference must map to one of the 14 fixes. Anything else is a regression.

## Docs

- README: the minimum Neovim version (0.10), the new `palette` / `overrides` /
  `semantic_tokens` options with an example (changing `LineNr`, which answers #15),
  how to run the tests, and a note that `require("gruber-darker.palette")` now returns
  hex strings.

## Owner environment tasks (outside the repo's code)

These were requested alongside the design approval.

1. **Pushes go only to the fork.**
   - `origin` is already `aardwulf89/gruber-darker.nvim`, and no other remote exists.
   - Set `remote.pushDefault=origin`.
   - Run `gh repo set-default aardwulf89/gruber-darker.nvim`. Without this, `gh pr create`
     in a fork targets the parent repo (blazkowolf).
   - Don't add an `upstream` remote. If one is ever added, it must get
     `remote.upstream.pushurl=no_push`.
2. **Neovim config uses the fork.** In `~/.config/nvim/init.lua`, change the `vim.pack.add`
   entry `https://github.com/blazkowolf/gruber-darker.nvim` →
   `https://github.com/aardwulf89/gruber-darker.nvim`.
   - On the next start, `vim.pack.add` sees the source mismatch, deletes the old clone and
     reinstalls from the fork. `nvim-pack-lock.json` updates itself.
   - `~/.config/nvim` is not under git, so back up `init.lua` and the lockfile before editing.
   - Do this **after** the refactor is merged and pushed to the fork's `main`, so the
     reinstall picks up the new code. Then verify with a headless start: the plugin dir's
     remote is the fork and the HEAD matches.
3. **JavaScript Tree-sitter parser.** Add `'javascript'` to `ts_langs` in `init.lua`. That
   list feeds both `require('nvim-treesitter').install()` and the `FileType` autocmd that
   starts highlighting. Then install it: run `require('nvim-treesitter').install({ 'javascript' }):wait()`
   headless. Verify that `javascript.so` exists and that a `<script>` body in an HTML buffer
   resolves to `javascript` captures (#23 on the owner's machine).

## Left to the builder

- Internal function names, how the provider files split up, and the assert helper's shape.
- The exact snapshot script and diff format. JSON plus a small Lua diff is fine.
- Commit granularity.
