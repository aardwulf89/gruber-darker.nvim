# gruber-darker.nvim Bugfix + Core Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the 14 confirmed theme bugs and rebuild the core so options, palette and overrides are re-evaluated on every load, without any other visible colour change.

**Architecture:** The palette becomes plain hex strings. Each highlight provider becomes a pure function `(c, opts) -> { [group] = spec }`, and links are written as group-name strings. `highlights/init.lua` merges the providers, rejects duplicate groups, applies them, runs the semantic-token step, then applies user overrides. A text snapshot of every highlight group, taken before the refactor, guards against unintended colour changes.

**Tech Stack:** Lua, Neovim >= 0.10 (owner runs 0.12.6), headless `nvim -l` tests with no framework.

**Spec:** `docs/superpowers/specs/2026-11-06-bugfix-refactor-design.md`

## Global Constraints

- Neovim >= 0.10.
- Style per `.stylua.toml`: tabs, 120 columns, double quotes, call parentheses always. stylua isn't installed, so format by hand.
- These must keep working: `require("gruber-darker").setup()`, `require("gruber-darker").load()`, `:colorscheme gruber-darker`, and every existing `GruberDarker*` group name.
- No colour changes beyond the 14 fixes. That means no palette or drift corrections (fg stays `#e4e4e4`, green stays `#73d936`) and no italic default changes.
- Don't touch `extras/`.
- All tests run with `nvim --headless --clean -l tests/run.lua [filter]` and exit non-zero on failure.
- The snapshot guard runs with `nvim --headless --clean -l tests/snapshot.lua check` and must pass at the end of every task from Task 2 on.
- Commits end with the trailer `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

## Review Focus

1. **User overrides a palette colour with a non-hex value** (`"red"`, `"#fff"`, `nil` via a typo'd key). Expected: `:colorscheme` raises one clear error naming the key, and doesn't half-apply. Test: Task 3, `invalid palette value errors with key name`.
2. **`setup()` is called after the theme is already active, then `:colorscheme` is re-run** (lazy.nvim `opts` ordering, #14). Expected: the new options win. Test: Task 2, `setup after load then reapply`.
3. **Switching to another colorscheme and back.** Expected: no errors, no leftover `GruberDarker` autocmds while away, and the theme reapplies fully. Test: Task 2, `switch away and back`.
4. **An `overrides` entry targets a group the theme also links to.** Expected: the override replaces the spec, and groups linking to it follow the override. Test: Task 3, `override replaces spec and dependents follow`.
5. **Loading the theme many times in one session** (reload plugins, `:colorscheme` spam). Expected: no `guicursor` growth and no duplicate autocmds. Test: Task 5, `guicursor append is idempotent`, and Task 2, `switch away and back` (asserts one `ColorSchemePre` autocmd in the group).

---

## File Structure

| Path | Responsibility |
|---|---|
| `colors/gruber-darker.lua` | One line: `require("gruber-darker").load()` |
| `lua/gruber-darker.lua` | Public `setup`, `load`, autocmds, `SIDEBAR_WINHIGHLIGHT` constant |
| `lua/gruber-darker/config.lua` | `DEFAULTS`, `setup`, `get` |
| `lua/gruber-darker/palette.lua` | Base palette: `table<string, string>` hex |
| `lua/gruber-darker/highlights/init.lua` | `resolve_palette`, `build`, `apply` |
| `lua/gruber-darker/highlights/{colorscheme,vim,lsp,treesitter,cmp,telescope,rainbow,compile-mode,visual-multi}.lua` | Providers: `fun(c, opts): table<string, vim.api.keyset.highlight>` |
| `lua/gruber-darker/highlights/terminal.lua` | `fun(c)`: sets `vim.g.terminal_color_*` and returns nothing |
| `tests/run.lua` | Runner: loads `tests/*_spec.lua`, optional filename filter |
| `tests/helpers.lua` | `reload()`, `hl(name)`, assert helpers |
| `tests/snapshot.lua` | `dump <file>` / `check` |
| `tests/snapshot-before.txt` | Baseline captured from the pre-refactor code |
| `tests/snapshot_expected.lua` | Group names allowed to differ from the baseline |
| `tests/{core,overrides,treesitter,lsp,ui}_spec.lua` | Tests per area |
| Deleted: `lua/gruber-darker/color.lua`, `lua/gruber-darker/highlight.lua` | |

---

### Task 1: Snapshot tooling and pre-refactor baseline

**Files:**
- Create: `tests/snapshot.lua`, `tests/snapshot_expected.lua`, `tests/snapshot-before.txt`

**Interfaces:**
- Produces:
  - `nvim --headless --clean -l tests/snapshot.lua dump <path>` writes the current snapshot.
  - `... check` writes the current snapshot to a temp file and diffs it against `tests/snapshot-before.txt`.
  - `tests/snapshot_expected.lua` returns `table<string, true>` of group names allowed to differ, and later tasks add entries to it.

- [ ] **Step 1: Implement `tests/snapshot.lua`**
  - Find the repo root from the script path (`debug.getinfo(1, "S").source`). Prepend it to `runtimepath`, then `vim.cmd.colorscheme("gruber-darker")`.
  - Collect every key of `vim.api.nvim_get_hl(0, {})`. For each name, take the **unresolved** spec `vim.api.nvim_get_hl(0, { name = name })`, so links stay as links and dependents don't show as changed.
  - Write one line per group: `name<TAB>serialised spec`. Lines are sorted by name. Inside each spec, keys are sorted and nested `cterm` tables are serialised the same way. Use `vim.inspect` with `{ newline = "", indent = "" }` on a key-sorted copy.
  - `check` collects three sets: **changed** (both sides have the name, with different specs), **added** and **removed**.
  - It fails (`os.exit(1)`) and prints `UNEXPECTED <kind> <name>: <before> -> <after>` for any name not in `snapshot_expected.lua`.
  - It also fails with `STALE <name>` for any expected name that didn't differ.
  - Otherwise it prints `snapshot OK (<n> expected differences)` and exits 0.

- [ ] **Step 2: Create `tests/snapshot_expected.lua` returning `{}`**

- [ ] **Step 3: Capture the baseline from the untouched code**

Run: `nvim --headless --clean -l tests/snapshot.lua dump tests/snapshot-before.txt && wc -l tests/snapshot-before.txt`
Expected: several hundred lines. `grep -c '^GruberDarkerNiagara' tests/snapshot-before.txt` gives 1.

- [ ] **Step 4: Verify the guard is clean on unchanged code**

Run: `nvim --headless --clean -l tests/snapshot.lua check`
Expected: `snapshot OK (0 expected differences)`

- [ ] **Step 5: Commit** with `test: add highlight snapshot guard and pre-refactor baseline`

---

### Task 2: Core rebuild: palette, config, providers, apply (fixes 1, 2, 3, 13, 14)

**Files:**
- Create: `tests/run.lua`, `tests/helpers.lua`, `tests/core_spec.lua`
- Modify:
  - `lua/gruber-darker.lua`, `lua/gruber-darker/config.lua`, `lua/gruber-darker/palette.lua`, `colors/gruber-darker.lua`
  - every file in `lua/gruber-darker/highlights/`
  - `tests/snapshot_expected.lua`
- Delete: `lua/gruber-darker/color.lua`, `lua/gruber-darker/highlight.lua`

**Interfaces:**
- Produces:
  - `palette.lua` returns `table<string, string>`. It has the same keys and values as today, written as `"#rrggbb"`, and `none = "NONE"`.
  - `config.DEFAULTS`: today's defaults plus `palette = {}`, `overrides = {}` and `semantic_tokens = false`. Task 3 and Task 4 consume the new keys.
  - `config.setup(opts?)` re-merges `vim.tbl_deep_extend("force", {}, DEFAULTS, opts or {})` on every call.
  - `config.get() -> GruberDarkerOpts` returns the resolved options, or `DEFAULTS` if `setup()` was never called.
  - Provider modules return `fun(c: table<string,string>, opts: GruberDarkerOpts): table<string, vim.api.keyset.highlight>`.
  - `highlights.resolve_palette(opts) -> table<string,string>`. In this task it returns a copy of the base palette, and Task 3 extends it.
  - `highlights.build(c, opts, providers?) -> table<string, spec>`.
    - `providers` is an optional list of `{ name = string, fn = provider }`. It defaults to the module's list, in the spec's order (colorscheme, vim, lsp, treesitter, cmp, telescope, rainbow, compile-mode). The parameter exists so tests can inject providers.
    - On a duplicate it calls `error("gruber-darker: duplicate highlight group <G> in <providerA> and <providerB>")`.
  - `highlights.apply(opts)` resolves the palette, builds, runs `nvim_set_hl` for each group, calls `terminal(c)` and does the idempotent `guicursor` step (fix 12 lands in Task 5).
  - `gruber-darker.SIDEBAR_WINHIGHLIGHT = "Normal:NormalSB,SignColumn:SignColumnSB"`
  - `tests/helpers.lua`:
    - `reload(opts?)` clears `package.loaded` entries matching `^gruber%-darker`, runs `hi clear`, resets `vim.g.colors_name`, and calls `setup(opts)` if `opts` is given. Then it runs `vim.cmd.colorscheme("gruber-darker")`.
    - `hl(name) -> table` returns the unresolved `nvim_get_hl`.
    - `eq(actual, expected, msg)` uses `vim.deep_equal`, and on failure the message includes both sides via `vim.inspect`.
    - `ok(cond, msg)`
  - `tests/run.lua`:
    - Prepends the repo root to `runtimepath`.
    - Loads each `tests/*_spec.lua` whose filename contains `arg[1]` (all of them when `arg[1]` is absent). Each one returns `table<string, fun()>`.
    - Runs every test in `pcall` and prints `PASS name` or `FAIL name: err`.
    - Prints a summary and exits 1 if any test failed.

- [ ] **Step 1: Write `tests/run.lua`, `tests/helpers.lua` and `tests/core_spec.lua` with these tests:**

```lua
-- each a key in the returned table; h = require("helpers") (runner adds tests/ to package.path)
["setup twice, last wins"] = function()
  h.reload(); require("gruber-darker").setup({ bold = true }); require("gruber-darker").setup({ bold = false })
  vim.cmd.colorscheme("gruber-darker")
  h.eq(vim.api.nvim_get_hl(0, { name = "Keyword", link = false }).bold, nil, "Keyword bold after bold=false")
end,
["setup after load then reapply"] = function()
  h.reload(); require("gruber-darker").setup({ bold = false }); vim.cmd.colorscheme("gruber-darker")
  h.eq(vim.api.nvim_get_hl(0, { name = "Keyword", link = false }).bold, nil, "reapply picks new opts")
end,
["switch away and back"] = function()
  h.reload(); vim.cmd.colorscheme("default")
  h.ok(not pcall(vim.api.nvim_get_autocmds, { group = "GruberDarker" }), "augroup gone while away")
  vim.cmd.colorscheme("gruber-darker")
  h.eq(vim.g.colors_name, "gruber-darker", "colors_name")
  h.eq(#vim.api.nvim_get_autocmds({ group = "GruberDarker", event = "ColorSchemePre" }), 1, "one ColorSchemePre autocmd")
  h.eq(h.hl("Normal").bg, 0x181818, "Normal bg")
end,
["palette values are hex strings"] = function()
  for k, v in pairs(require("gruber-darker.palette")) do
    h.ok(v == "NONE" or v:match("^#%x%x%x%x%x%x$"), "palette." .. k .. " = " .. tostring(v))
  end
end,
["no dangling links"] = function() -- fixes 2, 3
  -- baseline: groups Neovim defines after `hi clear` with no colorscheme
  vim.cmd.hi("clear"); local builtin = vim.api.nvim_get_hl(0, {})
  local opts = require("gruber-darker.config").get()
  local hls = require("gruber-darker.highlights")
  local built = hls.build(hls.resolve_palette(opts), opts)
  for name, spec in pairs(built) do
    if spec.link then h.ok(built[spec.link] or builtin[spec.link], name .. " -> missing " .. spec.link) end
  end
  for pair in require("gruber-darker").SIDEBAR_WINHIGHLIGHT:gmatch("[^,]+") do
    local target = pair:match(":(.+)$"); h.ok(built[target] or builtin[target], "winhighlight -> missing " .. target)
  end
end,
["TelescopeNormal and CmpItemAbbrDeprecated resolve"] = function()
  h.reload()
  h.eq(h.hl("TelescopeNormal"), { link = "GruberDarkerFg0" }, "TelescopeNormal")
  h.eq(h.hl("CmpItemAbbrDeprecated"), { link = "GruberDarkerDarkestNiagara" }, "CmpItemAbbrDeprecated")
end,
["duplicate groups are rejected"] = function()
  local hls = require("gruber-darker.highlights")
  local p = function() return { Foo = { fg = "#000000" } } end
  local okk, err = pcall(hls.build, {}, {}, { { name = "a", fn = p }, { name = "b", fn = p } })
  h.ok(not okk and tostring(err):find("duplicate highlight group Foo in a and b", 1, true), tostring(err))
end,
["doc comments carry italic"] = function() -- fix 13
  h.reload()
  local s = h.hl("@comment.documentation"); h.eq(s.fg, 0x73d936, "fg green"); h.eq(s.italic, true, "italic")
  h.reload({ italic = { comments = false } }); h.eq(h.hl("@comment.documentation").italic, nil, "italic off")
end,
```

The `no dangling links` test is expected to fail on `SignColumnSB` until Step 3 defines it.

- [ ] **Step 2: Run to verify failure**

Run: `nvim --headless --clean -l tests/run.lua core`
Expected: FAIL. It errors on `resolve_palette`/`build` being nil. The setup tests fail with `Keyword bold`.

- [ ] **Step 3: Rewrite the core per the Interfaces block**
  - Translate every existing provider entry 1:1. Object links like `{ link = gruber_hl.niagara }` become the name of the group that object held (`{ link = "GruberDarkerNiagara" }`). `c.x` becomes the palette string.
  - Keep today's specs exactly, including today's old tree-sitter capture names. Task 4 renames them.
  - Exceptions:
    - `TelescopeNormal` → `{ link = "GruberDarkerFg0" }`
    - `CmpItemAbbrDeprecated` → `{ link = "GruberDarkerDarkestNiagara" }`
    - Capitalise `CmpItemKindClass`.
    - `@comment.documentation` → `{ fg = c.green, italic = opts.italic.comments }`
    - Add `SignColumnSB = { fg = c["bg+2"], bg = c.none }` to the vim provider.
  - In `lua/gruber-darker.lua`:
    - Keep the `GruberDarker` augroup, the `ColorSchemePre` self-cleanup, the `FileType qf,help` autocmd (using `SIDEBAR_WINHIGHLIGHT`) and the existing `ColorScheme` `@lsp` wipe autocmd. Task 4 replaces the wipe.
    - Delete `M.colorscheme`, and delete the commented reload code in `colors/gruber-darker.lua`.
  - Keep `vim.opt.termguicolors = true` and the `hi clear` in `load()`.

- [ ] **Step 4: Update `tests/snapshot_expected.lua`**
  - Add `TelescopeNormal`, `CmpItemAbbrDeprecated`, `@comment.documentation` and `SignColumnSB`.
  - `CmpitemKindClass` / `CmpItemKindClass` won't appear, because names are case-insensitive. Add it only if the check reports it.

- [ ] **Step 5: Run tests and the guard**

Run: `nvim --headless --clean -l tests/run.lua && nvim --headless --clean -l tests/snapshot.lua check`
Expected: all PASS, then `snapshot OK (4 expected differences)`.

- [ ] **Step 6: Commit** with `refactor: rebuild core around plain palette and provider functions`

---

### Task 3: Override API and README (#5, #15, Review Focus 1 and 4)

**Files:**
- Modify: `lua/gruber-darker/highlights/init.lua`, `README.md`
- Create: `tests/overrides_spec.lua`

**Interfaces:**
- Consumes: `config.DEFAULTS.palette`, `config.DEFAULTS.overrides`, `highlights.resolve_palette`, `highlights.apply` (Task 2).
- Produces:
  - `resolve_palette(opts)` returns the base palette merged with `opts.palette`. On an invalid entry it calls `error(('gruber-darker: invalid palette color "%s": %s'):format(key, vim.inspect(value)))`. Valid values are `"NONE"` or `^#%x%x%x%x%x%x$`.
  - `apply(opts)` validates the palette before calling any `nvim_set_hl`. As its last step, it applies `opts.overrides`: either the table itself, or the result of calling `opts.overrides(c, opts)` when it's a function. Each entry replaces that group's spec via `nvim_set_hl`.

- [ ] **Step 1: Write the tests in `tests/overrides_spec.lua`:**

```lua
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
  h.reload({ palette = { yellow = "#abcdef" }, overrides = function(c) got = c.yellow; return { LineNr = { fg = c.yellow } } end })
  h.eq(got, "#abcdef", "c.yellow"); h.eq(h.hl("LineNr").fg, 0xabcdef, "LineNr fg")
end,
["override replaces spec and dependents follow"] = function()
  h.reload({ overrides = { GruberDarkerNiagara = { fg = "#010203" } } })
  h.eq(vim.api.nvim_get_hl(0, { name = "Function", link = false }).fg, 0x010203, "Function follows")
end,
["invalid palette value errors with key name"] = function()
  local okk, err = pcall(h.reload, { palette = { yellow = "#fff" } })
  h.ok(not okk and tostring(err):find('invalid palette color "yellow"', 1, true), tostring(err))
end,
```

- [ ] **Step 2: Run to verify failure**

Run: `nvim --headless --clean -l tests/run.lua overrides`
Expected: FAIL on all 5.

- [ ] **Step 3: Implement per the Interfaces block**

- [ ] **Step 4: Update `README.md`**
  - State "Requires Neovim >= 0.10."
  - Add the three new keys to the Defaults block (`palette = {}`, `overrides = {}`, `semantic_tokens = false`).
  - Add an "Overriding colors" section with the `LineNr` example from the spec, which answers #15, and the function form.
  - Note that `require("gruber-darker.palette")` returns hex strings.
  - Add a "Development" section with the two test commands.

- [ ] **Step 5: Run all tests and the guard**

Run: `nvim --headless --clean -l tests/run.lua && nvim --headless --clean -l tests/snapshot.lua check`
Expected: all PASS, and `snapshot OK (4 expected differences)`.

- [ ] **Step 6: Commit** with `feat: add palette and overrides options`

---

### Task 4: Tree-sitter captures and LSP fixes (fixes 4, 5, 6)

**Files:**
- Modify: `lua/gruber-darker/highlights/treesitter.lua`, `lua/gruber-darker/highlights/lsp.lua`, `lua/gruber-darker/highlights/init.lua`, `lua/gruber-darker.lua`, `tests/snapshot_expected.lua`
- Create: `tests/treesitter_spec.lua`, `tests/lsp_spec.lua`

**Interfaces:**
- Consumes: `config.DEFAULTS.semantic_tokens` (Task 2) and `highlights.apply` (Task 2).
- Produces: `apply` runs the semantic step after the base groups and before the overrides.
  - When `opts.semantic_tokens == false`, it sets every name from `vim.fn.getcompletion("@lsp", "highlight")` to `{}`.
  - Then it sets `@lsp.type.comment.<ft> = { link = "Comment" }` for `ft` in `{ "c", "cpp", "objc", "objcpp", "cuda" }`.
  - The `ColorScheme` `@lsp`-wipe autocmd in `lua/gruber-darker.lua` is removed.

- [ ] **Step 1: Write `tests/treesitter_spec.lua`:**

```lua
local RENAMED = { -- new name -> exact unresolved spec carried over from the old capture (spec fix 4)
  ["@variable.member"] = { link = "GruberDarkerNiagara" }, ["@variable.parameter"] = { link = "Identifier" },
  ["@function.method"] = { link = "Function" }, ["@keyword.conditional"] = { fg = 0xffdd33 },
  ["@keyword.conditional.ternary"] = { link = "Operator" }, ["@keyword.repeat"] = { link = "Repeat" },
  ["@keyword.debug"] = { link = "Debug" }, ["@keyword.modifier"] = { link = "StorageClass" },
  ["@keyword.directive"] = { link = "PreProc" }, ["@keyword.directive.define"] = { link = "Define" },
  ["@string.regexp"] = { link = "Constant" }, ["@number.float"] = { link = "Float" },
  ["@markup.strong"] = { link = "Bold" }, ["@markup.italic"] = { link = "Italic" },
  ["@markup.underline"] = { link = "Underlined" }, ["@markup.strikethrough"] = { strikethrough = true },
  ["@markup.heading"] = { link = "Title" }, ["@markup.raw"] = { link = "Constant" },
  ["@markup.link.url"] = { fg = 0x96a6c8, underline = true }, ["@markup.link"] = { link = "GruberDarkerYellowBold" },
  ["@comment.todo"] = { link = "Todo" }, ["@comment.note"] = { link = "Comment" },
  ["@comment.warning"] = { link = "WarningMsg" }, ["@comment.error"] = { link = "ErrorMsg" },
  ["@diff.plus"] = { link = "DiffAdd" }, ["@diff.minus"] = { link = "DiffDelete" }, ["@diff.delta"] = { link = "DiffChange" },
  ["@property"] = { link = "@variable.member" },
}
local OLD = { "@field", "@parameter", "@method", "@conditional", "@conditional.ternary", "@repeat", "@debug",
  "@storageclass", "@preproc", "@define", "@string.regex", "@float", "@text", "@error", "@text.strong",
  "@text.emphasis", "@text.underline", "@text.strike", "@text.title", "@text.literal", "@text.uri",
  "@text.reference", "@text.todo", "@text.note", "@text.warning", "@text.danger", "@text.diff.add",
  "@text.diff.delete", "@text.diff.change" }
-- tests:
["renamed captures keep their spec"] -- h.reload(); for each RENAMED: h.eq(strip_cterm(h.hl(k)), v, k)
["old capture names are not defined"] -- h.reload(); for each OLD: h.eq(vim.fn.hlexists(name), 0, name)
```

`strip_cterm` is a helper in `tests/helpers.lua` that drops the `cterm` key, because `nvim_get_hl` adds `cterm` for underline. When `underline = false` is configured, `@markup.link.url` has no underline. That case isn't tested here, and the default opts are used.

- [ ] **Step 2: Write `tests/lsp_spec.lua`:**

```lua
["DiagnosticUnnecessary links Comment"] = function() h.reload(); h.eq(h.hl("DiagnosticUnnecessary"), { link = "Comment" }, "") end,
["semantic tokens off: clangd comment only"] = function()
  h.reload()
  for _, ft in ipairs({ "c", "cpp", "objc", "objcpp", "cuda" }) do h.eq(h.hl("@lsp.type.comment." .. ft), { link = "Comment" }, ft) end
  h.eq(h.hl("@lsp.type.comment"), {}, "generic comment cleared"); h.eq(h.hl("@lsp.type.variable"), {}, "variable cleared")
end,
["semantic tokens on: defaults kept"] = function()
  h.reload({ semantic_tokens = true }); h.eq(h.hl("@lsp.type.variable"), { link = "@variable" }, "default link kept")
end,
```

- [ ] **Step 3: Run to verify failure**

Run: `nvim --headless --clean -l tests/run.lua treesitter && nvim --headless --clean -l tests/run.lua lsp`
Expected: FAIL. Old names are defined, `@variable.member` is missing, `DiagnosticUnnecessary` links to `DiagnosticUnderlineHint`, and `@lsp.type.comment.c` is empty.

- [ ] **Step 4: Implement**
  - Rename the tree-sitter keys per the spec table and drop `@text` and `@error`. `@comment.luadoc` keeps linking to `@comment.documentation`.
  - Set `DiagnosticUnnecessary = { link = "Comment" }`.
  - Add the semantic step to `apply` and remove the autocmd.

- [ ] **Step 5: Update `tests/snapshot_expected.lua`**
  - Add every key of `RENAMED` and every `OLD` name.
  - Add `DiagnosticUnnecessary` and `@lsp.type.comment.{c,cpp,objc,objcpp,cuda}`.
  - If the check reports `STALE` for an `OLD` name whose baseline spec was `{}` (`@conditional.ternary`, `@error`), check that name in `tests/snapshot-before.txt`. If it isn't there, the baseline never listed it, so drop it from the allowlist. Treat any other `STALE` as a code bug.

- [ ] **Step 6: Run all tests and the guard**

Run: `nvim --headless --clean -l tests/run.lua && nvim --headless --clean -l tests/snapshot.lua check`
Expected: all PASS, and `snapshot OK`. If the check reports `UNEXPECTED` on any other `@lsp*` name, the semantic step is clearing or linking the wrong set, so fix the code rather than the allowlist.

- [ ] **Step 7: Commit** with `fix: modern tree-sitter captures, unnecessary-code dimming, clangd inactive regions`

---

### Task 5: Editor UI and plugin fixes (fixes 7, 8, 9, 10, 11, 12)

**Files:**
- Modify: `lua/gruber-darker/highlights/vim.lua`, `lua/gruber-darker/highlights/init.lua`, `tests/snapshot_expected.lua`
- Create: `lua/gruber-darker/highlights/visual-multi.lua`, `tests/ui_spec.lua`

**Interfaces:**
- Consumes: the provider signature and `build`'s provider list (Task 2). Append `visual-multi` last.
- Produces: no new public API.

- [ ] **Step 1: Write `tests/ui_spec.lua`** (after `h.reload()`, compare against `strip_cterm(h.hl(...))`):

```lua
["javaScript and htmlCssDefinition are plain"]   -- both == { link = "Normal" }
["popup thumb visible"]     -- PmenuThumb == { bg = 0x52494e }; PmenuSbar == { bg = 0x181818 }
["fold column has no bg"]   -- FoldColumn == { fg = 0xcc8c3c }
["visual-multi groups"]     -- VM_Cursor == { fg = 0x000000, bg = 0xffdd33 }; VM_Insert same;
                            -- VM_Extend == { link = "Visual" }; VM_Mono == { link = "ErrorMsg" }
["DiffText distinct"]       -- DiffText == { fg = 0xffdd33, bg = 0x453d41, bold = true }; DiffChange == { fg = 0xffdd33 }
["guicursor append is idempotent"] = function()
  h.reload(); h.reload(); vim.cmd.colorscheme("gruber-darker")
  local _, n = vim.o.guicursor:gsub("a:Cursor/lCursor", ""); h.eq(n, 1, vim.o.guicursor)
end,
```

- [ ] **Step 2: Run to verify failure**

Run: `nvim --headless --clean -l tests/run.lua ui`
Expected: all 6 FAIL.

- [ ] **Step 3: Implement**
  - In `vim.lua`:
    - `javaScript` and `htmlCssDefinition` → `{ link = "Normal" }`
    - `PmenuThumb.bg = c["bg+4"]`
    - `FoldColumn = { fg = c.brown, bg = c.none }`
    - `DiffText = { fg = c.yellow, bg = c["bg+2"], bold = opts.bold }`
  - Create `visual-multi.lua` with the four `VM_*` groups.
  - In `apply`, only append `a:Cursor/lCursor` to `vim.opt.guicursor` when `vim.o.guicursor` doesn't already contain it.

- [ ] **Step 4: Update `tests/snapshot_expected.lua`**
  - Add `javaScript`, `htmlCssDefinition`, `PmenuThumb`, `FoldColumn`, `DiffText` and the four `VM_*` names.
  - `CursorLineFold` links to `FoldColumn` and stays unchanged as a link.

- [ ] **Step 5: Run all tests and the guard**

Run: `nvim --headless --clean -l tests/run.lua && nvim --headless --clean -l tests/snapshot.lua check`
Expected: all PASS, and `snapshot OK`.

- [ ] **Step 6: Commit** with `fix: html script bodies, popup thumb, fold column, diff text, visual-multi, guicursor`

---

### Task 6: Owner environment: push guard and JavaScript parser

**Files:**
- Modify: repo git config, `~/.config/nvim/init.lua` (`ts_langs`, around line 139)

- [ ] **Step 1: Push guard**

Run:
```bash
git config remote.pushDefault origin
gh repo set-default aardwulf89/gruber-darker.nvim
gh repo set-default --view; git config --get remote.pushDefault; git remote
```
Expected: `aardwulf89/gruber-darker.nvim`, then `origin`, then only `origin`.

- [ ] **Step 2: Back up the config**
  - Run `cp ~/.config/nvim/init.lua ~/.config/nvim/init.lua.bak-2026-11-06` and the same for `nvim-pack-lock.json`.
  - `~/.config/nvim` isn't under git.

- [ ] **Step 3: Add `'javascript'` to `ts_langs`.** Keep the list in alphabetical order, between `html` and `json`.

- [ ] **Step 4: Install the parser and verify**

Run: `nvim --headless -c "lua require('nvim-treesitter').install({ 'javascript' }):wait(300000)" -c q && ls ~/.local/share/nvim/site/parser/javascript.so`
Expected: the file exists.

Then verify the injection with a headless script. Open `/tmp/gd-probe/t.html`. Run `vim.treesitter.start()`, then `vim.treesitter.get_parser():parse(true)`. `vim.inspect_pos(0, 1, 0).treesitter` must contain an entry with `lang == "javascript"`.

- [ ] **Step 5: No commit**, since the config is outside the repo. Report the backup paths.

---

### Task 7: After merge and push: swap the Neovim config to the fork

Run this only after `superpowers:finishing-a-development-branch` has merged the branch to `main` and pushed it to `origin`.

- [ ] **Step 1: Edit `~/.config/nvim/init.lua`.** In the `vim.pack.add` list, change `'https://github.com/blazkowolf/gruber-darker.nvim'` to `'https://github.com/aardwulf89/gruber-darker.nvim'`.

- [ ] **Step 2: Trigger the reinstall and verify**

Run: `nvim --headless -c q; git -C ~/.local/share/nvim/site/pack/core/opt/gruber-darker.nvim remote get-url origin; git -C ~/.local/share/nvim/site/pack/core/opt/gruber-darker.nvim rev-parse HEAD; git -C /home/alex/Projects/gruber-darker.nvim rev-parse origin/main; grep -A2 '"gruber-darker.nvim"' ~/.config/nvim/nvim-pack-lock.json`
Expected:
- The remote URL contains `aardwulf89/gruber-darker.nvim`.
- Both revs are equal.
- The lockfile `src` is the fork.

- [ ] **Step 3: Smoke test the real config**

Run: `nvim --headless -c 'lua print(vim.g.colors_name, vim.api.nvim_get_hl(0,{name="@variable.member"}).link)' -c q`
Expected: `gruber-darker GruberDarkerNiagara`
