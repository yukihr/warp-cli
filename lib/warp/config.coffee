fs = require 'fs'
merge = (orig, ext) ->
  for key, val in ext
    if typeof val of 'object'
      orig[key] = merge orig[key], val
    else
      orig[key] = val
  orig

CONFIG_PATH = '~/.warp/config.json'
DEFAULTS = {}

class Config
  constructor: () ->
    _config = JSON.parse fs.readFileSync CONFIG_PATH
    merge _config, DEFAULTS