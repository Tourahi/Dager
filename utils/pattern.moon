----
-- Pattern functions

import match, sub from string

Table = assert require "Dager.utils.table"


--- Looks for a pattern using % ignores it and return the rest of the string.
-- @usage patget "test.moon",'%.moon' -- returns : test
-- @tparam String s
-- @tparam String pat
patget = (s, pat) ->
  prefix, suffix = match pat, '^(.*)%%(.*)$'
  print prefix, suffix
  return s==pat and s or nil unless prefix
  if (sub s, 1, #prefix)==prefix and (suffix == '' or (sub s, -#suffix)==suffix)
    sub s, #prefix+1, -#suffix-1
  else
    nil


--- Adds a prefix and/or a suffix to a string.
-- @usage patset "test",'more %s' -- returns : more tests
-- @tparam String s
-- @tparam String rep
patset = (s, rep) ->
	prefix, suffix = match rep, '^(.*)%%(.*)$'
	if prefix
		prefix..s..suffix
	else
		rep

--- Replace a part of a string with another string.
-- @usage patsubst "test.moon", '%.moon', '%.lua' -- returns : test.lua
-- @tparam String s
-- @tparam String pat
-- @tparam String rep
patsubst = (s, pat, rep) ->
	prefix, suffix = match pat, '^(.*)%%(.*)$'
	rprefix, rsuffix = match rep, '^(.*)%%(.*)$'

	t = type s
	f = false
	if t=='nil'
		return nil
	if t=='number'
		t = 'string'
		s = tostring s
	if t=='string'
		t = 'table'
		s = {s}
		f = true
	if t!='table'
		error "can't substitute patterns on type #{t}"

	r, i = {}, 1
	for s in *Table.flatten s
		if not prefix
			if s==pat
				if rprefix
					r[i], i = rprefix..s..rsuffix, i+1
				else
					r[i], i = rep, i+1
		elseif (sub s, 1, #prefix)==prefix and (suffix == '' or (sub s, -#suffix)==suffix)
			if rprefix
				r[i], i = rprefix..(sub s, #prefix+1, -#suffix-1)..rsuffix, i+1
			else
				r[i], i = rep, i+1

	f and r[1] or r

{ :patget, :patset, :patsubst }
