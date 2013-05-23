if typeof require is 'function'
  EventEmitter = require('events').EventEmitter
else
  EventEmitter = window.EventEmitter

class Message extends EventEmitter
  constructor: ->
    @socketId = 0
    @sockets = []
    @callbackId = 0
    @callbacks = []

  addSocket: (socket) ->
    id = @socketId++ # Make internal reference for socket id
    @sockets[id] = socket
    if typeof socket.on is 'function' # Node's EventEmitter
      socket.on 'open', () =>
        @_onOpen id
      socket.on 'message', (message) =>
        @_onMessage JSON.parse(message), id
      socket.on 'close', () =>
        @_removeSocket id
        @_onClose id
    else # Browsers' WebSocket
      socket.onopen = () =>
        @_onOpen id
      socket.onmessage = (msg) =>
        @_onMessage JSON.parse(msg.data), id
      socket.onclose = () =>
        @_removeSocket id
        @_onClose id

  _removeSocket: (id) ->
    delete @sockets[id]

  _onOpen: (id) ->
    @emit 'prepared', id

  _onMessage: (message, socketId) ->
    done = (->)
    if typeof message.callbackId is 'number'
      cid = message.callbackId
      done = () =>
        @command 'callback', cid #TODO

    switch message.type
      when 'notify'
        @emit 'notify', message.data, socketId, done
      when 'command'
        if message.data.name is 'callback'
          @_execCallback message.data.args
        else
          @emit 'command', message.data, socketId, done
      else
        throw "Unknown message type: #{message.type}, from socket: #{socketId}"

  _onClose: (id) ->
    @emit 'close', id

  _sendWebSocketMessage: (msg, id) =>
    if id
      @sockets[id].send (JSON.stringify msg)
    else
      for id, socket of @sockets
        socket.send (JSON.stringify msg)

  send: (type, data, options = {}) =>
    cid = null
    if options.callback
      cid = @callbackId++
      @callbacks[cid] = options.callback

    @_sendWebSocketMessage
      type: type
      data: data
      callbackId: cid,
        options.socketId

  command: (command, args, options = {}) =>
    @send 'command',
      name: command
      args: args
      , options

  notify: (name, data, options = {}) =>
    @send 'notify',
      name: name
      data: data
      , options

  _execCallback: (callbackId) ->
    cid = callbackId
    cb = @callbacks[cid]
    cb() if cb
    delete @callbacks[cid]

  resendLastCommand: ->
    #TODO

# exports
if typeof window is "undefined"
  module.exports = Message
else
  window.Message = Message