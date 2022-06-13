----
-- Functions to help with tables

import sort, concat from table
import huge from math


-- @local
_isTable = (tab) ->
  return type(tab) == 'table'

-- @local
_isNumber = (n) ->
  return type(n) == 'number'

-- @local
_tabMinIdx = (tab) ->
  min = huge
  for k in pairs tab
    if type(k) == 'string'
      error "Only numerically indexed tables are accepted."
    if (type k) == 'number'
      min = k if k < min
    else
      return tab
  return min


--- Flattens numerically indexed tables.
-- @tparam table tab
-- @tparam table ...
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
      sort keys
      elems, i = {}, 1

      for k in *keys
        if type(k) == 'string'
          error "Only numerically indexed tables are accepted."
        if type(k) == 'number'
          for e in *flatten( tab[k] )
            elems[i], i = e, i+1
        else
          return {tab}

      setmetatable elems, __tostring: => concat @, ' '
    else
      error "Elements of type #{tp} can't be flattened."


--- Get value at given i or key and perform and send it to a callback if provided
-- @tparam table tab
-- @tparam (number/string) i
-- @tparam function cb
getAt = (tab, i, cb = nil) ->
  if _isTable tab
    if tab[i] == nil then return nil

    if cb then return cb tab[i]
    else return tab[i]

  error "Only tables are accepted."


--- Get the first value of a table taken into account subtables
-- @tparam table tab
-- @tparam table ...
first = (tab, ...) ->
  tp = type tab

  switch tp
    when 'nil'
      if select('#', ...) == 0
        nil
      else
        first ...
    when 'string'
      tab
    when 'number'
      tostring tab
    when 'boolean'
      tab
    when 'table'
      first tab[_tabMinIdx(tab)]
    else
      error "can't find first of type #{tp}."


--- Get the min value of a table subtables are not considered
-- @tparam table tab
min = (tab) ->
  if _isTable tab
    _min = tab[1]
    for i = 2, #tab
      elem = tab[i]
      if _isNumber(elem) and not _isTable(elem)
        _min = elem if elem < _min
    return _min
  error "Only tables are accepted."


--- Get the max value of a table subtables are not considered
-- @tparam table tab
max = (tab) ->
  if _isTable tab
    _max = tab[1]
    for i = 2, #tab
      elem = tab[i]
      if _isNumber(elem) and not _isTable(elem)
        _max = elem if elem > _max
    return _max
  error "Only tables are accepted."

--- Loop and run the callback for every element
-- @tparam table tab
-- @tparam function cb
foreach = (tab, cb) ->
  [cb v for v in *flatten tab]


--- Filter a table using the given filter
-- @tparam table tab
-- @tparam function f
filter = (tab, f) ->
  [v for v in *flatten tab when f v]


--- Test if the table includes(contains) the given value
-- @tparam table tab
-- @tparam function f
has = (tab, v) ->
  return true if tab == v
  if type(tab) == 'table'
    for k, e in pairs tab
      if type(k) == 'number'
        return true if has e, v
  if type(tab) == 'number'
    return tostring(tab) == tostring(v)
  false

includes = has
contains = has

--- Excludes the given values from the table
-- @tparam table tab
-- @tparam table ...
exclude = (tab, ...) ->
  exclusions = flatten ...
  [v for v in *flatten tab when not includes exclusions, v]

{
  :flatten
  :getAt
  :first
  :min
  :max
  :foreach
  :filter
  :has, :includes, :contains
  :exclude
}
