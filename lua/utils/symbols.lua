-- PyCharm-style "Go to Symbol": ripgrep streams every definition line in the project once,
-- then the Snacks matcher fuzzy-filters on the symbol name (optionally `Container.name`).
local M = {}

local function get_project_root()
  local ok, util = pcall(require, "lazyvim.util")
  return (ok and util.root.get()) or vim.uv.cwd()
end

-- Coarse ripgrep patterns (PCRE2). The transform re-parses each line per language and drops false positives.
local rg_patterns = {
  -- python
  [[^\s*(?:async\s+)?def\s+\w+]],
  [[^\s*(?:export\s+)?(?:default\s+)?(?:declare\s+)?(?:abstract\s+)?class\s+[\w$]+]],
  -- rust
  [[^\s*(?:pub(?:\([^)]*\))?\s+)?(?:(?:default|async|const|unsafe|extern(?:\s+"\w+")?)\s+)*fn\s+\w+]],
  [[^\s*(?:pub(?:\([^)]*\))?\s+)?(?:struct|enum|trait|type|mod|union)\s+\w+]],
  [[^\s*(?:unsafe\s+)?impl\b]],
  -- go
  [[^func\s]],
  [[^type\s+\w+]],
  -- js / ts
  [[^\s*(?:export\s+)?(?:default\s+)?(?:declare\s+)?(?:async\s+)?function\b]],
  [[^\s*(?:export\s+)?(?:declare\s+)?(?:abstract\s+)?(?:interface|enum|type|const\s+enum)\s+[\w$]+]],
  [[^\s*(?:export\s+)?(?:const|let|var)\s+[\w$]+[^=]*=\s*(?:async\s+)?(?:function\b|\([^)]*\)\s*(?::[^=]+)?=>|[\w$]+\s*=>)]],
  [[^\s+(?!(?:if|for|while|switch|catch|return|else|match|loop|with|elif|except|await|new|throw|typeof|super|this)\b)(?:(?:public|private|protected|static|readonly|async|override|abstract|get|set)\s+)*[#\w$]+\s*(?:<[^>]*>)?\([^;]*\)[^;=]*\{\s*\}?\s*$]],
  [[^\s+(?:(?:public|private|protected|static|readonly)\s+)*[#\w$]+\s*=\s*(?:async\s+)?(?:\([^)]*\)|[\w$]+)\s*=>]],
  -- lua
  [[^\s*(?:local\s+)?function\s+[\w.:]+]],
}

local lang_by_ext = {
  py = "python",
  pyi = "python",
  rs = "rust",
  go = "go",
  lua = "lua",
  js = "js",
  jsx = "js",
  mjs = "js",
  cjs = "js",
  ts = "js",
  tsx = "js",
  mts = "js",
  cts = "js",
}

local js_keywords = {}
for _, k in ipairs({ "if", "for", "while", "switch", "catch", "return", "else", "function", "new", "throw", "await" }) do
  js_keywords[k] = true
end

local rust_qualifiers = { pub = true, async = true, const = true, unsafe = true, extern = true, default = true }

---@return string? kind, string? name, boolean? container
local function parse_python(line)
  local name = line:match("^async%s+def%s+([%w_]+)") or line:match("^def%s+([%w_]+)")
  if name then
    return "Function", name
  end
  name = line:match("^class%s+([%w_]+)")
  if name then
    return "Class", name, true
  end
end

local function rust_impl_type(line)
  local rest = line:gsub("^unsafe%s+", ""):gsub("^impl%s*", "")
  rest = rest:gsub("^%b<>", "")
  rest = rest:match("%sfor%s+(.*)") or rest
  rest = rest:gsub("^[&%s]*", ""):gsub("^dyn%s+", ""):gsub("^mut%s+", "")
  local path = rest:match("^([%w_:]+)")
  return path and path:match("([%w_]+)$")
end

local function parse_rust(line)
  if line:match("^unsafe%s+impl[%s<]") or line:match("^impl[%s<]") then
    local t = rust_impl_type(line)
    return t and "impl" or nil, t, true
  end
  local l = line:gsub("pub%b()", "pub"):gsub('extern%s+"%w+"', "extern")
  local prefix, name = l:match("^(.-)fn%s+([%w_]+)")
  if name then
    for word in prefix:gmatch("%S+") do
      if not rust_qualifiers[word] then
        return
      end
    end
    return "Function", name
  end
  local kw
  l = l:gsub("^pub%s+", "")
  kw, name = l:match("^(%a+)%s+([%w_]+)")
  local kinds =
    { struct = "Struct", enum = "Enum", trait = "Interface", type = "TypeParameter", mod = "Module", union = "Struct" }
  if kw and kinds[kw] then
    return kinds[kw], name, kw == "trait"
  end
end

---@return string? kind, string? name, boolean? container, string? receiver
local function parse_go(line)
  local recv, name = line:match("^func%s*(%b())%s*([%w_]+)")
  if recv and name then
    local t = recv:sub(2, -2):gsub("%b[]", ""):match("([%w_]+)%s*$")
    return "Method", name, false, t
  end
  name = line:match("^func%s+([%w_]+)")
  if name then
    return "Function", name
  end
  local tname, rest = line:match("^type%s+([%w_]+)(.*)$")
  if tname then
    rest = rest:gsub("^%b[]", "")
    if rest:match("^%s*struct") then
      return "Struct", tname
    elseif rest:match("^%s*interface") then
      return "Interface", tname
    end
    return "TypeParameter", tname
  end
end

local function parse_js(line, in_class)
  local l = line
  local stripped = true
  while stripped do
    stripped = false
    for _, mod in ipairs({ "export", "default", "declare", "abstract", "async" }) do
      local s = l:gsub("^" .. mod .. "%s+", "", 1)
      if s ~= l then
        l, stripped = s, true
      end
    end
  end
  local name = l:match("^function%*?%s*([%w_$]+)")
  if name then
    return "Function", name
  end
  name = l:match("^class%s+([%w_$]+)")
  if name then
    return "Class", name, true
  end
  name = l:match("^interface%s+([%w_$]+)")
  if name then
    return "Interface", name
  end
  name = l:match("^enum%s+([%w_$]+)") or l:match("^const%s+enum%s+([%w_$]+)")
  if name then
    return "Enum", name
  end
  name = l:match("^type%s+([%w_$]+)%s*[<=]")
  if name then
    return "TypeParameter", name
  end
  local decl = l:match("^const%s+(.*)") or l:match("^let%s+(.*)") or l:match("^var%s+(.*)")
  local rhs
  if decl then
    name, rhs = decl:match("^([%w_$]+)[^=]*=%s*(.*)$")
  end
  if name and (rhs:match("=>") or rhs:match("^async%s+function") or rhs:match("^function")) then
    return "Function", name
  end
  if in_class then
    local m = l
    stripped = true
    while stripped do
      stripped = false
      for _, mod in ipairs({ "public", "private", "protected", "static", "readonly", "override", "get", "set" }) do
        local s = m:gsub("^" .. mod .. "%s+", "", 1)
        if s ~= m then
          m, stripped = s, true
        end
      end
    end
    name = m:match("^([#%w_$]+)%s*<[^>]*>%s*%(") or m:match("^([#%w_$]+)%s*%(")
    if name and not js_keywords[name] then
      return "Method", name
    end
    name = m:match("^([#%w_$]+)%s*=%s*.-=>")
    if name then
      return "Method", name
    end
  end
end

local function parse_lua(line)
  local name = line:match("^local%s+function%s+([%w_]+)") or line:match("^function%s+([%w_.:]+)")
  if name then
    return "Function", name
  end
end

local low_rank_paths =
  { "/tests?/", "/spec/", "/vendor/", "/migrations/", "_test%.", "%.test%.", "%.spec%.", "/conftest%.py$" }

local function path_rank(file)
  local f = "/" .. file:lower()
  for _, p in ipairs(low_rank_paths) do
    if f:find(p) then
      return 1
    end
  end
  return 0
end

--- Parse one ripgrep match into a picker item. `state` tracks enclosing classes/impls per file.
---@return table|false
function M.parse(state, file, lnum, text)
  local lang = lang_by_ext[file:match("%.(%w+)$") or ""]
  if not lang then
    return false
  end
  if state.file ~= file then
    state.file, state.stack = file, {}
  end
  local indent = #text:match("^%s*")
  local line = text:sub(indent + 1)
  local stack = state.stack
  while #stack > 0 and stack[#stack].indent >= indent do
    table.remove(stack)
  end
  local top = stack[#stack]

  local kind, name, is_container, receiver
  if lang == "python" then
    kind, name, is_container = parse_python(line)
  elseif lang == "rust" then
    kind, name, is_container = parse_rust(line)
  elseif lang == "go" then
    kind, name, is_container, receiver = parse_go(line)
  elseif lang == "js" then
    kind, name, is_container = parse_js(line, top and top.class)
  else
    kind, name = parse_lua(line)
  end
  if not kind then
    return false
  end

  local container = receiver
  if not container and top and top.class then
    container = top.name
    if kind == "Function" then
      kind = "Method"
    end
  end
  -- Push every definition so nested helpers don't get attributed to an outer class
  stack[#stack + 1] = { indent = indent, name = name, class = is_container or false }
  if kind == "impl" then
    return false
  end

  local display = container and (container .. "." .. name) or name
  local col = text:find(name, indent + 1, true) or (indent + 1)
  return {
    text = display,
    name = display,
    bare = name:lower(),
    kind = kind,
    file = file,
    pos = { lnum, col - 1 },
    rank = path_rank(file),
  }
end

---@type snacks.picker.finder
function M.finder(opts, ctx)
  local args = {
    "--color=never",
    "--no-heading",
    "--with-filename",
    "--line-number",
    "--max-columns=300",
    "--pcre2",
    "-0",
    opts.hidden and "--hidden" or "--no-hidden",
  }
  if opts.ignored then
    args[#args + 1] = "--no-ignore"
  end
  for _, t in ipairs({ "py", "rust", "go", "ts", "js", "lua" }) do
    vim.list_extend(args, { "-t", t })
  end
  for _, g in ipairs({ ".git", "node_modules", "target", ".venv", "venv", "dist", "build", "__pycache__" }) do
    vim.list_extend(args, { "-g", "!" .. g })
  end
  for _, p in ipairs(rg_patterns) do
    vim.list_extend(args, { "-e", p })
  end

  local kinds = opts.kinds and {} or nil
  for _, k in ipairs(opts.kinds or {}) do
    kinds[k] = true
  end
  local cwd = opts.cwd
  local state = {}
  return require("snacks.picker.source.proc").proc(
    ctx:opts({
      cmd = "rg",
      args = args,
      notify = false,
      transform = function(item)
        local sep = item.text:find("\0", 1, true)
        if not sep then
          return false
        end
        local file = item.text:sub(1, sep - 1)
        local lnum, text = item.text:sub(sep + 1):match("^(%d+):(.*)$")
        if not lnum then
          return false
        end
        local parsed = M.parse(state, file, tonumber(lnum), text)
        if not parsed or (kinds and not kinds[parsed.kind]) then
          return false
        end
        parsed.cwd = cwd
        return parsed
      end,
    }),
    ctx
  )
end

-- Like PyCharm, a query that matches the symbol's own name beats one that only matches its container
-- (`parse` ranks `Parser.parse_expr` above `Parser.visit`). Queries containing `.` or spaces search qualified names.
local function in_order(haystack, needle)
  local pos = 1
  for i = 1, #needle do
    pos = haystack:find(needle:sub(i, i), pos, true)
    if not pos then
      return false
    end
    pos = pos + 1
  end
  return true
end

local function name_first_sort(get_pattern)
  local base = require("snacks.picker.sort").default({ fields = { "score:desc", "rank", "#text", "idx" } })
  local function hit(item, pattern)
    if item._hit_pattern ~= pattern then
      item._hit_pattern, item._hit = pattern, in_order(item.bare or "", pattern)
    end
    return item._hit
  end
  return function(a, b)
    local pattern = get_pattern()
    if pattern ~= "" and not pattern:find("[%s%.]") then
      local ha, hb = hit(a, pattern), hit(b, pattern)
      if ha ~= hb then
        return ha
      end
    end
    return base(a, b)
  end
end

---@param opts? snacks.picker.Config|{kinds?: string[]} `kinds` limits results to those LSP kind names
function M.pick(opts)
  local picker
  local function get_pattern()
    return picker and picker.matcher.pattern:lower() or ""
  end
  picker = Snacks.picker.pick(vim.tbl_extend("force", {
    title = "Symbols",
    finder = M.finder,
    format = "lsp_symbol",
    workspace = true,
    preview = "file",
    cwd = get_project_root(),
    matcher = { frecency = true },
    sort = name_first_sort(get_pattern),
  }, opts or {}))
  return picker
end

return M
