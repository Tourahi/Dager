----
-- Using lua's impl for cmd functions

import cmdline from assert require "Dager.cmd.std"
import first from assert require "Dager.utils.table"
import exe from assert require "Dager.cmd.std"
import popen from io
log = assert require "Dager.utils.log"


--- Passes command to be executed by an operating system shell.
-- @tparam table ... list of command <They will be seperated with spaces>
cmd = (...) ->
  ok, ret, code = exe cmdline ...
  error "command #{first ...} exited with #{code} (#{ret})" unless ok

--- Passes command to be executed by an operating system shell then returns the result.
-- @tparam table ... list of command <They will be seperated with spaces>
cmdResult = (...) ->
  fileHandle, err = popen cmdline ...
  error err unless fileHandle
  data = fileHandle\read '*a'
  fileHandle\close!
  data

--- Verbose version of cmd
sh = (cli) ->
  log.verbose -> print '[sh] ' .. cli
  ok, ret, code = exe cli
  error "command '#{cli}' exited with #{code} (#{ret})" unless ok


{
  :cmd
  :cmdResult
  :sh
}
