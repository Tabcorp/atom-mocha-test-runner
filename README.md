# Atom : Mocha test runner

[![License](http://img.shields.io/badge/license-MIT-yellow.svg?style=flat)](https://github.com/TabDigital/atom-mocha-test-runner/blob/master/LICENSE.md)

Runs [Mocha](https://github.com/visionmedia/mocha) unit tests from within Atom.

- `ctrl-alt-m` runs either
  - the current test file
  - or a single `it` / `describe` if the cursor is on that line

- `ctrl-alt-shift-m` re-runs the last test selection
  - even if you switched to another tab

![Demo](https://raw.github.com/TabDigital/atom-mocha-test-runner/master/demo.gif)

### Running mocha

This plugin looks for the closest `package.json` to the current file,
and run the corresponding `mocha`. This should automatically pick up the right version,
as well as your `mocha.opts` settings.

If you don't have a `package.json` file, or if Mocha isn't installed locally,
it will try to execute the global `mocha` command instead.

### How does it work?

To run the selected test, it uses `--grep` on the test name.
In the case the name isn't unique enough, it might run a few other tests.
In practice we found this is not an issue, and you still get fast TDD feedback loops.

### Settings

If you go to the settings pane, you can set the following values:

- `Node binary path`: path to the `node` executable (*defaults to `/usr/local/bin/node`*).
- `Text only`: remove any colors from the Mocha output (*defaults to `false`*)
- `Show debug information`: display extra information for troubleshooting (*defaults to `false`*)
