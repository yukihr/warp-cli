expect = require('chai').expect
request = require 'request'
path = require 'path'
# async = require 'async'
WebSocket = require 'ws'
WarpServer = require path.join(__dirname, '../lib/warp/server')

port = 8800
httpUrl = "http://localhost:#{port}"
wsUrl = "ws://localhost:#{port}"

describe 'Warp Server instance', ->
  warps = null

  beforeEach ->
    warps = new WarpServer
      autoCloseClients: true
      showHeader: true
      enableClientLog: true
      port: 8800

  afterEach ->
    warps.close()

  describe 'instance', ->
    it 'should have properties', ->
      expect(warps).to.have.property 'autoCloseClients', true
      expect(warps).to.have.property 'showHeader', true
      expect(warps).to.have.property 'enableClientLog', true
      expect(warps).to.have.property 'port', 8800

    it 'should have methods', ->
      expect(warps).to.respondTo('close')
      expect(warps).to.respondTo('renderHtml')


describe 'Warp http server', ->
  warps = null

  beforeEach ->
    warps = new WarpServer
      port: 8800

  afterEach ->
    warps.close()

  describe 'GET /', ->
    it 'should respond with html', (done) ->
      request httpUrl, (err, res, body) ->
        expect(res.statusCode).to.eql 200
        expect(err).to.not.exist
        done()

  describe 'GET /eventemitter.js', ->
    it 'should respond with js', (done) ->
      request "#{httpUrl}/eventemitter.js", (err, res, body) ->
        expect(res.statusCode).to.eql 200
        expect(err).to.not.exist
        done()

  describe 'GET /websocketmessage.js', ->
    it 'should respond with js', (done) ->
      request "#{httpUrl}/message.js", (err, res, body) ->
        expect(res.statusCode).to.eql 200
        expect(err).to.not.exist
        done()

  describe 'GET /client.js', ->
    it 'should respond with js', (done) ->
      request "#{httpUrl}/client.js", (err, res, body) ->
        expect(res.statusCode).to.eql 200
        expect(err).to.not.exist
        done()

  describe 'GET /client.css', ->
    it 'should respond with css', (done) ->
      request "#{httpUrl}/client.css", (err, res, body) ->
        expect(res.statusCode).to.eql 200
        expect(err).to.not.exist
        done()


describe 'Warp web socket server', ->
  warps = null
  ws = null

  beforeEach ->
    warps = new WarpServer
      port: 8800
    ws = new WebSocket wsUrl

  afterEach ->
    warps.close()

  it 'should respond with open event', (done) ->
    ws.on 'open', () ->
      done()

  it 'should send command to client collectly', (done) ->
    ws.on 'open', () ->
      # send command to client after ready
      warps.message.command 'test', ['foo', 'bar', 'baz'],
        callback: (->)
    ws.on 'message', (data, flags) ->
      expect(data).to.be.eql '{"type":"command","data":{"name":"test","args":["foo","bar","baz"]},"callbackId":0}'
      done()

  it 'should notify to client collectly', (done) ->
    ws.on 'open', () ->
      warps.message.notify 'test', ['foo', 'bar', 'baz'],
        callback: (->)
    ws.on 'message', (data, flags) ->
      expect(data).to.be.eql '{"type":"notify","data":{"name":"test","data":["foo","bar","baz"]},"callbackId":0}'
      done()
