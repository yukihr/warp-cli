module.exports = class MessageListener
  constructor: (options = {}) ->
    @server = options.server
    @message = options.message
    @server.on 'connection', (webSocket) =>
      @message.addSocket webSocket
      # @message.on 'command', (command, id) ->
      @message.on 'notify', (notify, id) =>
        console.log "client_#{id}_#{notify.name}:#{notify.data}"
        if notify.name is 'status'
          if notify.data is 'start'
            @message.notify 'clientId', id,
              socketId: id

      @message.on 'close', (id) =>
        console.log "client_#{id}_status:closed"
