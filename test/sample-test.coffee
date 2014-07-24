
assert = require 'assert'

describe 'Top level describe', ->

  describe 'Nested describe', ->

    it 'is successful', ->
      assert(true)

    it 'fails', ->
      assert(false)

  describe 'Other nested', ->

    it 'is also successful', ->
      assert(true)

    it 'is successful with [square brackets]', ->
      assert(true)

    it 'is successful with (parentheses)', ->
      assert(true)
