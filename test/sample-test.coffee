
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

    it 'is successful\t\nwith\' []()"&%', ->
      assert(true)
