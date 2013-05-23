expect = require('chai').expect
path = require 'path'
phantom = require 'phantom'
WebSocket = require 'ws'
WarpServer = require path.join(__dirname, '../lib/warp/server')

openUrl = (url, callback) ->
  phantom.create (ph) ->
    ph.createPage (page) ->
      page.open url, (status) ->
        callback
          phantom: ph
          page: page
          status: status

port = 8800
clientUrl = "http://localhost:#{port}"
openClient = (callback) ->
  openUrl clientUrl, (res) ->
    callback res


describe 'Warp', ->
  warps = null

  beforeEach ->
    warps = new WarpServer
      port: port

  afterEach ->
    warps.close()

  it 'should be correct html', (done) ->
    openClient (res) ->
      res.page.evaluate (-> document.title), (result) ->
        expect(result).to.be.eql 'warp'
        res.phantom.exit()
        done()

  it 'should notify clientId', (done) ->
    warps.message.on 'notify', (notify) ->
      if notify.name is 'status'
        openClient (res) ->
          res.page.evaluate () ->
            document.getElementById('client-id').textContent
          , (result) ->
            # expect(result).to.be.eql '0'
            res.phantom.exit()
            done()

  it 'client should handle command renderHtml', (done) ->
    openClient (res) ->
      warps.message.command 'renderHtml',
        '''
<html>
  <head>
    <title>Test</title>
  </head>
  <body>
  </body>
</html>
        '''
        callback: ->
          res.page.evaluate (-> document.title), (result) ->
            expect(result).to.be.eql 'Test'
            res.phantom.exit()
            done()
