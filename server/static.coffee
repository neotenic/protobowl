# Here's a basic static file server
# Really, we'd use something like S3 or Apache

console.log 'hello world from simple static server v2'

process.chdir(__dirname + '/../')

express = require 'express'
http = require 'http'
util = require 'util'
fs = require 'fs'

app = express()
server = http.Server(app)


app.use express.logger()
app.engine 'html', (path, options, callback) ->
	fs.readFile path, 'utf8', callback

app.set("view options", {layout: false})
app.set("views", "")
app.use express.static('debug')

app.get '/', (req, res) -> res.redirect '/lobby'

app.get '/:name', (req, res) -> 
	res.render 'debug/app.html'
	

server.listen 5555, ->
	console.log "main listening on port 5555"
