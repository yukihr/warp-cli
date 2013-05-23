require 'coffee-script'
http = require 'http'
path = require 'path'
WebSocketServer = new require('ws').Server
HttpHandlers = require path.join __dirname, 'server/HttpHandlers'
Message = require path.join __dirname, 'common/Message'
MessageListener = require path.join __dirname, 'server/MessageListener'
Converter = require path.join __dirname, 'server/Converter'

PORT = 8800

module.exports = class Server
  constructor: (options = {}) ->
    @port = options.port or PORT
    @autoCloseClients = options.autoCloseClients or true
    @showHeader = options.showHeader or true
    @enableClientLog = options.enableClientLog or true

    @httpServer = http.createServer()
    @httpServer.on 'request', (req, res) ->
      try
        HttpHandlers.client req, res
      catch e
        try
          HttpHandlers.static req, res
        catch e
          console.log e
    @httpServer.listen @port

    @wss = new WebSocketServer
      server: @httpServer
    @message = new Message
    new MessageListener
      server: @wss
      message: @message

    @converter = new Converter

  close: ->
    @httpServer.close()
    @wss.close()

  renderHtml: (filename, content) ->
    html = @converter.convert filename, content
    @message.command 'renderHtml', html
