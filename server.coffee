# App timezone is UTC. This needs to be set before ANY Date() methods are called
# or it will be ignored
process.env.TZ = "EST"

# NODE_ENV
process.env.NODE_ENV ||= "development"


# Running this file fires up the Web server.
if module.id == "."
  Server = require("./server")
  Server.on "loaded", ->
    console.log "Server is READY!"
    if process.env.NODE_ENV == "development"
      # growl = require("growl").notify
      # growl "Restarted", title: "docs.dial800.com"
      # Jim really needs to buy me a Mac :|
      console.log("Leo does not have a Mac. Nothing to see here. Move along.")
 
  port = process.env.PORT || 8080

  Server.listen port
  return

require("sugar")

Express = require("express")

Coffee  = require("coffee-script")

eco = require("eco")

stylus = require("stylus")
nib = require("nib")
compileStylus = (str, path) ->
  console.log "COMPILING STYLUS"
  console.log path
  stylus(str).set('filename', path).set('compress', true).use(nib())

server = Express.createServer()

server.register ".eco", eco

FS = require("fs")

server = Express.createServer()
server.configure ->
  server.set "root", __dirname
  server.set "jsonp callback", true

  server.use Express.query()
  server.use Express.bodyParser()
  server.use Express.cookieParser()

  # Templates and views
  server.set "views", "#{__dirname}/app/views"
  server.set "view engine", "eco"
  server.set "view options"
    layout:  "layouts/default.eco"
    release:  new Date().toJSON()
    env:      server.settings.env


server.configure "development", ->
  process.on "uncaughtException", (error)->
    console.log "Caught exception: #{error}"
    console.log error.stack.split("\n")

  server.use Express.logger(buffer: false)
  if process.env.DEBUG
    server.use Express.profiler()
  server.error Express.errorHandler(dumpExceptions: true, showStack: true)

  # use Stylus
  server.use stylus.middleware
    src: "#{__dirname}/app"
    dest: "#{__dirname}/public"
    compile: compileStylus

  server.use server.router

  server.use Express.static "#{__dirname}/public"


server.configure "production", ->
  
  server.error Express.errorHandler()

  server.use Express.logger()
  server.use Express.responseTime()

  server.use server.router

  server.use Express.static "#{__dirname}/public", maxAge: 1000 * 60 * 60 * 24 * 14


server.on "listening", ->
  console.log "listening"

  FS.readdir "#{__dirname}/app/resources/", (error, files)->
    for file in files
      if /\.coffee$/.test(file)
        require "#{__dirname}/app/resources/#{file}"
    
    server.emit "loaded"

module.exports = server
