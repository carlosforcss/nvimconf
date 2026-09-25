local M = {}

-- Copies: package.tests.test_file.TestClass.test_func
-- (project-root-relative module path + nearest class/function via Treesitter)
function M.copy()
  local rel = vim.fs.relpath(LazyVim.root(), vim.fn.expand("%:p")) or vim.fn.expand("%")
  local dotted = rel:gsub("\\", "/"):gsub("%.py$", ""):gsub("/", "."):gsub("%.__init__$", "")

  local class_name, func_name
  local node = vim.treesitter.get_node()
  while node do
    local t = node:type()
    local name = node:field("name")[1]
    if not func_name and t == "function_definition" and name then
      func_name = vim.treesitter.get_node_text(name, 0)
    end
    if not class_name and t == "class_definition" and name then
      class_name = vim.treesitter.get_node_text(name, 0)
    end
    node = node:parent()
  end

  if class_name then
    dotted = dotted .. "." .. class_name
  end
  if func_name then
    dotted = dotted .. "." .. func_name
  end

  vim.fn.setreg("+", dotted)
  vim.notify("Copied: " .. dotted)
end

return M
