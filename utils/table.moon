----
-- Functions to help with tables

import sort, concat from table

-- @local
_onlyNumKeys = (keys) ->
  for k in *keys
    if type(k) == 'string'
      error "Only numerically indexed tables are accepted."

--- Flattens numerically indexed tables.
-- @tparam table tab
-- @tparam any<lua data types> ...
flatten = (tab, ...) ->
  numberOfArgs = select '#', ...
  if numberOfArgs != 0 then return flatten {tab, ...}

  tp = type tab

  switch tp
    when 'nil'
      {}
    when 'string'
      {tab}
    when 'number'
      {tostring tab}
    when 'boolean'
      {tab}
    when 'table'
      keys = [k for k in pairs tab]
      _onlyNumKeys keys
      sort keys
      elems, i = {}, 1

      for k in *keys
        if type(k) == 'number'
          for e in *flatten( tab[k] )
            elems[i], i = e, i+1
        else
          return {tab}

      setmetatable elems, __tostring: => concat @, ' '
    else
      error "Elements of type #{tp} can't be flattened."




{ :flatten }
