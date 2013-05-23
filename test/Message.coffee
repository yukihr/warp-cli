expect = require('chai').expect
request = require 'request'
path = require 'path'
async = require 'async'
WebSocket = require 'ws'
WebSocketServer = require('ws').Server
Message = require path.join(__dirname, '../lib/warp/common/Message')
port = 8800
wsUrl = "ws://localhost:#{port}"

describe 'Message', ->
  describe 'instance', ->
    it 'should have methods', ->
      msg = new Message
      ['addSocket', 'on'
       'send', 'command', 'notify'].forEach (method) ->
        expect(msg).to.respondTo(method)

  describe '#addSocket', ->
    it 'should increase number of @sockets', (done) ->
      msg = new Message
      wss = new WebSocketServer
        port: port
      ws = new WebSocket wsUrl
      wss.on 'connection', (_ws) ->
        msg.addSocket ws
        expect(msg.sockets.length).to.be.eql 1
        wss.close()
        done()

  describe '#on', ->
    it 'should register event listeners on client sockets', (done) ->
      cmsg = new Message
      smsg = new Message
      wss = new WebSocketServer
        port: port
      ws = new WebSocket wsUrl
      cmsg.addSocket ws
      cmsg.on 'command', (command, id, _done) ->
        expect(command.name).to.be.eql 'test'
        expect(command.args).to.be.eql 'args'
        expect(id).to.be.eql 0
        expect(typeof _done).to.be.eql 'function'
        done()
      wss.on 'connection', (_ws) ->
        smsg.addSocket _ws
        smsg.command 'test', 'args'
        wss.close()

    it 'should register event listeners on server sockets', (done) ->
      cmsg = new Message
      smsg = new Message
      wss = new WebSocketServer
        port: port
      ws = new WebSocket wsUrl
      cmsg.addSocket ws
      cmsg.on 'prepared', (id) ->
        cmsg.command 'test', 'args'
      wss.on 'connection', (_ws) ->
        smsg.addSocket _ws
      smsg.on 'command', (command, id, _done) ->
        expect(command.name).to.be.eql 'test'
        expect(command.args).to.be.eql 'args'
        expect(id).to.be.eql 0
        expect(typeof _done).to.be.eql 'function'
        done()
        wss.close()

  describe 'callback', ->
    it 'should be correctly fired', (done) ->
      cmsg = new Message
      smsg = new Message
      wss = new WebSocketServer
        port: port
      ws = new WebSocket wsUrl
      cmsg.addSocket ws
      cmsg.on 'command', (command, id, _done) ->
        # expect(command.name).to.be.eql 'test'
        # expect(command.args).to.be.eql 'args'
        # expect(id).to.be.eql 0
        # expect(typeof _done).to.be.eql 'function'
        _done()
      wss.on 'connection', (_ws) ->
        smsg.addSocket _ws
        smsg.command 'test', 'args'
          callback: () ->
            done()
            wss.close()
