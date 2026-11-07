-- Highlight snapshot guard.
-- Usage:
--   nvim --headless --clean -l tests/snapshot.lua dump <path>
--   nvim --headless --clean -l tests/snapshot.lua check

local script = debug.getinfo(1, "S").source:sub(2)
local tests_dir = vim.fn.fnamemodify(script, ":p:h")
local root = vim.fn.fnamemodify(tests_dir, ":h")

vim.opt.runtimepath:prepend(root)
vim.cmd.colorscheme("gruber-darker")

local function serialise(spec)
	return vim.inspect(spec, { newline = "", indent = "" })
end

---@return table<string, string>
local function collect()
	local snapshot = {}
	for name in pairs(vim.api.nvim_get_hl(0, {})) do
		snapshot[name] = serialise(vim.api.nvim_get_hl(0, { name = name }))
	end
	return snapshot
end

---@param snapshot table<string, string>
---@return string[]
local function to_lines(snapshot)
	local names = vim.tbl_keys(snapshot)
	table.sort(names)
	return vim.tbl_map(function(name)
		return name .. "\t" .. snapshot[name]
	end, names)
end

local function dump(path)
	vim.fn.writefile(to_lines(collect()), path)
end

local function check()
	local before = {}
	for _, line in ipairs(vim.fn.readfile(tests_dir .. "/snapshot-before.txt")) do
		local name, spec = line:match("^([^\t]*)\t(.*)$")
		before[name] = spec
	end
	local after = collect()

	-- name -> { kind, before, after }
	local diffs = {}
	for name, spec in pairs(after) do
		if before[name] == nil then
			diffs[name] = { "added", "<none>", spec }
		elseif before[name] ~= spec then
			diffs[name] = { "changed", before[name], spec }
		end
	end
	for name, spec in pairs(before) do
		if after[name] == nil then
			diffs[name] = { "removed", spec, "<none>" }
		end
	end

	local expected = dofile(tests_dir .. "/snapshot_expected.lua")
	local failed = false
	local names = vim.tbl_keys(diffs)
	table.sort(names)
	for _, name in ipairs(names) do
		if not expected[name] then
			local d = diffs[name]
			print(string.format("UNEXPECTED %s %s: %s -> %s", d[1], name, d[2], d[3]))
			failed = true
		end
	end
	local stale = vim.tbl_keys(expected)
	table.sort(stale)
	for _, name in ipairs(stale) do
		if not diffs[name] then
			print("STALE " .. name)
			failed = true
		end
	end

	if failed then
		os.exit(1)
	end
	print(string.format("snapshot OK (%d expected differences)", #names))
	os.exit(0)
end

local cmd, path = arg[1], arg[2]
if cmd == "dump" and path then
	dump(path)
elseif cmd == "check" then
	check()
else
	print("usage: snapshot.lua dump <path> | check")
	os.exit(2)
end
