url = require 'url'
path = require 'path'
fs = require 'fs'
coffeeScript = require 'coffee-script'

module.exports = class HttpHandlers
  @clientRoot = path.join __dirname, "../client"
  @static: (req, res) ->
    p = path.join process.cwd(), url.parse(req.url).path
    ext = path.extname p

    _exists = fs.exists or path.exists

    _exists p, (exists) =>
      unless exists
        res.writeHead 404, 'Content-Type': 'text/plain'
        res.write '404 Not Found\n'
        res.end()
        throw 'Requested file is not found.'
        return

      # Suppress Chattering Display
      res.setHeader "Cache-Control", "max-age=100"

      fs.readFile p, 'binary', (err, file) =>
        if err
          res.writeHead 500, 'Content-Type': 'text/plain'
          res.write err + "\n"
          res.end()
          return

        switch ext.substr 1
          when 'png'
            res.writeHead 200, 'Content-Type': 'image/png'
          when 'gif'
            res.writeHead 200, 'Content-Type': 'image/gif'
          when 'jpg', 'jpeg'
            res.writeHead 200, 'Content-Type': 'image/jpeg'
          when 'html', 'htm'
            res.writeHead 200, 'Content-Type': 'text/html'
          when 'js'
            res.writeHead 200, 'Content-Type': 'text/javascript'
          when 'css'
            res.writeHead 200, 'Content-Type': 'text/css'
          when 'swf', 'swfl'
            res.writeHead 200, 'Content-Type': 'application/x-shockwave-flash'
          else
            res.writeHead 200, 'Content-Type': 'text/plain'

        res.write file, 'binary'
        res.end()

  @setClientRoot: (path) ->
    @clientRoot = path

  @client: (req, res) ->
    switch url.parse(req.url).path
      when '/'
        res.writeHead 200, 'Content-Type': 'text/html'
        res.write fs.readFileSync(@clientRoot + '/index.html'), 'utf-8'
        res.end()
      when '/content.html'
        res.writeHead 200, 'Content-Type': 'text/html'
        res.write fs.readFileSync(@clientRoot + '/content.html'), 'utf-8'
        res.end()
      when '/eventemitter.js'
        res.writeHead 200, 'Content-Type': 'text/javascript'
        res.write fs.readFileSync(@clientRoot + '/EventEmitter.js'), 'utf-8'
        res.end()
      when '/message.js'
        res.writeHead 200, 'Content-Type': 'text/javascript'
        res.write coffeeScript.compile(fs.readFileSync(path.join(__dirname, '../common/Message.coffee'), 'ascii')), 'utf-8'
        res.end()
      when '/client.js'
        res.writeHead 200, 'Content-Type': 'text/javascript'
        res.write coffeeScript.compile(fs.readFileSync(@clientRoot + '/client.coffee', 'ascii')), 'utf-8'
        res.end()
      when '/client.css'
        res.writeHead 200, 'Content-Type': 'text/css'
        res.write fs.readFileSync(@clientRoot + '/client.css'), 'utf-8'
        res.end()
      else
        throw 'Client not routed.'