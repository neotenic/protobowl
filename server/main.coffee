console.log 'hello from protobowl v3'

express = require 'express'
fs = require 'fs'

app = express.createServer()
app.set 'views', "server" # directory where the jade files are
app.set 'view options', layout: false

io = require('socket.io').listen(app)

io.configure 'production', ->
	io.set "log level", 0
	io.set "browser client minification", true
	io.set "browser client gzip", true

io.configure 'development', ->
	io.set "log level", 2
	io.set "browser client minification", true
	io.set "browser client gzip", true

app.use require('less-middleware')({
	src: "assets/less",
	dest: "assets"
})

Snockets = require 'snockets'
CoffeeScript = require 'coffee-script'
Snockets.compilers.coffee = 
	match: /\.js$/
	compileSync: (sourcePath, source) ->
		CoffeeScript.compile source, {filename: sourcePath, bare: true}

snockets = new Snockets()
app.use (req, res, next) ->
	if req.url is '/app.js'
		snockets.getConcatenation 'client/app.coffee', (err, js) ->
			fs.writeFile 'assets/app.js', err || js, 'utf8', ->
				next()		
	# else if req.url is '/protobowl.css'
	# 	parser = new(less.Parser)({
	# 		paths: ['assets/less'],
	# 		filename: 'protobowl.less'
	# 	})
	# 	parser.parse
	else
		next()


app.use express.compress()
# app.use express.staticCache()
app.use express.static('assets')
app.use express.favicon('assets/img/favicon.ico')


Cookies = require 'cookies'
crypto = require 'crypto'

# simple helper function that hashes things
sha1 = (text) ->
	hash = crypto.createHash('sha1')
	hash.update(text)
	hash.digest('hex')

# inject the cookies into the session... yo
app.use (req, res, next) ->
	cookies = new Cookies(req, res)
	unless cookies.get 'protocookie'
		seed = "proto" + Math.random() + "bowl" + Math.random() + "client" + req.headers['user-agent']
		expire_date = new Date()
		expire_date.setFullYear expire_date.getFullYear() + 2
		cookies.set 'protocookie', sha1(seed), {
			expires: expire_date,
			httpOnly: false,
			signed: false,
			secure: false,
			path: '/'
		}
	next()


url = require 'url'
parseCookie = require('express/node_modules/connect').utils.parseCookie
rooms = {}
{QuizRoom} = require '../shared/room'
{QuizPlayer} = require '../shared/player'
names = require '../shared/names'
uptime_begin = +new Date

remote = require './remote'

class SocketQuizRoom extends QuizRoom
	emit: (name, data) ->
		console.log 'emitting shit', @name, name
		io.sockets.in(@name).emit name, data

	get_question: (cb) ->
		category = (if @category is 'custom' then @distribution else @category)
		remote.get_question @type, @difficulty, category, (question) =>
			cb(question || error_question)

	get_parameters: (type, difficulty, callback) -> remote.get_parameters(type, difficulty, callback)
	count_questions: (type, difficulty, category, cb) -> remote.count_questions(type, difficulty, category, cb) 


class SocketQuizPlayer extends QuizPlayer
	constructor: (room, id) ->
		super(room, id)
		@sockets = []
		@name = names.generateName()

	disco: (data) ->
		if data.old_socket and io.sockets.socket(data.old_socket)
			io.sockets.socket(data.old_socket).disconnect()

	active: -> @sockets.length > 0 and super()

	disconnect: ->
		super()
		console.log 'HANDLING A DISCONNECT'

		# room.del_socket publicID, sock.id
		


	add_socket: (sock) ->
		@sockets.push sock.id unless sock.id in @sockets
		blacklist = ['add_socket', 'emit']
		sock.emit 'log', 'moo'
		
		for attr of this when typeof this[attr] is 'function' and attr not in blacklist
			# wow this is a pretty mesed up line
			do (attr) => sock.on attr, (args...) => this[attr](args...)

	emit: (name, data) ->
		for sock in @sockets
			io.sockets.socket(sock).emit(name, data)

io.sockets.on 'connection', (sock) ->
	headers = sock.handshake.headers
	return sock.disconnect() unless headers.referer and headers.cookie
	config = url.parse(headers.referer)

	# if config.host isnt 'protobowl.com' and app.settings.env isnt 'development'
	# 	console.log "Sending Upgrade Request", headers.referer
	# 	config.host = 'protobowl.com'
	# 	sock.emit 'application_update', +new Date
	# 	sock.emit 'redirect', url.format(config)
	# 	sock.disconnect()
	# 	return

	cookie = parseCookie(headers.cookie)
	return sock.disconnect() unless cookie.protocookie and config.pathname
	# set the config stuff
	# is_god = /god/.test config.search
	# is_ninja = /ninja/.test config.search
	# configger the things which are derived from said parsed stuff
	room_name = config.pathname.replace(/\//g, '').toLowerCase()
	publicID = sha1(cookie.protocookie + room_name)
	
	# get the room
	rooms[room_name] = new SocketQuizRoom(room_name) unless rooms[room_name]
	room = rooms[room_name]

	# get the user's identity
	room.users[publicID] = new SocketQuizPlayer(room, publicID) unless room.users[publicID]
	user = room.users[publicID]
	user.add_socket sock
	sock.join room_name

	sock.emit 'joined', { id: user.id, name: user.name }
	

	# publicID = "__secret_ninja" if is_ninja
	# publicID += "_god" if is_god
	# create the room if it doesn't exist
	# rooms[room_name] = new QuizRoom(room_name) unless rooms[room_name]
	# room = rooms[room_name]

	# existing_user = (publicID of room.users)
	# if existing_user and room.users[publicID].banned
	# 	sock.emit 'redirect', "/#{room_name}-banned"
	# 	sock.disconnect()
	# 	return

	# room.add_socket publicID, sock.id
	# # actually join the room socket
	# if is_god
	# 	sock.join r_name for r_name of rooms
	# else
	# 	sock.join room_name
	# # look up this user in the room
	# user = room.users[publicID]
	# if is_ninja
	# 	user.ninja = true
	# 	user.name = publicID
	# # give the user a stupid name

	# tell that there's a new person at the partaay
	room.sync(3)

	
	user.verb 'joined the room'
	# room.emit 'log', {user: publicID, verb: 'joined the room'} # unless is_ninja
	# # detect if the server had been recently restarted
	# if new Date - uptime_begin < 1000 * 60 and existing_user
	# 	sock.emit 'log', {verb: 'The server has recently been restarted. Your scores may have been preserved in the journal (however, restoration is experimental and not necessarily reliable). The journal does not record the current question, chat messages, or current attempts, so you may need to manually advance a question. This may have been part of a server or client software update, or the result of an unexpected server crash. We apologize for any inconvienience this may have caused.'}
	# 	sock.emit 'application_update', +new Date # check for updates in case it was an update


app.get '/:channel', (req, res) ->
	name = req.params.channel
	res.render 'room.jade', { name }

app.get '/', (req, res) ->
	res.end 'welcome to protobowl v3 beta'

remote.initialize_remote()
port = process.env.PORT || 5555
app.listen port, ->
	console.log "listening on port", port