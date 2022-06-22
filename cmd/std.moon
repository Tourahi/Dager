----
-- Cmd functions

import gsub, sub, match from string
import concat from table
import flatten from require "Dager.utils.table"
import execute from os

log = assert require "Dager.utils.log"

specials =
  '\"': '\\\"'
  '\\': '\\\\'
  '\'': '\\\''
  '\n': '\\n'
  '\r': '\\r'
  '\t': '\\t'


--- Replaces a special char.
-- @tparam string c
replaceSpecial = (c) ->
  specials[c] or c

-- Escape special chars
escape = (arg) ->
  return arg if match arg, "^[a-zA-Z0-9_.-]+$"
  '"'..gsub(arg, "([\"\\\n\r\t])", replaceSpecial)..'"'

--- Concat args with spaces between them
-- @tparam table ...
cmdline = (...) ->
	concat [escape arg for arg in *flatten ...], ' '

--- Parses an arg string.(Can be verbose if LOGDEBUGPARSER is on)
-- @tparam string argsStr
parser = (argsStr) ->
  state = 'normal'

  current, cIdx = {}, 1
  args, aIdx = {}, 1

  c = nil
  i = 0

  parsing = true

  -- helpers
  add = ->
    current[cIdx], cIdx = c, cIdx + 1
  push = ->
    args[aIdx], aIdx, current, cIdx = (concat current), aIdx+1, {}, 1 if cIdx!=1
  addv = (v) ->
    current[cIdx], cIdx = v, cIdx + 1
  fail = (msg) ->
    error "failed to parse: #{msg} in state #{state} at pos #{i}", 2
  finish = ->
    parsing = false
  EOF = ''

  log.debugParser "argsStr : " .. argsStr

  while parsing
    i += 1
    c = sub argsStr, i, i

    switch state
      when 'normal'
        switch c

          when '\"'
            state = 'dQuote'
            log.debugParser "normal : dQuote"

          when '\''
            state = 'sQuote'
            log.debugParser "normal : sQuote"

          when ' '
            push!
            log.debugParser "normal : space"

          when '\n'
            push!
            log.debugParser "normal : '\\n'"

          when '\\'
            state = 'backslashnormal'
            log.debugParser "normal : backslashnormal"

          when EOF
            push!
            finish!
            log.debugParser "normal : EOF"

          else
            add!
            log.debugParser "normal : ELSE"


      when 'dQuote'
        switch c

          when '\"'
            state = 'normal'
            log.debugParser "dQuote : dQuote"

          when '\\'
            state = 'backslashdoublequote'
            log.debugParser "dQuote : backslashdoublequote"

          when EOF
            fail "unexpected EOF"
            print "mo"
            log.debugParser "dQuote : EOF"

          else
            add!
            log.debugParser "dQuote : ELSE"

      when 'sQuote'
        switch c

          when '\''
            state = 'normal'
            log.debugParser "sQuote : sQuote"

          when EOF
            fail "unexpected EOF"
            log.debugParser "sQuote : EOF"

          else
            add!
            log.debugParser "sQuote : ELSE"

      when 'backslashnormal'
        switch c

          when '\n'
            state = 'normal'
            log.debugParser "backslashnormal : '\\n'"

          when EOF
            fail "unexpected EOF"
            log.debugParser "backslashnormal : EOF"

          else
            add!
            state = "normal"
            log.debugParser "backslashnormal : ELSE"


      when 'backslashdoublequote'
        switch c

          when '$'
            add!
            state = 'dQuote'
            log.debugParser "backslashdoublequote : char $"

          when '`'
            add!
            state = 'dQuote'
            log.debugParser "backslashdoublequote : char `"

          when '\"'
            add!
            state = 'dQuote'
            log.debugParser "backslashdoublequote : dQuote"

          when '\\'
            add!
            state = 'dQuote'
            log.debugParser "backslashdoublequote : backslashdoublequote"

          when '\n'
            state = 'dQuote'
            log.debugParser "backslashdoublequote : '\\n'"


          when EOF
            fail "unexpected EOF"
            log.debugParser "backslashdoublequote : EOF"

          else
            addv '\\'
            add!
            state = 'dQuote'
            log.debugParser "backslashdoublequote : ELSE"

  args

--- Execute a command using lua's os.execute
-- @tparam string cmd
exe = (cmd) ->
  a, b, c = execute cmd
  if type a == 'boolean' then return a, b, c
  else
    a==0 or nil, 'exit', a

{ :escape, :cmdline, :parser, :exe }
