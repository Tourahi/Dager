import pcall from assert require "Dager.utils.pcall"



runWithContext = {}

runWithContext = if setfenv -- lua <= 5.1
  (func, ctx, ...) ->
    env = getfenv func
    setfenv func, ctx

    local data, ndata, ok

    check = (succ, ...) ->
      ok = succ
      if succ
        data = {...}
        ndata = select('#', ...)
      else
        data = ... -- in case of an error

    check pcall(func, ...)
    setfenv func, env

    if ok then unpack data, 1, ndata
    else error data

else
  import dump from string

  (func, ctx, ...) ->
    codeBin = dump func, false
    func = load codeBin, 'runWithContext', 'b', ctx
    func ...


{
  :runWithContext
}
