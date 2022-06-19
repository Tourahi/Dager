import concat from table

VERBOSE =  false -- verbose mode. default : false

import LOGDEBUGPARSER from assert require "Dager.utils.constants"

_tostring = tostring

-- Options
log = {}
_log = {}
log.stackLevel = 3
log.usecolor = true
log.outfile = nil
log.level = "trace"
log.ptf = false

modes = {
  { name: "trace", abr: 'T', color: "\27[34m" },
  { name: "debug", abr: 'D', color: "\27[36m" },
  { name: "info", abr: 'I',  color: "\27[32m" },
  { name: "warn", abr: 'W',  color: "\27[33m" },
  { name: "error", abr: 'E', color: "\27[31m" },
  { name: "fatal", abr: 'F', color: "\27[35m" },
}

abrNameMap = {
  T: "trace"
  D: "debug"
  I: "info"
  W: "warn"
  E: "error"
  F: "fatal"
}

levels = {}
for i, v in ipairs(modes) do levels[v.name] = i


log.verbose = (arg, level = "info") ->
  if #level == 1 then level = abrNameMap[level\upper!]
  if level == nil or #level == 0 then error "_.verbose invalid mog level."
  if arg == nil then return VERBOSE
  switch type arg
    when 'function' arg! if VERBOSE
    when 'boolean' VERBOSE = arg
    when 'string'
      if level
        _log[level] arg if VERBOSE
      else print arg if VERBOSE
    else error "_.verbose takes [no argument, a boolean, a function or a string]"


log.logFileName = (name) ->
  assert type(name) == 'string' and #name > 0, "File name is invalid."
  log.outfile = name or log.outfile


round = (x, increment) ->
  increment = increment or 1
  x = x / increment
  return (x > 0 and math.floor(x + .5) or math.ceil(x - .5)) * increment

tostring = (...) ->
  t = {}
  for i = 1, select('#', ...)
    x = select(i, ...)
    if type(x) == "number"
      x = round(x, .01)

    t[#t + 1] = _tostring(x)

  return table.concat(t, " ")

dump = (value) ->
  local _dump -- recursive func
  _dump = (val, depth) ->
    if depth == nil
      depth = 0

    v_t = type val
    if v_t == "string"
      return '"'.. val .. '"\n'
    elseif v_t == "table"
      depth = depth + 1
      local lines
      _lines = {}
      _len = 1
      for k, v in pairs(val)
        _lines[_len] = (" ")\rep(depth * 4) .. "[" .. tostring(k) .. "] = " .. _dump(v, depth)
        _len = _len + 1
      lines = _lines

      -- Moonscript Only
      local class_name
      if val.__call then
        class_name = "<" .. tostring(val.__class.__name) .. ">"

      return tostring(class_name or "") .. "{\n" .. concat(lines) .. (" ")\rep((depth - 1) * 4) .. "}\n"
    else
      return tostring(val) .. "\n"

  return _dump(value)


for i, x in ipairs(modes) do
  _log[x.name] = (...) ->

    -- Return early if we're below the log level
    if i < levels[log.level]
      return

    msg = tostring(...)
    info = debug.getinfo(log.stackLevel, "Sl")
    lineinfo = info.short_src .. ":" .. info.currentline

    print tostring(log.usecolor and "\27[0m") or ""
    -- Output to console
    print(string.format("%s[%-2s%s]%s %s: %s",
      log.usecolor and x.color or "",
      x.abr,
      os.date("%H:%M:%S"),
      log.usecolor and "\27[0m" or "",
      lineinfo,
      msg))

    if log.outfile
    -- Output to log file
      fp = io.open(log.outfile, "a")
      str = string.format("[%-6s%s] %s: %s\n",
        x.abr, os.date(), lineinfo, msg)
      fp\write(str)
      fp\close()

log.debugParser = (msg) ->
  if LOGDEBUGPARSER
    log.stackLevel = 4
    if VERBOSE == false then  log.verbose true
    if type(msg) == 'string'
      print log.verbose(msg, 'd')
    if type(msg) == 'table' then print log.verbose(log.dump(msg), 'd')
    VERBOSE = false
    log.stackLevel = 3

log.dump = dump -- Mostly for debugging purposes

log
