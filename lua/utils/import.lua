local M = {}

local function get_project_root()
  local ok, util = pcall(require, "lazyvim.util")
  return (ok and util.root.get()) or vim.loop.cwd()
end

local function split_path_parts(path)
  local parts = {}
  for p in path:gmatch("[^/]+") do
    table.insert(parts, p)
  end
  return parts
end

local function build_python_import(def_path, symbol)
  local root = get_project_root()
  local rel = (vim.fs.relpath(root, def_path) or def_path):gsub("\\", "/")
  if rel:match("/__init__%.py$") then
    local mod = rel:gsub("/__init__%.py$", ""):gsub("/", ".")
    return "from " .. mod .. " import " .. symbol
  end
  local mod = rel:gsub("%.pyi?$", ""):gsub("/", ".")
  return "from " .. mod .. " import " .. symbol
end

local function build_js_import(def_path, symbol)
  local nm = def_path:match("node_modules/(.+)")
  if nm then
    local pkg = nm:match("^(@[^/]+/[^/]+)") or nm:match("^([^/]+)")
    return "import { " .. symbol .. " } from '" .. pkg .. "'"
  end

  local cur_dir = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":h")
  local from = split_path_parts(cur_dir)
  local to = split_path_parts(def_path)

  local common = 0
  for i = 1, math.min(#from, #to) do
    if from[i] == to[i] then
      common = i
    else
      break
    end
  end

  local result = {}
  for _ = 1, #from - common do
    table.insert(result, "..")
  end
  for i = common + 1, #to do
    table.insert(result, to[i])
  end

  local rel = table.concat(result, "/"):gsub("%.[jt]sx?$", "")
  if not rel:match("^%.%.") then
    rel = "./" .. rel
  end
  return "import { " .. symbol .. " } from '" .. rel .. "'"
end

local function build_rust_import(def_path, symbol)
  if def_path:match("toolchains/") then
    local lib = def_path:match("library/([^/]+)/src/(.+)%.rs$")
    if lib then
      local inner = def_path:match("library/[^/]+/src/(.+)%.rs$"):gsub("/", "::"):gsub("::mod$", "")
      return "use " .. lib .. "::" .. inner .. "::" .. symbol .. ";"
    end
    return "use " .. symbol .. ";"
  end

  local root = get_project_root()
  local rel = (vim.fs.relpath(root, def_path) or def_path):gsub("\\", "/")
  local mod = rel:gsub("^src/", ""):gsub("%.rs$", ""):gsub("/mod$", "")
  if mod == "lib" or mod == "main" then
    return "use " .. symbol .. ";"
  end
  return "use crate::" .. mod:gsub("/", "::") .. "::" .. symbol .. ";"
end

local builders = {
  python = build_python_import,
  javascript = build_js_import,
  typescript = build_js_import,
  javascriptreact = build_js_import,
  typescriptreact = build_js_import,
  rust = build_rust_import,
}

function M.yank_import()
  local symbol = vim.fn.expand("<cword>")
  if symbol == "" then
    vim.notify("No symbol under cursor", vim.log.levels.WARN)
    return
  end

  local ft = vim.bo.filetype
  local builder = builders[ft]
  if not builder then
    vim.notify("yi: unsupported filetype '" .. ft .. "'", vim.log.levels.WARN)
    return
  end

  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result)
    if err or not result or (vim.islist(result) and #result == 0) then
      vim.notify("No definition found for: " .. symbol, vim.log.levels.WARN)
      return
    end

    local loc = vim.islist(result) and result[1] or result
    local def_path = vim.uri_to_fname(loc.uri or loc.targetUri)
    local import_str = builder(def_path, symbol)

    vim.fn.setreg("+", import_str)
    vim.notify("Copied: " .. import_str)
  end)
end

return M
