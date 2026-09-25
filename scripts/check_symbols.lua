-- Runs utils/symbols.lua over scripts/fixture with the real ripgrep arguments and compares against expected.txt.
-- Usage: nvim --headless -u NONE --cmd "set rtp^=<config>" -l scripts/check_symbols.lua <fixture-dir> [--update]
local fixture, update = arg[1], arg[2] == "--update"

-- Capture the proc() options instead of spawning through Snacks (not loaded with -u NONE)
local captured
package.loaded["snacks.picker.source.proc"] = {
  proc = function(o)
    captured = o
    return function() end
  end,
}
require("utils.symbols").finder({ cwd = fixture }, {
  opts = function(_, o)
    return o
  end,
})

local out = vim.system(vim.list_extend({ "rg" }, captured.args), { cwd = fixture }):wait()
local lines = {}
for l in out.stdout:gmatch("[^\n]+") do
  local item = captured.transform({ text = l })
  if item then
    lines[#lines + 1] = ("%s %s %s:%d rank=%d"):format(item.kind, item.text, item.file, item.pos[1], item.rank)
  end
end
table.sort(lines)

local expected_file = fixture .. "/expected.txt"
if update then
  vim.fn.writefile(lines, expected_file)
  io.stdout:write("updated " .. expected_file .. " (" .. #lines .. " symbols)" .. "\n")
  return
end

local function set(list)
  local s = {}
  for _, l in ipairs(list) do
    s[l] = true
  end
  return s
end
local expected = vim.fn.readfile(expected_file)
local got, want = set(lines), set(expected)
local diff = {}
for _, l in ipairs(expected) do
  if not got[l] then
    diff[#diff + 1] = "  missing:    " .. l
  end
end
for _, l in ipairs(lines) do
  if not want[l] then
    diff[#diff + 1] = "  unexpected: " .. l
  end
end
if #diff == 0 then
  io.stdout:write("OK   symbols: " .. #lines .. " fixture symbols match" .. "\n")
else
  io.stdout:write("FAIL symbols: differs from scripts/fixture/expected.txt\n" .. table.concat(diff, "\n") .. "\n")
  os.exit(1)
end
