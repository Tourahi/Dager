import match, sub from string


patget = (s, pat) ->
	prefix, suffix = match pat, '^(.*)%%(.*)$'
	return s==pat and s or nil unless prefix
	if (sub s, 1, #prefix)==prefix and (suffix == '' or (sub s, -#suffix)==suffix)
		sub s, #prefix+1, -#suffix-1
	else
		nil


patset = (s, rep) ->
	prefix, suffix = match rep, '^(.*)%%(.*)$'
	if prefix
		prefix..s..suffix
	else
		rep

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
	for s in *flatten s
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
