
import VERBOSE from assert require "Dager.utils.constants"
import concat from table

_tostring = tostring

-- Options
log = {}
log.usecolor = true
log.outfile = nil
log.level = "trace"
log.ptf = false

modes = {
  { name: "trace", color: "\27[34m", },
  { name: "debug", colot: "\27[36m", },
  { name: "info",  colot: "\27[32m", },
  { name: "warn",  colot: "\27[33m", },
  { name: "error", colot: "\27[31m", },
  { name: "fatal", colot: "\27[35m", },
}

levels = {}
for i, v in ipairs(modes) do levels[v.name] = i


log.verbose = (arg, level) ->
  if arg == nil then return VERBOSE
  switch type arg
    when 'function' arg! if VERBOSE
    when 'boolean' VERBOSE = arg
    when 'string' print arg if VERBOSE
    else error "_.logVerbose takes [no argument, a boolean, a function or a string]"


log.logFileName = (name) ->
  log.outfile = name or log.outfile


round = (x, increment) ->
  increment = increment or 1
  x = x / increment
  return (x > 0 and math.floor(x + .5) or math.ceil(x - .5)) * increment

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

log.dump = dump -- Mostly for debugging purposes

log
