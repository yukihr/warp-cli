# global: Message:false
# Utils
$id = ()->
  document.getElementById.apply(document, arguments)

$cls = ()->
  document.getElementsByClassName.apply(document, arguments)

class Deferred
  nop = (->)
  constructor: ->
    @_stack = []
  wait: (fn) ->
    @_stack.push nop
    fn @_done
    @
  _done: =>
    @_stack.pop()()
  then: (fn) ->
    @_stack.unshift fn
    @_stack.pop()()
    @


# Handlers
message = new Message

handleCommand = (command, frame) ->
  console.log command.name
  fdoc = frame.contentDocument
  switch command.name
    when "reload"
      frame.src = frame.src
    when "load", "url"
      frame.src = command.args
      $id("loaded-url").value = command.args
    when "renderHtml"
      console.log "renderHtml"
      fdoc.documentElement.innerHTML = command.args
      document.title = frame.contentDocument.title
    when "scroll"
      point = command.data.split(" ")
      inTop = parseInt(point[0], 10)
      inOffset = parseInt(point[1], 10)
      inScreen = parseInt(point[2], 10)
      docHeight = fdoc.documentElement.scrollHeight or fdoc.body.scrollHeight
      screen = fdoc.documentElement.clientHeight / docHeight * 100
      top = (fdoc.documentElement.scrollTop or fdoc.body.scrollTop) / docHeight * 100
      screenDelta = inScreen - screen

      # = Length to Window Top
      # Positive when browser screen is narrow than editor
      # = Hidden Screen Height
      scrollTo = (inTop * docHeight / 100) + ((if screenDelta >= 0 then screenDelta else 0)) * docHeight / 100 * inOffset / 100
      frame.contentWindow.scrollTo 0, scrollTo
    else
      message.notify 'error', "Unknown command: #{command.name}"

handleNotify = (notify) ->
  switch notify.name
    when "clientId"
      $id("client-id").textContent = notify.data
    when "test"
      false
    else
      message.notify 'error', "Unknown notify: #{notify.name}"


# Start up
soc = new WebSocket("ws://" + location.host + "/", "warp")
message.addSocket soc
frame = null
dfd = new Deferred

dfd
  .wait (done)->
    message.on 'prepared', (id)->
      done()
  .wait (done)->
    document.addEventListener "DOMContentLoaded", ->
      # On Firefox, have to wait loading of iframe,
      # because doc will have reference to empty content before load.
      frame = $id("warp-frame")
      frame.onload = ->
        done()
        frame.onload = (->)
  .then ->
    message.on 'command', (cmd, id, done) ->
      handleCommand cmd, frame
      done()
    message.on 'notify', (notify, id, done) ->
      handleNotify notify
      done()
    message.notify 'status', 'start'

soc.onclose = ->
  #if(#{@autoCloseClients}) { window.open('', '_self', ''); window.close(); }
  $id("closed-screen").setAttribute "style", "display:block;"
