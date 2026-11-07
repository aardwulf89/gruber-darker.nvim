-- Minimal test runner.
-- Usage: nvim --headless --clean -l tests/run.lua [filter]
-- Loads every tests/*_spec.lua whose filename contains `filter` (all when absent).
-- Each spec file returns `table<string, fun()>`.

local script = debug.getinfo(1, "S").source:sub(2)
local tests_dir = vim.fn.fnamemodify(script, ":p:h")
local root = vim.fn.fnamemodify(tests_dir, ":h")

vim.opt.runtimepath:prepend(root)
package.path = tests_dir .. "/?.lua;" .. package.path

local filter = arg[1]
local files = vim.fn.glob(tests_dir .. "/*_spec.lua", false, true)
table.sort(files)

local passed, failed = 0, 0
for _, file in ipairs(files) do
	local fname = vim.fn.fnamemodify(file, ":t")
	if not filter or fname:find(filter, 1, true) then
		local spec = dofile(file)
		local names = vim.tbl_keys(spec)
		table.sort(names)
		for _, name in ipairs(names) do
			local ok, err = pcall(spec[name])
			if ok then
				passed = passed + 1
				io.write("PASS ", name, "\n")
			else
				failed = failed + 1
				io.write("FAIL ", name, ": ", tostring(err), "\n")
			end
		end
	end
end

io.write(string.format("%d passed, %d failed\n", passed, failed))
os.exit(failed > 0 and 1 or 0)
