expect = require('chai').expect
request = require 'request'
path = require 'path'
async = require 'async'
Converter = require path.join(__dirname, '../lib/warp/server/Converter')

describe 'Converter', ->
  converter = new Converter

  # beforeEach ->
  #   warps = new WarpServer
  #     autoCloseClients: true
  #     showHeader: true
  #     enableClientLog: true
  #     port: 8800

  # afterEach ->
  #   warps.close()

  describe 'instance', ->
    # it 'should have properties', ->
    #   expect(warps).to.have.property 'autoCloseClients', true
    #   expect(warps).to.have.property 'showHeader', true
    #   expect(warps).to.have.property 'enableClientLog', true
    #   expect(warps).to.have.property 'port', 8800

    it 'should have methods', ->
      expect(converter).to.respondTo('convert')