try 
	remote = require './remote'
catch err
	remote = require './local'

remote.initialize_remote()

fs = require 'fs'
http = require 'http'
https = require 'https'
querystring = require 'querystring'
url = require 'url'
os = require 'os'
util = require 'util'
crypto = require 'crypto'
namer = require '../shared/names'

rooms = {}
{QuizRoom} = require '../shared/room'
{QuizPlayer} = require '../shared/player'
{checkAnswer} = require '../shared/checker2'

express = require 'express'

app = express()
server = http.Server(app)

app.set 'views', "admin"
app.set 'view options', layout: false
app.set 'trust proxy', true
app.use '/stalkermode', express.static('admin')

# server = http.Server()
io = require('socket.io').listen(server)
ninjacode = Math.random().toString(36).slice(3)

log_config = { host: 'localhost', port: 18228 }

# server.on 'request', (req, res) ->
# 	res.writeHead 301, {
# 		'Location': 'http://localhost:5555/'
# 	}
# 	res.end()

if app.settings.env is 'production' and remote.deploy
	log_config = remote.deploy.log

io.configure 'production', ->
	io.set "log level", 0
	io.set "browser client minification", true
	io.set "browser client gzip", true
	io.set 'transports', ['websocket', 'htmlfile', 'xhr-polling']
	

io.configure 'development', ->
	io.set "log level", 2
	io.set "browser client minification", false
	io.set "browser client gzip", false
	io.set 'flash policy port', 0
	io.set 'transports', ['websocket', 'htmlfile', 'xhr-polling']
	


codename = namer.generateName()

console.log "hello from protobowl v4, my name is #{codename}", __dirname, process.cwd(), process.memoryUsage()

uptime_begin = +new Date
message_count = 0

# simple helper function that hashes things
sha1 = (text) ->
	hash = crypto.createHash('sha1')
	hash.update(text + '')
	hash.digest('hex')

# basic statistical methods for statistical purposes
Avg = (list) -> Sum(list) / list.length
Sum = (list) -> s = 0; s += item for item in list; s
StDev = (list) -> mu = Avg(list); Math.sqrt Avg((item - mu) * (item - mu) for item in list)

# so i hears that robust statistics are bettrawr, so uh, heres it is
Med = (list) -> m = list.sort((a, b) -> a - b); m[Math.floor(m.length/2)] || 0
IQR = (list) -> m = list.sort((a, b) -> a - b); (m[~~(m.length*0.75)]-m[~~(m.length*0.25)]) || 0
MAD = (list) -> m = list.sort((a, b) -> a - b); Med(Math.abs(item - mu) for item in m)

track_time = (start_time, label) ->
	duration = Date.now() - start_time
	# if (duration > 0 and gammasave) or duration >= 42
	# 	log 'track_time', duration + 'ms ' + label

log = (action, obj) ->
	req = http.request log_config, ->
		# console.log "saved log"
	req.on 'error', (e) ->
		console.log "backup log", action, JSON.stringify(obj), JSON.stringify(e)
	req.write((+new Date) + ' ' + action + ' ' + JSON.stringify(obj) + '\n')
	req.end()

	io.sockets.in("stalkermode-dash").emit action, obj

log 'server_restart', {}

public_room_list = ['lobby', 'hsquizbowl', 'msquizbowl']


class SocketQuizRoom extends QuizRoom
	emit: (name, data) ->
		io.sockets.in(@name).emit name, data

	check_answer: (attempt, answer, question) -> checkAnswer(attempt, answer, question) 

	get_question: (callback) ->
		cb = (question) =>
			log 'next', [@name, question?.answer, @qid]
			callback(question)
		if @next_id and @show_bonus
			remote.get_by_id @next_id, cb
		else
			category = (if @category is 'custom' then @distribution else @category)
			remote.get_question @type, @difficulty, category, cb

	get_parameters: (type, difficulty, callback) -> remote.get_parameters(type, difficulty, callback)

	count_questions: (type, difficulty, category, cb) -> remote.count_questions(type, difficulty, category, cb) 

	journal: (force) -> 
		unless @name of journal_queue
			journal_queue[@name] = Date.now()

		STALE_TIME = 1000 * 60 * 2 # a few minutes
		if !@archived or Date.now() - @archived > STALE_TIME or force
			@archived = Date.now()
			process.nextTick => # do it the next tick, why not?
				t_start = Date.now()
				journal_queue[@name] = null
				remote.archiveRoom? this
				delete journal_queue[@name]
				track_time t_start, "dynamic refresh_stale(#{@name})"
		

	end_buzz: (session) ->
		if @attempt?.user
			ruling = @check_answer @attempt.text, @answer, @question
			log 'buzz', [@name, @attempt.user + '-' + @users[@attempt.user]?.name, @attempt.text, @answer, ruling, @qid, @time() - @begin_time, @end_time - @begin_time, @answer_duration]
		super(session)

	merge_user: (id, new_id) ->
		return false if !@users[id]
		if @users[new_id]
			# merge current user into this one
			sum_terms = ['guesses', 'interrupts', 'early', 'seen', 'correct', 'time_spent']
			for term in sum_terms
				@users[new_id][term] += @users[id][term]
			delete @users[id]
		else
			# rename the current user into this new one
			@users[new_id] = @users[id]
			@users[new_id].id = new_id
			delete @users[id]
			
		@emit 'rename_user', {old_id: id, new_id: new_id}
		@sync(2)

	deserialize: (data) ->
		blacklist = ['users', 'attempt', 'generating_question', 'acl']
		for attr, val of data when attr not in blacklist
			@[attr] = val
		for user in data.users
			u = new SocketQuizPlayer(@, user.id)
			@users[user.id] = u
			u.deserialize(user)

class SocketQuizPlayer extends QuizPlayer
	constructor: (room, id) ->
		super(room, id)
		@sockets = []
		@name = namer.generateName()
	
	chat: (data) ->
		super(data)
		log 'chat', [@room.name, @id + '-' + @name, data.text] if data.done

	verb: (action, no_rate_limit) -> 
		super(action, no_rate_limit)
		log 'verb', [@room.name, @id + '-' + @name, action]
		@room.journal()

	online: -> @sockets.length > 0

	report_question: (data) ->
		return unless data
		data.room = @room.name
		data.user = @id + '-' + @name
		remote.handle_report data if remote.handle_report
		log 'report_question', data

	tag_question: (data) ->
		mongoose = require 'mongoose'
		remote.Question.findById mongoose.Types.ObjectId(data.id), (err, doc) ->
			return if err
			doc.tags = data.tags
			doc.save()

	change_bold: (data) ->
		mongoose = require 'mongoose'
		remote.Question.findById mongoose.Types.ObjectId(data.id), (err, doc) =>
			return if err
			if data.answer.replace(/[^a-z]/ig, '') is doc.answer.replace(/[^a-z]/ig, '')
				doc.answer = data.answer
				doc.fixed = 1
				doc.save()
				@emit 'bold', { user: @id, qid: data.id, time: @room.serverTime(), answer: doc.answer }


	report_answer: (data) ->
		return unless data
		data.room = @room.name
		data.user = @id + '-' + @name
		log 'report_answer', data

		mongoose = require 'mongoose'
		remote.Question.findById mongoose.Types.ObjectId(data.qid), (err, doc) ->
			if !err and doc and doc.fixed isnt 1
				doc.fixed = -1
				doc.save()
		

	check_public: (_, fn) ->
		output = {}
		for check_name in public_room_list
			output[check_name] = 0
			if rooms[check_name]?.users
				for uid, udat of rooms[check_name].users
					output[check_name]++ if udat.active()


		for name in remote.get_types()
			check_name = name + '/lobby'
			if rooms[check_name]?.users
				output[check_name] = 0
				for uid, udat of rooms[check_name].users
					output[check_name]++ if udat.active()
		fn output if fn

	ban: (duration = 1000 * 60 * 10) ->
		if @room.serverTime() > @banned
			# if you have not been banned already
			@banned = @room.serverTime() + duration
			@room._ip_ban = {} if !@room._ip_ban
			for ip in @ip()
				@room._ip_ban[ip] = { strikes: 0, banished: 0 } if !@room._ip_ban[ip]
				@room._ip_ban[ip].strikes++

		order = ['b', 'hm', 'cgl', 'mlp']

		destination = order[(order.indexOf(@room.name) + 1)]

		if !destination # nothing, there is nothing
			@banned = 0
			return  false

		@emit 'redirect', '/' + destination
		
		for sock in @sockets
			io.sockets.socket(sock)?.disconnect()

	ip_ban: (duration = 1000 * 60 * 25) ->
		@room._ip_ban = {} if !@room._ip_ban
		for ip in @ip()
			@room._ip_ban[ip] = { strikes: 0, banished: @room.serverTime() + duration }
		@ban(duration)

	rate_limit: -> false

	ip: ->
		ips = []
		for sock_id in @sockets
			sock = io.sockets.socket(sock_id)
			real_ip = sock.handshake?.address?.address
			forward_ip = sock.handshake?.headers?["x-forwarded-for"]
			addr = (forward_ip || real_ip)
			ips.push addr if sock and addr
		return ips

	_password: -> remote?.passcode(this)

	link: (assertion) ->
		console.log 'verifying assertion', assertion
		req = https.request host: "verifier.login.persona.org", path: "/verify", method: "POST", (res) =>
			body = ''
			res.on 'data', (chunk) -> body += chunk
			res.on 'end', =>
				try
					response = JSON.parse(body)
					# console.log response
					response.cookie = remote.secure_cookie {email: response.email, time: Date.now()}

					@emit 'verify', response
					# @room.merge_user @id, sha1(response.email)
					# if response?.status is 'okay'
		
		audience = "http://localhost:5555"
		data = querystring.stringify assertion: assertion, audience: audience
		req.setHeader 'Content-Type', 'application/x-www-form-urlencoded'
		req.setHeader 'Content-Length', data.length
		req.write data
		req.end()


	update: -> io.sockets.emit 'force_application_update', Date.now()

	add_socket: (sock) ->
		add_start = Date.now()
		if @sockets.length is 0
			@last_session = @room.serverTime()
			@verb 'joined the room'

		@sockets.push sock.id unless sock.id in @sockets
		blacklist = ['add_socket', 'emit', 'disconnect']
		
		sock.on 'disconnect', =>
			@sockets = (s for s in @sockets when (s isnt sock.id and io.sockets.socket(s)))
			if @sockets.length is 0
				@disconnected()
				@room.journal()
				user_count_log 'disconnected ' + @id + '-' + @name, @room.name
		
		for attr of this when typeof this[attr] is 'function' and attr not in blacklist and attr[0] != '_'
			# wow this is a pretty mesed up line
			do (attr) => 
				sock.on attr, (args...) => 
					message_count++
					t_start = Date.now()
					if @banned and @room.serverTime() < @banned
						@ban()
					else if @__rate_limited and @room.serverTime() < @__rate_limited and @id[0] != '_'
						@throttle()
					else
						try
							this[attr](args...)
						catch err
							console.error "Error while running QuizPlayer::#{attr} for #{@room.name}/#{@id} with args: ", args
							console.error err.stack
							@room.emit 'debug', "Error while running QuizPlayer::#{attr} for #{@room.name}/#{@id}.\nPlease email info@protobowl.com with the contents of this error.\n\n#{err.stack}"
							remote?.notifyBen "Error while running QuizPlayer::#{attr} for #{@room.name}/#{@id}", "#{err.stack}"

					track_time t_start, "QuizPlayer::#{attr} for #{@room.name}/#{@id}"

		if @banned and @room.serverTime() < @banned
			@ban()
			sock.disconnect()

		@room.journal()
		
		for ip in @ip()
			if @room._ip_ban and @room._ip_ban[ip]
				if @room._ip_ban[ip].strikes >= 3
					@ip_ban()

				if @room.serverTime() < @room._ip_ban[ip].banished
					@ban()
					break


		user_count_log 'connected ' + @id + '-' + @name + " (#{ip})", @room.name
		track_time add_start, "QuizPlayer::add_socket for #{@room.name}/#{@id}"

	disconnect_all: ->
		for sock in @sockets
			io.sockets.socket(sock).disconnect()

	emit: (name, data) ->
		for sock in @sockets
			io.sockets.socket(sock).emit(name, data)

status_metrics = ->
	active_count = 0
	online_count = 0
	muwave_count = 0
	latencies = []
	for name, room of rooms
		for uid, user of room.users
			if user.online()
				online_count++ 
				active_count++ if user.active()
				muwave_count++ if user.muwave
				latencies.push(user._latency[0]) if user._latency
	metrics = { 
		online: online_count, 
		active: active_count, 
		avg_latency: Med(latencies), 
		std_latency: IQR(latencies), 
		free_memory: os.freemem(), 
		message_count,
		muwave: muwave_count
	}
	return metrics

last_message = 0

user_count_log = (message, room_name) ->
	t_start = Date.now()
	metrics = status_metrics()
	metrics.room = room_name
	metrics.message = message
	log 'user_count', metrics
	
	if Date.now() > last_message + 1000 * 60 * 10 and metrics.avg_latency > 250
		last_message = Date.now()
		remote?.notifyBen? 'Detected Increased Latency', "THE WAG IN HERE IS TOO DAMN HIGH #{metrics.avg_latency} ± #{metrics.std_latency}\n\n#{util.inspect(metrics)}"

	track_time t_start, "user_count_log"


load_room = (name, callback) ->
	if rooms[name] # its really nice and simple if you have it cached
		return callback rooms[name], false
	t_start = Date.now()
	
	timeout = setTimeout ->
		handle_response null
	, 1000 * 6

	handle_response = (data) ->	
		clearTimeout timeout

		room = new SocketQuizRoom(name) 
		rooms[name] = room

		if data and data.users and data.name
			room.deserialize data
			callback room, false, Date.now() - t_start
		else
			callback room, true, Date.now() - t_start

	if remote.loadRoom
		remote.loadRoom name, handle_response

	else
		handle_response null
		# room = new SocketQuizRoom(name) 
		# rooms[name] = room
		# callback room, true
	track_time t_start, "load_room(#{name})"

io.sockets.on 'connection', (sock) ->
	headers = sock?.handshake?.headers
	if headers?.referer
		config = url.parse(headers.referer, true)
		# is_ninja = 'ninja' of config.query	
		# configger the things which are derived from said parsed stuff

		if config.pathname is '/stalkermode/patriot'
			sock.join 'stalkermode-dash'
			sock.on 'status', ->
				io.sockets.in("stalkermode-dash").emit 'user_count', status_metrics()
			return
			
	user = null

	sock.on 'perf', (noop, cb) -> cb os.freemem()

	sock.on 'join', ({auth, cookie, room_name, question_type, old_socket, version, custom_id, muwave}) ->
		if user
			sock.emit 'debug', "For some reason it appears you are a zombie. Please contact info@protobowl.com because this is worthy of investigation."
			return
		if !version or version < 7 or !room_name
			sock.emit 'log', verb: 'YOU ARE RUNNING AN OUTDATED AND INCOMPATIBLE VERSION OF PROTOBOWL.'
			sock.emit 'force_application_update', Date.now()
			sock.emit 'application_update', Date.now()
			sock.disconnect()
			return
		# io.sockets.socket(old_socket)?.disconnect() if old_socket

		protoauth = remote.parse_cookie(auth)
		if auth is ninjacode
			is_ninja = true
		else if protoauth
			publicID = sha1(protoauth.email)
		else
			publicID = sha1(cookie + room_name + '')
			if auth
				sock.emit 'log', verb: 'Warning: Authorization token was rejected by server'

		if room_name is "private"
			unless protoauth
				sock.emit 'log', verb: 'You may not access this private room without first logging in.'
				sock.disconnected()
				return
			room_name = "private/"+publicID

		# get the room
		slow_load = setTimeout ->
			sock.emit 'log', verb: 'The database state server is taking unusually long to look up a room. This can happen when the statekeeper database is inaccessible. Please contact the Protobowl administrators or developers to resolve this issue. '
		, 1000 * 3

		load_room room_name, (room, is_new, load_elapsed) ->
			clearTimeout slow_load

			room.type = question_type if is_new

			if is_ninja
				publicID = "__secret_ninja_#{Math.random().toFixed(4).slice(2)}" 
				if custom_id
					publicID = (custom_id + "0000000000000000000000000000000000000000").slice(0, 40)
					is_ninja = false

			# get the user's identity
			existing_user = (publicID of room.users)
			unless room.users[publicID]
				room.users[publicID] = new SocketQuizPlayer(room, publicID) 
				user = room.users[publicID]

				if room_name in public_room_list
					# public rooms default to locked, like cars in the city
					user.lock = true
				else
					if room.active_count() <= 1
						# small room, hey wai not right?
						user.lock = true
					else if room.locked()
						user.lock = true
					else
						# probablistic systems work for lots of things
						user.lock = (Math.random() > 0.5)

			user = room.users[publicID]
			user.name = 'secret ninja' if is_ninja
			user.auth = true if protoauth

			try
				if muwave
					user.muwave = 100
				else if sock.transport is 'xhr-polling'
					user.muwave = 1
				else if sock.transport is 'htmlfile'
					user.muwave = 2
				else if sock.transport is 'jsonp-polling'
					user.muwave = 3
				else
					delete user.muwave
				if user.muwave
					user._transport = sock.transport
					user._headers = sock?.handshake?.headers
			catch err
				remote?.notifyBen? 'Internal SocketIO error', "Internal Error: \n#{err}\n#{room_name}/#{publicID}\n#{sock?.handshake?.headers}"

			sock.join room_name
			user.add_socket sock

			real_ip = sock.handshake?.address?.address
			forward_ip = sock.handshake?.headers?["x-forwarded-for"]

			sock.emit 'joined', { auth: protoauth, id: user.id, name: user.name, existing: existing_user, muwave: user.muwave, ip: (forward_ip || real_ip) }
			room.sync(4) # tell errybody that there's a new person at the partaay
			if !cookie
				sock.emit 'log', verb: "Warning: This session lacks a protocookie. The session state may not be preserved and may be inadvertently shared with others. "

			# if !auth
			# 	sock.emit 'log', verb: "TODO: Remove this warning, because its totes okay not to be logged in while in production "

			# # detect if the server had been recently restarted
			if new Date - uptime_begin < 1000 * 60 * 2
				if existing_user
					sock.emit 'log', {verb: 'The server has recently been restarted. This may have been part of a software update, or the result of an unexpected server crash. We apologize for any inconvenience this may have caused.'}
				sock.emit 'application_update', Date.now() # check for updates in case it was an update


journal_queue = {}

process_queue = ->
	t_start = Date.now()
	[min_time, min_room] = [Date.now(), null]
	for name, time of journal_queue
		if !rooms[name]
			journal_queue[name] = null
			delete journal_queue[name]
			continue			
		[min_time, min_room] = [time, name] if time < min_time
	
	track_time t_start, 'argmin_queue'
	return unless min_room

	# if !gammasave
	# 	return if Date.now() - min_time  < 1000 * 60 * 3

	room = rooms[min_room]

	STALE_TIME = 1000 * 3
	
	if !room?.archived or Date.now() - room?.archived > STALE_TIME
		room.archived = Date.now()
		process.nextTick ->
			t_start = Date.now()
			remote.archiveRoom? room
			journal_queue[min_room] = null
			delete journal_queue[min_room]
			track_time t_start, "static refresh_stale(#{min_room})"
	

setInterval process_queue, 1000	

perf_hist = (0 for i in [0..100])

check_performance = ->
	t_now = Date.now()
	delay = 100
	setTimeout ->
		t_delta = Math.max(0, Date.now() - t_now - delay)
		
		perf_hist[Math.min(perf_hist.length - 1, t_delta)]++

		if t_delta > 50
			io.sockets.in("stalkermode-dash").emit 'slow', t_delta
	, delay

setInterval check_performance, 762

clearInactive = ->
	t_start = Date.now()
	# the maximum size a room can be
	MAX_SIZE = 15

	rank_user = (u) -> if u.correct > 2 then u.last_action else u.time_spent
	
	reap_room = (name) ->
		log 'reap_room', name
		rooms[name] = null
		journal_queue[name] = null
		delete journal_queue[name]
		delete rooms[name]
		remote.removeRoom?(name)

	reap_user = (u) ->
		log 'reap_user', {
			seen: u.seen, 
			guesses: u.guesses, 
			early: u.early, 
			interrupts: u.interrupts, 
			correct: u.correct, 
			time_spent: u.time_spent,
			last_action: u.last_action,
			room: u.room.name,
			id: u.id,
			name: u.name
		}
		u.room.delete_user u.id

	for room_name, room of rooms
		user_pool = (user for id, user of room.users)
		if user_pool.length is 0
			reap_room room_name
			continue

		offline_pool = (user for user in user_pool when !user.online())
		
		for user in offline_pool when user.correct < 2 and user.last_action < Date.now() - 1000 * 60 * 5
			reap_user user
			continue

		offline_pool.sort (a, b) -> rank_user(a) - rank_user(b)
		if offline_pool.length > 0 and user_pool.length > MAX_SIZE
			reap_user offline_pool[0]
			continue # no point here but it makes the code more poetic

	track_time t_start, 'clearInactive'

setInterval clearInactive, 1000 * 10 # every ten seconds


# think of it like a filesystem swap; slow access external memory that is used to save ram
swapInactive = ->
	t_start = Date.now()
	for name, room of rooms
		online = (user for username, user of room.users when user.online())
		continue if online.length > 0
		events = (room.serverTime() - user.last_action for username, user of room.users)
		shortest_lapse = Math.min.apply @, events
		continue if shortest_lapse < 1000 * 60 * 20 # things are stale after a few minutes
		# ripe for swapping
		remote.archiveRoom? room, (name) ->
			rooms[name] = null
			delete rooms[name]
			journal_queue[name] = null
			delete journal_queue[name]

	track_time t_start, 'swapInactive'

if remote.archiveRoom
	# do it every ten seconds like a bonobo
	setInterval swapInactive, 1000 * 10 



port = process.env.PORT || 5566

remote.ready ->
	server.listen port, ->
		console.log "listening on port", port

app.use express.bodyParser()

# authorization and redirects
app.use (req, res, next) ->
	res.header("Access-Control-Allow-Origin", "*")
	res.header("Access-Control-Allow-Methods", "HEAD,GET,PUT,POST,DELETE")
	res.header("Access-Control-Allow-Headers", "X-Requested-With")

	if remote.authorized and /stalkermode/.test(req.path)
		remote.authorized req, (allow) ->
			if allow
				next()
			else
				res.redirect "/401"
	else
		next()


app.post '/stalkermode/announce', (req, res) ->
	io.sockets.emit 'chat', {
		text: req.body.message, 
		session: Math.random().toString(36).slice(3), 
		user: '__' + req.body.name, 
		done: true,
		time: +new Date
	}
	res.redirect '/stalkermode'

# i forgot why it was called al gore; possibly change
app.post '/stalkermode/algore', (req, res) ->
	return res.end('nothing to count') unless remote.populate_cache
	remote.populate_cache (layers) ->
		res.end("counted all cats #{JSON.stringify(layers, null, '  ')}")

app.post '/stalkermode/dapowah', (req, res) ->
	remote.loadAuthfile()
	res.end("loaded authorization file")

app.get '/stalkermode/authcodes', (req, res) ->
	res.end(JSON.stringify(remote.get_passcodes(), null, '  '))

app.get '/stalkermode/users', (req, res) -> res.render 'users.jade', { rooms: rooms }


app.get '/stalkermode/cook', (req, res) ->
	remote.cook?(req, res)
	res.redirect '/stalkermode'


app.get '/stalkermode/logout', (req, res) ->
	res.clearCookie 'boxxyauth'
	res.redirect '/stalkermode'


app.get '/stalkermode/user/:room/:user', (req, res) ->
	req.params.room = req.params.room.replace(/~/g, '/')
	u = rooms?[req.params.room]?.users?[req.params.user]
	u2 = {}
	u2[k] = v for k, v of u when k not in ['room'] and typeof v isnt 'function'
		
	res.render 'user.jade', { room: req.params.room, id: req.params.user, user: u, text: util.inspect(u2), ips: u?.ip() }


app.get '/stalkermode/room/:room', (req, res) ->
	u = rooms?[req.params.room.replace(/~/g, '/')]
	u2 = {}
	u2[k] = v for k, v of u when k not in ['users', 'timing', 'cumulative'] and typeof v isnt 'function'
	res.render 'control.jade', { room: u, name: req.params.room.replace(/~/g, '/'), text: util.inspect(u2)}

app.post '/stalkermode/stahp', (req, res) -> process.exit(0)

app.post '/stalkermode/the-scene-is-safe', (req, res) -> 
	io.sockets.emit 'impending_doom', Date.now()

	user_names = (name for name, time of journal_queue)
	restart_server = ->
		console.log 'Server shutdown has been manually triggered'
		setTimeout ->
			process.exit(0)
		, 250
	if user_names.length is 0
		res.end 'Nothing to save; Server restarted.' 
		restart_server()
		return
	start_time = Date.now()
	saved = 0
	increment_and_check = ->
		saved++
		if saved is user_names.length
			res.end "Saved #{user_names.length} rooms (#{user_names.join(', ')}) in #{Date.now() - start_time}ms; Server restarted."
			restart_server()
	for name in user_names
		remote.archiveRoom? rooms[name], increment_and_check


app.post '/stalkermode/clear_bans/:room', (req, res) ->
	delete rooms?[req.params.room.replace(/~/g, '/')]?._ip_ban
	res.redirect "/stalkermode/room/#{req.params.room}"

app.post '/stalkermode/anarchy/:room', (req, res) ->
	room = rooms?[req.params.room.replace(/~/g, '/')]
	room?.admins = []
	room?.sync(1)
	res.redirect "/stalkermode/room/#{req.params.room}"

app.post '/stalkermode/delete_room/:room', (req, res) ->
	if rooms?[req.params.room.replace(/~/g, '/')]?.users
		for id, u of rooms[req.params.room.replace(/~/g, '/')].users
			for sock in u.sockets
				io.sockets.socket(sock).disconnect()
	rooms[req.params.room.replace(/~/g, '/')] = new SocketQuizRoom(req.params.room.replace(/~/g, '/'))
	res.redirect "/stalkermode/room/#{req.params.room}"


app.post '/stalkermode/disco_room/:room', (req, res) ->
	if rooms?[req.params.room.replace(/~/g, '/')]?.users
		for id, u of rooms[req.params.room.replace(/~/g, '/')].users
			for sock in u.sockets
				io.sockets.socket(sock).disconnect()
	res.redirect "/stalkermode/room/#{req.params.room}"


app.post '/stalkermode/emit/:room/:user', (req, res) ->
	u = rooms?[req.params.room.replace(/~/g, '/')]?.users?[req.params.user]
	u.emit req.body.action, req.body.text
	res.redirect "/stalkermode/user/#{req.params.room}/#{req.params.user}"

app.post '/stalkermode/exec/:command/:room/:user', (req, res) ->
	rooms?[req.params.room.replace(/~/g, '/')]?.users?[req.params.user]?[req.params.command]?()
	res.redirect "/stalkermode/user/#{req.params.room}/#{req.params.user}"

app.post '/stalkermode/unban/:room/:user', (req, res) ->
	rooms?[req.params.room.replace(/~/g, '/')]?.users?[req.params.user]?.banned = 0
	res.redirect "/stalkermode/user/#{req.params.room}/#{req.params.user}"


app.post '/stalkermode/negify/:room/:user/:num', (req, res) ->
	rooms?[req.params.room.replace(/~/g, '/')]?.users?[req.params.user]?.interrupts += (parseInt(req.params.num) || 1)
	rooms?[req.params.room.replace(/~/g, '/')]?.sync(1)
	res.redirect "/stalkermode/user/#{req.params.room}/#{req.params.user}"

app.post '/stalkermode/cheatify/:room/:user/:num', (req, res) ->
	rooms?[req.params.room.replace(/~/g, '/')]?.users?[req.params.user]?.correct += (parseInt(req.params.num) || 1)
	rooms?[req.params.room.replace(/~/g, '/')]?.sync(1)
	res.redirect "/stalkermode/user/#{req.params.room}/#{req.params.user}"


app.post '/stalkermode/disco/:room/:user', (req, res) ->
	u = rooms?[req.params.room.replace(/~/g, '/')]?.users?[req.params.user]
	io.sockets.socket(sock).disconnect() for sock in u.sockets
	res.redirect "/stalkermode/user/#{req.params.room}/#{req.params.user}"

app.get '/stalkermode', (req, res) ->
	latencies = []
	for name, room of rooms
		latencies.push(user._latency[0]) for id, user of room.users when user._latency and user.online()
	os_info = {
		hostname: os.hostname(),
		type: os.type(),
		platform: os.platform(),
		arch: os.arch(),
		release: os.release(),
		loadavg: os.loadavg(),
		uptime: os.uptime(),
		totalmem: os.totalmem(),
		freemem: os.freemem()
	}
	res.render 'admin.jade', {
		env: app.settings.env,
		mem: util.inspect(process.memoryUsage()),
		start: uptime_begin,
		avg_latency: Med(latencies),
		std_latency: IQR(latencies),
		cookie: req.protocookie,
		queue: Object.keys(journal_queue).length,
		os: os_info,
		os_text: util.inspect(os_info),
		codename,
		message_count,
		rooms
	}

app.post '/stalkermode/reports/remove_report/:id', (req, res) ->
	mongoose = require 'mongoose'
	remote.Report.remove {_id: mongoose.Types.ObjectId(req.params.id)}, (err, docs) ->
		res.end 'REMOVED IT' + req.params.id


app.post '/stalkermode/reports/remove_question/:id', (req, res) ->
	mongoose = require 'mongoose'
	remote.Question.remove {_id: mongoose.Types.ObjectId(req.params.id)}, (err, docs) ->
		res.end 'REMOVED IT' + req.params.id


app.post '/stalkermode/reports/change_question/:id', (req, res) ->
	mongoose = require 'mongoose'
	blacklist = ['inc_random', 'seen']
	remote.Question.findById mongoose.Types.ObjectId(req.params.id), (err, doc) ->
		criterion = {
			difficulty: req.body.difficulty || doc.difficulty, 
			category: req.body.category || doc.category, 
			type: req.body.type || doc.type
		}
		remote.Question.collection.findOne criterion, null, { sort: { inc_random: 1 } }, (err, existing) ->
			for key, val of req.body when key not in blacklist
				doc[key] = val
			doc.inc_random = existing.inc_random - 0.1 # show it now
			doc.save()
			res.end('gots it')

app.post '/stalkermode/reports/simple_change/:id', (req, res) ->
	mongoose = require 'mongoose'
	blacklist = ['inc_random', 'seen', 'category', 'difficulty']
	remote.Question.findById mongoose.Types.ObjectId(req.params.id), (err, doc) ->
		for key, val of req.body when key not in blacklist
			doc[key] = val
		doc.save()
		res.end('gots it')

app.post '/stalkermode/reports/set_bold', (req, res) ->
	mongoose = require 'mongoose'
	remote.Question.update { answer: req.body.old }, { $set: { answer: req.body.answer, fixed: req.body.fixed || 1 }}, {multi: true}, (err) ->
		res.end('merp')

app.post '/stalkermode/reports/report_question/:id', (req, res) ->
	mongoose = require 'mongoose'
	remote.Question.findById mongoose.Types.ObjectId(req.params.id), (err, doc) ->
		remote.handle_report {
			type: doc.type,
			category: doc.category,
			num: doc.num,
			tournament: doc.tournament,
			question: doc.question,
			answer: doc.answer,
			difficulty: doc.difficulty,
			year: doc.year,
			round: doc.round,
			qid: doc.id.toString(),
			comment: "reported from stalkermode"
		}
		res.end('merp')


app.get '/stalkermode/remaining', (req, res) ->
	remote.count_unfixed (count) ->
		res.end count.toString()

# app.get '/stalkermode/to_meekly_go', (req, res) ->
# 	remote.Question.findOne { fixed: 42 }, (err, doc) ->
# 		res.end JSON.stringify doc

app.get '/stalkermode/to_boldly_go', (req, res) ->
	remote.Question.findOne { fixed: -1 }, (err, doc) ->
		if !doc
			# remote.Question.findOne { fixed: null }, (err, doc) ->
			# 	res.end JSON.stringify doc
			# return
			cats = ["Science", "Fine Arts", "Literature", "Social Science", "History", "Geography", "Religion", "Trash", "Philosophy", "Mythology"]
			cat = cats[Math.floor(cats.length * Math.random())]
			remote.Question.find({fixed: null, type: "qb", category: cat}).sort('inc_random').findOne (err, doc) ->
				res.end JSON.stringify doc
			return

		res.end JSON.stringify doc

app.get '/stalkermode/reports/all', (req, res) ->
	return res.render 'reports.jade', { reports: [], categories: [] } unless remote.Report
	remote.Report.find {}, (err, docs) ->
		res.render 'reports.jade', { reports: docs, categories: remote.get_categories('qb') }

app.get '/stalkermode/reports/:type', (req, res) ->
	return res.render 'reports.jade', { reports: [], categories: [] } unless remote.Report
	remote.Report.find {describe: req.params.type}, (err, docs) ->
		res.render 'reports.jade', { reports: docs, categories: remote.get_categories('qb') }

app.get '/lag', (req, res) ->
	res.render 'lag.jade', { }

app.get '/stalkermode/audacity', (req, res) ->
	res.render 'audacity.jade', { }

app.get '/stalkermode/patriot', (req, res) -> res.render 'dash.jade'

app.get '/stalkermode/ninjacode', (req, res) -> 
	res.header 'Access-Control-Allow-Origin', '*'
	res.end ninjacode


app.get '/stalkermode/archived', (req, res) -> 
	return res.render 'archived.jade', { list: [], rooms } unless remote.listArchived
	remote.listArchived (list) ->
		res.render 'archived.jade', { list, rooms }

app.get '/stalkermode/:other', (req, res) -> res.redirect '/stalkermode'

app.get '/perf-histogram', (req, res) -> res.end util.inspect(perf_hist)

app.get '/401', (req, res) -> res.render 'auth.jade', {}

app.post '/401', (req, res) -> remote.authenticate(req, res)

app.get '*', (req, res) ->
	options = url.parse(req.url)
	options.host = 'protobowl.com'
	res.writeHead 301, {Location: url.format(options)}
	res.end()