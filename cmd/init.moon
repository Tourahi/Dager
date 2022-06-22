----
-- Cmd init (This is the file that should be included to use the cmd lib)

import parser, escape, cmdline from assert require "Dager.cmd.std"
import verbose from assert require "Dager.utils.log"


ok, cmd, backend = false, nil, nil

unless ok
  ok, cmd = pcall -> require "Dager.cmd.luaCmd"
  backend = 'lua'
error "unable to load any cmd library, tried {luaposix}" unless ok


-- from the backend
cmd = {k, v for k, v in pairs cmd}
cmd.backend = backend

cmd.parser = parser
cmd.escape = escape
_sh = cmd.sh

for f in *({'cmd', 'cmdrst', 'sh'})
  orig = cmd[f]
  if f == 3
    cmd[f] = (cli) ->
      verbose "[sh] #{cli}"
      _sh cli
  else
    cmd[f] = (...) ->
      verbose "[#{f}] #{cmdline ...}"
      orig ...


setmetatable cmd, __call: => {'cmd', 'cmdrst', 'sh'}
