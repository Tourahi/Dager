import gsub, sub, match from string
import concat from table
import flatten from require "Dager.utils.table"

specials =
	'\"': '\\\"'
	'\\': '\\\\'
	'\'': '\\\''
	'\n': '\\n'
	'\r': '\\r'
	'\t': '\\t'


replaceSpecial = (c) ->
  specials[c] or c

-- Escape special chars
escape = (arg) ->
  return arg if match arg, "^[a-zA-Z0-9_.-]+$"
  '"'..gsub(arg, "([\"\\\n\r\t])", replaceSpecial)..'"'

-- concat args with spaces between them
cmdline = (...) ->
	concat [escape arg for arg in *flatten ...], ' '

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

  while parsing
    i += 1
    c = sub argsStr, i, i

    switch state
      when 'normal'
        switch c

          when '\"'
            state = 'dQuote'

          when '\''
            state = 'sQuote'

          when ' '
            push!

          when '\n'
            push!

          when '\\'
            state = 'backslashnormal'

          when EOF
            push!
            finish!

          else
            add!

      when 'dQuote'
        switch c

          when '\"'
            state = 'normal'

          when '\\'
            state = 'backslashdoublequote'

          when EOF
            fail "unexpected EOF"

          else
            add!

      when 'sQuote'
        switch c

          when '\''
            state = 'normal'

          when EOF
            fail "unexpected EOF"

          else
            add!

      when 'backslashnormal'
        switch c

          when '\n'
            state = 'normal'

          when EOF
            fail "unexpected EOF"

          else
            add!
            state = "normal"


      when 'backslashdoublequote'
        switch c

          when '$'
            add!
            state = 'dQuote'

          when '`'
            add!
            state = 'dQuote'

          when '\"'
            add!
            state = 'dQuote'

          when '\\'
            add!
            state = 'dQuote'

          when '\n'
            state = 'dQuote'

          when EOF
            fail "unexpected EOF"

          else
            addv '\\'
            add!
            state = 'dQuote'

  args

{ :escape, :cmdline, :parser }
