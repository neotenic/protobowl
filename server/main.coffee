console.log 'hello from protobowl v3', __dirname, process.cwd()
express = require 'express'
fs = require 'fs'
url = require 'url'
parseCookie = require('express/node_modules/connect').utils.parseCookie
rooms = {}
{QuizRoom} = require '../shared/room'
{QuizPlayer} = require '../shared/player'
{checkAnswer} = require '../shared/answerparse'

names = require '../shared/names'
uptime_begin = +new Date

try 
	remote = require './remote'
catch err
	questions = []
	count = 0
	fs.readFile 'assets/sample.txt', 'utf8', (err, data) ->
		throw err if err
		questions = (JSON.parse(line) for line in data.split("\n"))

	listProps = (prop) ->
		propmap = {}
		for q in questions
			propmap[q[prop]] = 1
		return (p for p of propmap)

	filterQuestions = (diff, cat) ->
		questions.filter (q) ->
			return false if diff and q.difficulty != diff
			return false if cat and q.category != cat
			return true

	fisher_yates = (i) ->
		return [] if i is 0
		arr = [0...i]
		while --i
			j = Math.floor(Math.random() * (i+1))
			[arr[i], arr[j]] = [arr[j], arr[i]] 
		arr
	current_category = ''
	current_difficulty = ''
	current_queue = []

	remote = {
		initialize_remote: (cb) -> 
			cb() if cb
		get_question: (type, diff, cat, cb) ->
			if diff == current_difficulty and cat == current_category and current_queue.length > 0
				cb current_queue.shift()
			else
				current_difficulty = diff
				current_category = cat
				temp_filtered = filterQuestions(diff, cat)
				current_queue = (temp_filtered[index] for index in fisher_yates(temp_filtered.length))
				cb current_queue.shift()
		
		get_parameters: (type, difficulty, cb) ->
			cb listProps('difficulty'), listProps('category')

		count_questions: (type, diff, cat, cb) ->
			cb filterQuestions(diff, cat).length
	}

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


journal_config = { host: 'localhost', port: 15865 }
log_config = { host: 'localhost', port: 18228 }

if app.settings.env is 'production' and remote.deploy
	log_config = remote.deploy.log
	journal_config = remote.deploy.journal
	console.log 'set to deployment defaults'

if app.settings.env is 'development'
	app.use require('less-middleware')({
		src: "assets/less",
		dest: "assets",
		compress: true
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
		else if req.url is '/offline.js'
			snockets.getConcatenation 'client/offline.coffee', (err, js) ->
				fs.writeFile 'assets/offline.js', err || js, 'utf8', ->
					next()
		# else if req.url is '/protobowl.css'
		# 	parser = new(less.Parser)({
		# 		paths: ['assets/less'],
		# 		filename: 'protobowl.less'
		# 	})
		# 	parser.parse
		else
			next()

	scheduledUpdate = null
	updateCache = ->
		fs.readFile 'assets/protobowl.appcache', 'utf8', (err, data) ->
			throw err if err
			data = data.replace(/INSERT_DATE.*?\n/, 'INSERT_DATE '+(new Date).toString() + "\n")
			fs.writeFile 'assets/protobowl.appcache', data, (err) ->
				throw err if err
				setTimeout ->
					io.sockets.emit 'force_application_update', +new Date
				, 2000
				scheduledUpdate = null

	watcher = (event, filename) ->
		return if filename in ["protobowl.appcache", "protobowl.css", "app.js"]
		console.log "changed file", filename
		unless scheduledUpdate
			scheduledUpdate = setTimeout updateCache, 500

	fs.watch "shared", watcher
	fs.watch "client", watcher

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

app.use (req, res, next) ->
	if req.headers.host isnt "protobowl.com" and app.settings.env isnt 'development'
		options = url.parse(req.url)
		options.host = 'protobowl.com'
		res.writeHead 301, {Location: url.format(options)}
		res.end()
	else
		next()

	

http = require('http')
log = (action, obj) ->
	req = http.request log_config, ->
		# console.log "saved log"
	req.on 'error', ->
		console.log "logging error"
	req.write((+new Date) + ' ' + action + ' ' + JSON.stringify(obj) + '\n')
	req.end()

log 'server_restart', {}



class SocketQuizRoom extends QuizRoom
	emit: (name, data) ->
		io.sockets.in(@name).emit name, data

	check_answer: (attempt, answer, question) -> checkAnswer(attempt, answer, question) 

	get_question: (cb) ->
		category = (if @category is 'custom' then @distribution else @category)
		remote.get_question @type, @difficulty, category, (question) =>
			cb(question || error_question)

	get_parameters: (type, difficulty, callback) -> remote.get_parameters(type, difficulty, callback)

	count_questions: (type, difficulty, category, cb) -> remote.count_questions(type, difficulty, category, cb) 

	journal: -> journal_queue[@name] = +new Date

class SocketQuizPlayer extends QuizPlayer
	constructor: (room, id) ->
		super(room, id)
		@sockets = []
		@name = names.generateName()

	disco: (data) ->
		if data.old_socket and io.sockets.socket(data.old_socket)
			io.sockets.socket(data.old_socket).disconnect()

	online: -> @sockets.length > 0

	report_question: (data) ->
		return unless data
		data.room = @room.name
		data.user = @id + '-' + @name
		remote.handle_report data if remote.handle_report
		log 'report_question', data

	report_answer: (data) ->
		return unless data
		data.room = @room.name
		data.user = @id + '-' + @name
		log 'report_answer', data


	check_public: (_, fn) ->
		output = {}
		checklist = ['hsquizbowl', 'lobby']
		for check_name in checklist
			output[check_name] = 0
			if rooms[check_name]?.users
				for uid, udat of rooms[check_name].users
					output[check_name]++ if udat.active()
		fn output

	add_socket: (sock) ->
		@sockets.push sock.id unless sock.id in @sockets
		blacklist = ['add_socket', 'emit', 'disconnect']
		
		for attr of this when typeof this[attr] is 'function' and attr not in blacklist
			# wow this is a pretty mesed up line
			do (attr) => sock.on attr, (args...) => this[attr](args...)

		id = sock.id

		@room.journal()

		sock.on 'disconnect', =>
			@sockets = (s for s in @sockets when s isnt id)
			@disconnect()
			@room.journal()

	emit: (name, data) ->
		for sock in @sockets
			io.sockets.socket(sock).emit(name, data)

io.sockets.on 'connection', (sock) ->
	headers = sock.handshake.headers
	return sock.disconnect() unless headers.referer and headers.cookie
	config = url.parse(headers.referer)

	if config.host isnt 'protobowl.com' and app.settings.env isnt 'development'
		config.host = 'protobowl.com'
		sock.emit 'application_update', +new Date
		sock.emit 'redirect', url.format(config)
		sock.disconnect()
		return

	cookie = parseCookie(headers.cookie)
	return sock.disconnect() unless cookie.protocookie and config.pathname
	# set the config stuff
	is_god = /god/.test config.search
	is_ninja = /ninja/.test config.search
	# configger the things which are derived from said parsed stuff
	room_name = config.pathname.replace(/\//g, '').toLowerCase()
	publicID = sha1(cookie.protocookie + room_name)

	publicID = "__secret_ninja" if is_ninja
	publicID += "_god" if is_god
	
	# get the room
	rooms[room_name] = new SocketQuizRoom(room_name) unless rooms[room_name]
	room = rooms[room_name]

	# get the user's identity
	existing_user = (publicID of room.users)
	room.users[publicID] = new SocketQuizPlayer(room, publicID) unless room.users[publicID]
	user = room.users[publicID]
	if user.banned
		sock.emit 'redirect', "/#{room_name}-banned"
		sock.disconnect()
		return
	user.name = 'secret ninja' if is_ninja
	
	user.add_socket sock
	sock.join room_name

	sock.emit 'joined', { id: user.id, name: user.name }
	
	# tell that there's a new person at the partaay
	room.sync(3)

	user.verb 'joined the room'
	
	# # detect if the server had been recently restarted
	if new Date - uptime_begin < 1000 * 60 and existing_user
		sock.emit 'log', {verb: 'The server has recently been restarted. Your scores may have been preserved in the journal (however, restoration is experimental and not necessarily reliable). The journal does not record the current question, chat messages, or current attempts, so you may need to manually advance a question. This may have been part of a server or client software update, or the result of an unexpected server crash. We apologize for any inconvienience this may have caused.'}
		sock.emit 'application_update', +new Date # check for updates in case it was an update


journal_queue = {}

process_journal_queue = ->
	room_names = Object.keys(journal_queue).sort (a, b) -> journal_queue[a] - journal_queue[b]
	return if room_names.length is 0
	first = room_names[0]
	delete journal_queue[first]
	if first of rooms
		partial_journal first

setInterval process_journal_queue, 1000

partial_journal = (name) ->
	journal_config.path = '/journal'
	journal_config.method = 'POST'
	req = http.request journal_config, (res) ->
		res.setEncoding 'utf8'
		# console.log "committed journal for", name
		res.on 'data', (chunk) ->
			if chunk == 'do_full_sync'
				console.log 'got trigger for doing a full journal sync'
				journal_queue = {} # full syncs clear queue
				full_journal_sync()
	req.on 'error', ->
		# console.log "journal error"
	req.write(JSON.stringify(rooms[name].journal_export()))
	req.end()

full_journal_sync = ->
	backup = for name, room of rooms
		room.journal_export()
	journal_config.path = '/full_sync'
	journal_config.method = 'POST'
	req = http.request journal_config, (res) ->
		# console.log "done full sync"
		log 'log', 'completed full sync'
	req.on 'error', ->
		log 'error', 'full sync error'
	req.write(JSON.stringify(backup))
	req.end()

rooms = {}

# this is actually really quite hacky

restore_journal = (callback) ->
	journal_config.path = '/retrieve'
	journal_config.method = 'GET'
	req = http.request journal_config, (res) ->
		console.log 'GOT JOURNAL RESPONSE'
		res.setEncoding 'utf8'
		packet = ''
		res.on 'data', (chunk) ->
			packet += chunk
		res.on 'end', ->
			console.log "GOT DATA"
			json = JSON.parse(packet)

			# a new question's gonna be pickt, so just restore settings 
			fields = ["difficulty", "distribution", "category", "rate", "answer_duration", "max_buzz"]
			for name, data of json
				# console.log data
				unless name of rooms
					log 'log', 'restoring ' + name
					rooms[name] = new SocketQuizRoom(name)
					room = rooms[name]
					for user in data.users
						id = user.id
						room.users[id] = new SocketQuizPlayer(room, id)
						for a, b of user
							room.users[id][a] = b

					for field in fields
						room[field] = data[field] if field of data
			console.log 'restored journal'
			callback() if callback
	req.on 'error', ->
		console.log "Journal not accessible. Starting with defaults."
		callback() if callback
	req.end()


setInterval ->
	clearInactive 1000 * 60 * 60 * 48 
, 1000 * 10 # every ten seconds


reaped = {
	name: "__reaped",
	users: 0,
	rooms: 0,
	seen: 0,
	correct: 0,
	guesses: 0,
	interrupts: 0,
	time_spent: 0,
	early: 0,
	last_action: +new Date
}


clearInactive = (threshold) ->
	# garbazhe collectour
	for name, room of rooms
		len = 0
		offline_pool = (username for username, user of room.users when user.sockets.length is 0)
		overcrowded_room = offline_pool.length > 10
		big_room = Object.keys(room.users).length > 10
		
		oldest_user = ''
		if overcrowded_room
			oldest = offline_pool.sort (a, b) -> 
				return room.users[a].last_action - room.users[b].last_action
			oldest_user = oldest[0]

		for username, user of room.users
			len++
			if !user.online()
				evict_user = false
				if overcrowded_room and username is oldest_user
					evict_user = true
				if (user.last_action < new Date - threshold) or evict_user or
				(user.last_action < new Date - 1000 * 60 * 30 and user.guesses is 0) or
				(big_room and user.correct < 2 and user.last_action < new Date - 1000 * 60 * 10)
					log 'reap_user', {
						seen: user.seen, 
						guesses: user.guesses, 
						early: user.early, 
						interrupts: user.interrupts, 
						correct: user.correct, 
						time_spent: user.time_spent,
						last_action: user.last_action,
						room: name,
						id: user.id,
						name: user.name
					}
					reaped.users++
					reaped.seen += user.seen
					reaped.guesses += user.guesses
					reaped.early += user.early
					reaped.interrupts += user.interrupts
					reaped.correct += user.correct
					reaped.time_spent += user.time_spent
					reaped.last_action = +new Date
					len--
					delete room.users[username]
					overcrowded_room = false
		if len is 0
			# console.log 'removing empty room', name
			log 'reap_room', name
			delete rooms[name]
			reaped.rooms++

app.post '/stalkermode/kickoffline', (req, res) ->
	clearInactive 1000 * 5 # five seconds
	res.redirect '/stalkermode'

app.post '/stalkermode/announce', express.bodyParser(), (req, res) ->
	io.sockets.emit 'chat', {
		text: req.body.message, 
		session: Math.random().toString(36).slice(3), 
		user: '__' + req.body.name, 
		done: true,
		time: +new Date
	}
	res.redirect '/stalkermode'

app.get '/stalkermode/full', (req, res) ->
	util = require('util')
	res.render 'admin.jade', {
		env: app.settings.env,
		mem: util.inspect(process.memoryUsage()),
		start: uptime_begin,
		reaped: reaped,
		full_room: true,
		queue: Object.keys(journal_queue).length,
		rooms: rooms
	}

app.get '/stalkermode', (req, res) ->
	util = require('util')
	res.render 'admin.jade', {
		env: app.settings.env,
		mem: util.inspect(process.memoryUsage()),
		start: uptime_begin,
		reaped: reaped,
		full_room: false,
		queue: Object.keys(journal_queue).length,
		rooms: rooms
	}

app.get '/new', (req, res) ->
	res.redirect '/' + names.generatePage()

app.get '/', (req, res) ->
	if req.headers.host isnt "protobowl.com" and app.settings.env isnt 'development'
		options = url.parse(req.url)
		options.host = 'protobowl.com'
		res.writeHead 301, {Location: url.format(options)}
		res.end()
		return
	res.redirect '/lobby'


app.get '/:channel', (req, res) ->
	name = req.params.channel
	res.render 'room.jade', { name }


remote.initialize_remote()
port = process.env.PORT || 5555
restore_journal ->
	app.listen port, ->
		console.log "listening on port", port