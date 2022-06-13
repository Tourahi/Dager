uTable = assert require "utils.table"
m = assert require 'moon'

Dump = m.p

tab = {
  1
  2
  3
  {88, 66}
  100
}


describe "flatten test.", ->

  flattenedTab = uTable.flatten tab

  it "Should have size of 6", ->
    assert.same 6, #flattenedTab

  it "Checks if the values are all strings", ->
    hasNonStringVal = false

    for k, v in pairs flattenedTab
      if type(v) != 'string' then hasNonStringVal = true

    assert.is_false hasNonStringVal


describe "getAt test.", ->
  pending "TODO!"

describe "first test.", ->
  pending "TODO!"

describe "min test.", ->
  pending "TODO!"

describe "max test.", ->
  pending "TODO!"

describe "looping test.", ->
  pending "TODO!"

describe "include\exclude test.", ->
  pending "TODO!"
