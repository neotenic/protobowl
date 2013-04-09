# Here's a basic static file server
# Really, we'd use something like S3 or Apache

console.log 'hello world from simple static server v1'

express = require 'express'
http = require 'http'
util = require 'util'


app = express()
server = http.Server(app)


app.use express.logger()

app.use express.favicon('static/img/favicon.ico')

app.get '/', (req, res) -> res.redirect '/lobby'

server.listen 5555, ->
	console.log "main listening on port 5555"

cdn = express()
cdnserve = http.Server(cdn)

cdn.use express.logger()
cdn.use express.static('static')

cdnserve.listen 5577, ->
	console.log "CDN listening on port 5577"