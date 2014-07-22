util  = require 'util'
spawn = require('child_process').spawn

exports.getPath = ->
  '/Users/Romain/Documents/dev/mocha-test-runner/node_modules/.bin/mocha'

exports.run = (testName, callback) ->

  console.log process.env
  folder = '/Users/Romain/Documents/dev/mocha-test-runner'
  binary = folder + '/node_modules/.bin/mocha'
  flags = ['--no-colors']
  if testName
    flags.push '--grep'
    flags.push testName
  opts =
    cwd: folder
    env: process.env

  mocha = spawn binary, flags, opts
  mocha.stdout.on 'data', (data) -> callback data.toString()
  mocha.stderr.on 'data', (data) -> callback data.toString()
  mocha.on 'exit', (code) -> console.log 'child process exited with code ' + code
