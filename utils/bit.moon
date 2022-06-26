loadstring = loadstring or load
import floor, ceil, pow from math


band = loadstring [[local a, b = ...; return a & b ]]
bor  = loadstring [[local a, b = ...; return a | b ]]
bxor = loadstring [[local a, b = ...; return a ~ b ]]
bnot = loadstring [[local a    = ...; return ~a    ]]
shl  = loadstring [[local a, b = ...; return a << b]]
shr  = loadstring [[local a, b = ...; return a >> b]]


unless band

  _isInt = (n) ->
    if n % 1 == 0
      n
    else
      error "N must be an int."

  -- Shift left
  _shl = (a, b) ->
    a * pow(2, b)

  -- Shift right
  _shr = (a, b) ->
    v = a / pow(2, b)
    if v < 0
      ceil v
    else
      floor v

  _l_shr = (v) ->
    v /= 2
    if v < 0
      ceil v
    else
      floor v

  _band = (a, b) ->
    v = 0
    n = 1

    for i = 0, 63
      if a % 2 == 1 and b % 2 == 1
        v += n
      if i != 63
        a = _l_shr a
        b = _l_shr b
        n *= 2
    v

  _bor = (a, b) ->
    v = 0
    n = 1

    for i = 0, 63
      if a % 2 == 1 or b % 2 == 1
        v += n
      if i != 63
        a = _l_shr a
        b = _l_shr b
        n *= 2
    v

  _bxor = (a, b) ->
    v = 0
    n = 1

    for i = 0, 63
      if a % 2 != b % 2
        v += n
      if i != 63
        a = _l_shr a
        b = _l_shr b
        n *= 2
    v

  _bnot = (a) ->
    v = 0
    n = 1

    for i = 0, 63
      if a % 2 == 0
        v += n
      if i != 63
        a = _l_shr a
        n *= 2
    v


  band = (a, b) -> _band (_isInt a), (_isInt b)
  bor = (a, b) -> _bor (_isInt a), (_isInt b)
  bxor = (a, b) -> _bxor (_isInt a), (_isInt b)
  bnot = (a, b) -> _bnot (_isInt a), (_isInt b)
  shl = (a, b) -> _shl (_isInt a), (_isInt b)
  shr = (a, b) -> _shr (_isInt a), (_isInt b)


{ :band, :bor, :bxor, :bnot, :shl, :shr }
