express = require('express')
fs = require('fs')
checkAnswer = require('./lib/answerparse').checkAnswer
syllables = require('./lib/syllable').syllables
parseCookie = require('express/node_modules/connect').utils.parseCookie
crypto = require('crypto')

app = express.createServer() 
io = require('socket.io').listen(app)

url = require('url')

Cookies = require('cookies')
app.use require('less-middleware')({src: __dirname})
app.use express.favicon(__dirname + '/img/favicon.ico')

names = require('./lib/names')

try 
	remote = require('./lib/remote')
catch err
	questions = []
	count = 0
	fs.readFile 'sample.txt', 'utf8', (err, data) ->
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

	remote = {
		countQuestions: (diff, cat, cb) ->
			cb filterQuestions(diff, cat).length, 42
		getAtIndex: (diff, cat, index, cb) ->
			cb filterQuestions(diff, cat)[index]
		getCategories: -> listProps('category')
		getDifficulties: -> listProps('difficulty')
	}

# this injects cookies into things, woot
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
	
#app.use express.cookieParser()
#app.use express.session {secret: 'should probably make this more secretive', cookie: {httpOnly: false}}
app.use express.static(__dirname)

if app.settings.env is 'development'
	scheduledUpdate = null
	updateCache = ->
		fs.readFile __dirname + '/offline.appcache', 'utf8', (err, data) ->
			throw err if err
			data = data.replace(/INSERT_DATE.*?\n/, 'INSERT_DATE '+(new Date).toString() + "\n")
			fs.writeFile __dirname + '/offline.appcache', data, (err) ->
				throw err if err
				io.sockets.emit 'application_update', +new Date
				scheduledUpdate = null

	watcher = (event, filename) ->
		return if filename in ["offline.appcache", "web.js", "web.coffee", "remote.coffee", "remote.js"] or /\.css$/.test(filename)
		console.log "changed file", filename
		unless scheduledUpdate
			scheduledUpdate = setTimeout updateCache, 500

	fs.watch __dirname, watcher
	fs.watch __dirname + "/lib", watcher
	fs.watch __dirname + "/less", watcher
	
io.configure 'production', ->
	io.set "log level", 0

io.configure 'development', ->
	io.set "log level", 2

app.set 'views', __dirname
app.set 'view options', {
	layout: false
}

error_question = {
	'category': '$0x40000',
	'difficulty': 'segmentation fault',
	'num': 'NaN',
	'tournament': 'Guru Meditation Cup',
	'question': 'This type of event occurs when the queried database returns an invalid question and is frequently indicative of a set of constraints which yields a null set. Certain manifestations of this kind of event lead to significant monetary loss and often result in large public relations campaigns to recover from the damaged brand valuation. This type of event is most common with computer software and hardware, and one way to diagnose this type of event when it happens on the bootstrapping phase of a computer operating system is by looking for the POST information. Kernel varieties of this event which are unrecoverable are referred to as namesake panics in the BSD/Mach hybrid microkernel which powers Mac OS X. The infamous Disk Operating System variety of this type of event is known for its primary color backdrop and continues to plague many of the contemporary descendents of DOS with code names such as Whistler, Longhorn and Chidori. For 10 points, name this event which happened right now.',
	'answer': 'error',
	'year': 1970,
	'round': '0x080483ba'
}

cumsum = (list, rate) ->
	sum = 0 #start nonzero, allow pause before rendering
	for num in [5].concat(list).slice(0, -1)
		sum += Math.round(num) * rate #always round!


fisher_yates = (i) ->
	return [] if i is 0
	arr = [0...i]
	while --i
		j = Math.floor(Math.random() * (i+1))
		[arr[i], arr[j]] = [arr[j], arr[i]] 
	arr

class QuizRoom
	constructor: (name) ->
		@name = name
		@answer_duration = 1000 * 5
		@time_offset = 0
		@rate = 1000 * 60 / 5 / 200
		@__timeout = -1
		
		# the following are nasty database hacks
		@question_schedule = []
		@history = []

		@freeze()
		@new_question()
		@users = {}
		@difficulty = ''
		@category = ''

		@max_buzz = null

		
	# this function really doesn't belong in here, because it sort of screws
	# up the database abstractions, but this app wasn't even supposed to have
	# a database, so I don't really care how disgustingly un-cool and bad
	# this is
	reset_schedule: ->
		remote.countQuestions @difficulty, @category, (num) =>
			if num < 300
				@question_schedule = fisher_yates(num)
			else
				@question_schedule = []

	get_question: (cb) ->
		num_attempts = 0
		attemptQuestion = =>
			num_attempts++
			remote.getQuestion @difficulty, @category, (question) =>
				# console.log(typeof question._id, @history,  "ATTEMPTS", num_attempts)
				if question._id.toString() in @history and num_attempts < 15
					return attemptQuestion()
				@history.splice 100
				@history.splice 0, 0, question._id.toString()
				cb(question || error_question)

		remote.countQuestions @difficulty, @category, (num, no_db) =>
			if num < 300 or no_db is 42
				if @question_schedule.length is 0
					@question_schedule = fisher_yates(num)

				index = @question_schedule.shift()
				
				remote.getAtIndex @difficulty, @category, index, (doc) ->
					cb doc || error_question

			else
				attemptQuestion()

	add_socket: (id, socket) ->
		unless id of @users
			@users[id] = {
				sockets: [],
				guesses: 0,
				interrupts: 0,
				early: 0,
				correct: 0,
				seen: 0,
				time_spent: 0,
				last_action: 0,
				times_buzzed: 0,
				show_typing: true,
				buzz_sound: false
			}
			journal @name
		user = @users[id]
		user.id = id
		@touch(id, true)
		# user.last_action = @serverTime()
		unless socket in user.sockets
			user.sockets.push socket
		
	emit_user: (id, args...) ->
		if id of @users
			for sock in @users[id].sockets
				s = io.sockets.socket(sock)
				s.emit args...


	# vote: (id, action, val) ->
	# 	# room.add_socket publicID, sock.id
	# 	@users[id][action] = val
	# 	@sync()

	touch: (id, no_add_time) ->
		unless no_add_time
			elapsed = @serverTime() - @users[id].last_action
			if elapsed < 1000 * 60 * 10
				@users[id].time_spent += elapsed
		@users[id].last_action = @serverTime()

	del_socket: (id, socket) ->
		user = @users[id]
		if user
			@touch(id)
			user.sockets = (sock for sock in user.sockets when sock isnt socket)
		journal @name

	time: ->
		return if @time_freeze then @time_freeze else @serverTime() - @time_offset

	serverTime: ->
		return +new Date

	freeze: ->
		@time_freeze = @time()

	unfreeze: ->
		if @time_freeze
			# @time_offset = new Date - @time_freeze
			@set_time @time_freeze
			@time_freeze = 0

	set_time: (ts) ->
		@time_offset = new Date - ts

	pause: ->
		#no point really because being in an attempt means being frozen
		@freeze() unless @attempt or @time() > @end_time
			
	unpause: ->
		#freeze with access controls
		@unfreeze() unless @attempt
	
	timeout: (metric, time, callback) ->
		@clear_timeout()
		diff = time - metric()
		if diff < 0
			callback()
		else
			@__timeout = setTimeout =>
				@timeout(metric, time, callback)
			, diff

	clear_timeout: ->
		clearTimeout @__timeout

	new_question: ->
		# question = questions[Math.floor(questions.length * Math.random())]
		@generating_question = true
		@get_question (question) =>
			delete @generating_question;
			@attempt = null
			@info = {
				category: question.category, 
				difficulty: question.difficulty, 
				tournament: question.tournament, 
				num: question.num, 
				year: question.year, 
				round: question.round
			}
			@question = question.question
				.replace(/FTP/g, 'For 10 points')
				.replace(/^\[.*?\]/, '')
				.replace(/\n/g, ' ')
				.replace(/\s+/g, ' ')
			@answer = question.answer
				.replace(/\<\w\w\>/g, '')
				.replace(/\[\w\w\]/g, '')

			# console.log @info
			# @qid = question.question
			@qid = "pb" + @info.year + "-" + @info.num + "-" + 
			@info.tournament.replace(/[^a-z0-9]+/ig, '-') + "---" +
			@answer.replace(/[^a-z0-9]+/ig, '-').slice(0, 20)
			# console.log @qid

			@begin_time = @time()
			@timing = (syllables(word) + 1 for word in @question.split(" "))
			@set_speed @rate #do the math with speeds
			# @cumulative = cumsum @timing, @rate #todo: comment out
			# @end_time = @begin_time + @cumulative[@cumulative.length - 1] + @answer_duration
			for id, user of @users
				user.times_buzzed = 0
				if user.sockets.length > 0 and new Date - user.last_action < 1000 * 60 * 10
					user.seen++

			@sync(2)

	set_speed: (rate) ->
		now = @time() # take a snapshot of time to do math with
		#first thing's first, recalculate the cumulative array
		@cumulative = cumsum @timing, @rate
		#calculate percentage of reading right now
		elapsed = now - @begin_time
		duration = @cumulative[@cumulative.length - 1]
		done = elapsed / duration

		# if it's past the actual reading time
		# this means altering the rate doesnt actually
		# affect the length of the answer_duration
		remainder = 0
		if done > 1
			remainder = elapsed - duration
			done = 1
		
		# set the new rate
		@rate = rate
		# recalculate the reading intervals
		@cumulative = cumsum @timing, @rate
		new_duration = @cumulative[@cumulative.length - 1]
		#how much time has elapsed in the new timescale
		@begin_time = now - new_duration * done - remainder
		# set the ending time
		@end_time = @begin_time + new_duration + @answer_duration



	skip: ->
		@new_question() unless @attempt

	next: ->
		if @time() > @end_time - @answer_duration and !@generating_question
			@new_question() unless @attempt

	emit: (name, data) ->
		io.sockets.in(@name).emit name, data

	finish: ->
		@set_time @end_time

	end_buzz: (session) -> #killit, killitwithfire
		return unless @attempt?.session is session
		# touch the user in weird places
		@touch @attempt.user
		unless @attempt.prompt
			@clear_timeout()
			@attempt.done = true
			@attempt.correct = checkAnswer @attempt.text, @answer, @question
			do_prompt = false
			
			if @attempt.correct is 'prompt'
				do_prompt = true
				@attempt.correct = false
			
			if Math.random() > 0.99 and @attempt.correct is false
				do_prompt = true

			log 'buzz', [@name, @attempt.user + '-' + @users[@attempt.user].name, @attempt.text, @answer, @attempt.correct]
			# conditionally set this based on stuff
			if do_prompt is true
				@attempt.correct = "prompt" # quasi hack i know

				@sync() # sync to create a new line in the annotats

				@attempt.prompt = true

				@attempt.done = false
				@attempt.realTime = @serverTime()
				@attempt.start = @time()
				@attempt.text = ''
				@attempt.duration = 10 * 1000

				io.sockets.in(@name).emit 'log', {user: @attempt.user, verb: "won the lottery, hooray! 1% of buzzes which would otherwise be deemed wrong are randomly selected to be prompted, that's because the user interface for prompts has been developed (and thus needs to be tested), but the answer checker algorithm isn't smart enough to actually give prompts."}
				
				@timeout @serverTime, @attempt.realTime + @attempt.duration, =>
					@end_buzz session
			@sync()
		else
			# io.sockets.in(@name).emit 'log', {user: @attempt.user, verb: "lost prompt powers"}
			@attempt.done = true
			@attempt.correct = checkAnswer @attempt.text, @answer, @question
			
			if @attempt.correct is 'prompt'
				@attempt.correct = false

			@sync()

		if @attempt.done
			# io.sockets.in(@name).emit 'log', {user: @attempt.user, verb: "finished buzzing"}
			@unfreeze()
			if @attempt.correct
				@users[@attempt.user].correct++
				if @attempt.early 
					@users[@attempt.user].early++
				@finish()
			else # incorrect
				if @attempt.interrupt
					@users[@attempt.user].interrupts++
				
				buzzed = 0
				pool = 0
				for id, user of @users when id[0] isnt "_" # skip secret ninja
					if user.sockets.length > 0 and (new Date - user.last_action) < 1000 * 60 * 10
						if user.times_buzzed >= @max_buzz and @max_buzz
							buzzed++
						pool++
				if @max_buzz
					# console.log 'people buzzed', buzzed, 'of', pool
					if buzzed >= pool 
						@finish() # if everyone's buzzed and nobody can buzz, then why continue reading

			journal @name
			@attempt = null #g'bye
			@sync(1) #two syncs in one request!


	buzz: (user, fn) -> #todo, remove the callback and replace it with a sync listener
		@touch user
		if @max_buzz and @users[user].times_buzzed >= @max_buzz
			# console.log @max_buzz
			fn 'THE BUZZES ARE TOO DAMN HIGH' if fn
			io.sockets.in(@name).emit 'log', {user: user, verb: 'has already buzzed'}

		else if @attempt is null and @time() <= @end_time
			fn 'http://www.whosawesome.com/' if fn
			session = Math.random().toString(36).slice(2)
			early_index = @question.replace(/[^ \*]/g, '').indexOf('*')


			@attempt = {
				user: user,
				realTime: @serverTime(), # oh god so much time crap
				start: @time(),
				duration: 8 * 1000,
				session, # generate 'em server side 
				text: '',
				early: early_index != -1 and @time() < @begin_time + @cumulative[early_index],
				interrupt: @time() < @end_time - @answer_duration,
				done: false
			}

			@users[user].times_buzzed++
			@users[user].guesses++
			
			@freeze()
			@sync(1) #partial sync
			@timeout @serverTime, @attempt.realTime + @attempt.duration, =>
				@end_buzz session
		else
			io.sockets.in(@name).emit 'log', {user: user, verb: 'lost the buzzer race'}
			fn 'THE GAME' if fn

	guess: (user, data) ->
		@touch user
		if @attempt?.user is user
			@attempt.text = data.text
			# lets just ignore the input session attribute
			# because that's more of a chat thing since with
			# buzzes, you always have room locking anyway
			if data.done
				# do done stuff
				# console.log 'omg finals clubs are so cool ~ zuck'
				@end_buzz @attempt.session
			else
				@sync()

	sync: (level = 0) ->
		data = {
			real_time: +new Date #,
			# voting: {}
		}
		# voting = ['skip', 'pause', 'unpause']
		# for action in voting
		# 	yay = 0
		# 	nay = 0
		# 	actionvotes = []
		# 	for id of @users
		# 		vote = @users[id][action]
		# 		if vote is 'yay'
		# 			yay++
		# 			actionvotes.push id
		# 		else
		# 			nay++
		# 	# console.log yay, 'yay', nay, 'nay', action
		# 	if actionvotes.length > 0
		# 		data.voting[action] = actionvotes
		# 	# console.log yay, nay, "VOTES FOR", action
		# 	if yay / (yay + nay) > 0
		# 		# client.del(action) for client in io.sockets.clients(@name)
		# 		delete @users[id][action] for id of @users
		# 		this[action]()
		
		blacklist = ["question", "answer", "timing", "voting", "info", "cumulative", "users", "question_schedule", "history", "__timeout", "generating_question"]
		user_blacklist = ["sockets"]
		for attr of this when typeof this[attr] != 'function' and attr not in blacklist
			data[attr] = this[attr]

		if level >= 1
			data.users = for id of @users when !@users[id].ninja
				user = {}
				for attr of @users[id] when attr not in user_blacklist
					user[attr] = @users[id][attr] 
				user.online = @users[id].sockets.length > 0
				user

		if level >= 2
			data.question = @question
			data.answer = @answer
			data.timing = @timing
			data.info = @info

		if level >= 3
			data.categories = remote.getCategories()
			data.difficulties = remote.getDifficulties()
			
		io.sockets.in(@name).emit 'sync', data
	
	journal_backup: ->
		# this is like a simplified sync
		data = {}
		# user data!
		user_blacklist = ["sockets"]
		data.users = for id of @users
			user = {}
			for attr of @users[id] when attr not in user_blacklist
				user[attr] = @users[id][attr]
			user
		# global room settings
		settings = ["name", "difficulty", "category", "rate", "answer_duration", "max_buzz"]
		for field in settings
			data[field] = @[field]
		# actually save stuff
		return data



sha1 = (text) ->
	hash = crypto.createHash('sha1')
	hash.update(text)
	hash.digest('hex')

journal_config = {
		host: 'localhost',
		port: 15865
	}

log_config = {
		host: 'localhost',
		port: 18228
	}

if app.settings.env isnt 'development'
	log_config = remote.deploy.log
	journal_config = remote.deploy.journal
	console.log 'set to deployment defaults'

http = require('http')
log = (action, obj) ->
	# no logs in dev
	return if app.settings.env is 'development'

	req = http.request log_config, ->
		# console.log "saved log"
	req.on 'error', ->
		console.log "logging error"
	req.write((+new Date) + ' ' + action + ' ' + JSON.stringify(obj) + '\n')
	req.end()

log 'server_restart', {}



journal_queue = {}
journal = (name) ->
	journal_queue[name] = +new Date


process_journal_queue = ->
	room_names = Object.keys(journal_queue).sort (a, b) -> journal_queue[a] - journal_queue[b]
	return if room_names.length is 0
	first = room_names[0]
	delete journal_queue[first]
	if first of rooms
		partial_journal first
	else
		console.log 'processing', first

setInterval process_journal_queue, 1000

partial_journal = (name) ->
	# return if app.settings.env is 'development'
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
	req.write(JSON.stringify(rooms[name].journal_backup()))
	req.end()

full_journal_sync = ->
	backup = for name, room of rooms
		room.journal_backup()
	journal_config.path = '/full_sync'
	journal_config.method = 'POST'
	req = http.request journal_config, (res) ->
		console.log "done full sync"
	req.on 'error', ->
		console.log "full sync error error"
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
			fields = ["difficulty", "category", "rate", "answer_duration", "max_buzz"]
			for name, data of json
				# console.log data
				unless name of rooms
					console.log 'restoring', name
					rooms[name] = new QuizRoom(name)
					room = rooms[name]
					for user in data.users
						id = user.id
						room.users[id] = user
						room.users[id].sockets = []

					for field in fields
						room[field] = data[field]
			console.log 'restored journal'
			callback() if callback
	req.on 'error', ->
		console.log "Journal not accessible. Starting with defaults."
		callback() if callback
	req.end()


io.sockets.on 'connection', (sock) ->
	# read the headers and parse them with library functions
	headers = sock.handshake.headers
	return sock.disconnect() unless headers.referer and headers.cookie
	config = url.parse(headers.referer)

	if config.host isnt 'protobowl.com' and app.settings.env isnt 'development'
		console.log "Sending Upgrade Request", headers.referer
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
	room_name = config.pathname.replace(/\//g, '')
	publicID = sha1(cookie.protocookie + room_name)
	publicID = "__secret_ninja" if is_ninja
	publicID += "_god" if is_god
	# create the room if it doesn't exist
	rooms[room_name] = new QuizRoom(room_name) unless rooms[room_name]
	room = rooms[room_name]
	existing_user = (publicID of room.users)
	room.add_socket publicID, sock.id
	# actually join the room socket
	if is_god
		sock.join r_name for r_name of rooms
	else
		sock.join room_name
	# look up this user in the room
	user = room.users[publicID]
	if is_ninja
		user.ninja = true
		user.name = publicID
	# give the user a stupid name
	user.name ||= names.generateName()
	# tell the user of his new moniker
	sock.emit 'joined', {
		id: publicID,
		name: user.name
	}
	# tell that there's a new person at the partaay
	room.sync(3)
	room.emit 'log', {user: publicID, verb: 'joined the room'} unless is_ninja
	# detect if the server had been recently restarted
	if new Date - uptime_begin < 1000 * 60 and existing_user
		sock.emit 'log', {verb: 'The server has recently been restarted. Your scores may have been preserved in the journal (however, restoration is experimental and not necessarily reliable). The journal does not record the current question, chat messages, or current attempts, so you may need to manually advance a question. This may have been part of a server or client software update, or the result of an unexpected server crash. We apologize for any inconvienience this may have caused.'}
		sock.emit 'application_update', +new Date # check for updates in case it was an update

	sock.on 'join', (data, fn) ->
		sock.emit 'application_update', +new Date
		sock.emit 'log', {user: publicID, verb: 'is using an outdated (and incompatible) version of ProtoBowl'}
		sock.disconnect()
		
	sock.on 'disco', (data) ->
		if data.old_socket and io.sockets.socket(data.old_socket)
			io.sockets.socket(data.old_socket).disconnect()

	sock.on 'echo', (data, callback) =>
		callback +new Date

	sock.on 'rename', (name) ->
		room.users[publicID].name = name.slice(0, 140) # limit on username size, tweet sized
		room.touch(publicID)
		room.sync(1)
		journal room.name

	sock.on 'skip', (vote) ->
		if room and !room.attempt
			room.skip()
			room.emit 'log', {user: publicID, verb: 'skipped a question'}

	sock.on 'finish', (vote) ->
		if room and !room.attempt
			room.finish()
			room.sync(1)

	sock.on 'next', ->
		room.next() # its a more restricted kind of skip

	sock.on 'pause', (vote) ->
		room.pause()
		room.sync()

	sock.on 'unpause', (vote) ->
		room.unpause()
		room.sync()

	sock.on 'difficulty', (data) ->
		room.difficulty = data
		room.reset_schedule()
		room.sync()
		journal room.name
		log 'difficulty', [room.name, publicID + '-' + room.users[publicID].name, room.difficulty]
		remote.countQuestions room.difficulty, room.category, (count) ->
			room.emit 'log', {user: publicID, verb: 'set difficulty to ' + (data || 'everything') + ' (' + count + ' questions)'}
		

	sock.on 'category', (data) ->
		room.category = data
		room.reset_schedule()
		room.sync()
		journal room.name
		log 'category', [room.name, publicID + '-' + room.users[publicID].name, room.category]
		remote.countQuestions room.difficulty, room.category, (count) ->
			room.emit 'log', {user: publicID, verb: 'set category to ' + (data.toLowerCase() || 'potpourri') + ' (' + count + ' questions)'}
		
	sock.on 'max_buzz', (data) ->
		room.max_buzz = data
		room.sync()
		journal room.name

	sock.on 'show_typing', (data) ->
		room.users[publicID].show_typing = data
		room.sync(2)
		journal room.name

	sock.on 'sounds', (data) ->
		room.users[publicID].sounds = data
		room.sync(2)
		journal room.name

	sock.on 'speed', (data) ->
		room.set_speed data
		room.sync()
		journal room.name

	sock.on 'buzz', (data, fn) ->
		room.buzz(publicID, fn) if room

	sock.on 'guess', (data) ->
		room.guess(publicID, data)  if room


	sock.on 'chat', ({text, done, session}) ->
		room.touch publicID
		log 'chat', [room.name, publicID + '-' + room.users[publicID].name, text] if done
		room.emit 'chat', {text: text, session:  session, user: publicID, done: done, time: room.serverTime()}

	sock.on 'resetscore', ->
		u = room.users[publicID]
		
		room.emit 'log', {user: publicID, verb: "was reset from #{u.correct} correct of #{u.guesses} guesses"}

		u.seen = u.interrupts = u.guesses = u.correct = u.early = 0
		room.sync(1)
		journal room.name

	sock.on 'report_question', (data) ->
		data.room = room.name
		data.user = publicID + '-' + room.users[publicID].name
		log 'report_question', data

	sock.on 'report_answer', (data) ->
		data.room = room.name
		data.user = publicID + '-' + room.users[publicID].name
		log 'report_answer', data

	sock.on 'check_rooms', (checklist, fn) ->
		output = {}
		for check_name in checklist
			output[check_name] = 0
			if rooms[check_name]?.users
				for uid, udat of rooms[check_name].users
					if udat.sockets.length > 0 and new Date - udat.last_action < 10 * 60 * 1000
						output[check_name]++
		fn output


	sock.on 'disconnect', ->
		# console.log "someone", publicID, sock.id, "left"
		log 'disconnect', [room.name, publicID, sock.id]

		room.del_socket publicID, sock.id
		room.sync(1)
		if room.users[publicID].sockets.length is 0 and !room.users[publicID].ninja
			room.emit 'log', {user: publicID, verb: 'left the room'}


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
		overcrowded_room = Object.keys(room.users).length > 20
		oldest_user = ''
		if overcrowded_room
			oldest = Object.keys(room.users).sort (a, b) -> 
				return room.users[a].last_action - room.users[b].last_action
			oldest_user = oldest[0]

		for username, user of room.users
			len++
			if user.sockets.length is 0
				evict_user = false
				if overcrowded_room and username is oldest_user
					evict_user = true
				if (user.last_action < new Date - threshold) or evict_user or
				(user.last_action < new Date - 1000 * 60 * 30 and user.guesses is 0) or
				(overcrowded_room and user.correct < 10 and user.last_action < new Date - 1000 * 60 * 30)
					# console.log 'kicking user of inactivity', user.name
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
			console.log 'removing empty room', name
			delete rooms[name]
			reaped.rooms++

uptime_begin = +new Date

app.post '/stalkermode/update', (req, res) ->
	console.log 'triggering application update check'
	io.sockets.emit 'application_update', +new Date
	res.redirect '/stalkermode'

app.post '/stalkermode/forceupdate', (req, res) ->
	console.log 'forcing application update'
	io.sockets.emit 'application_force_update', +new Date
	res.redirect '/stalkermode'


app.post '/stalkermode/kickoffline', (req, res) ->
	clearInactive 1000 * 5 # five seconds
	res.redirect '/stalkermode'


app.post '/stalkermode/fullsync', (req, res) ->
	full_journal_sync()
	res.redirect '/stalkermode'

app.post '/stalkermode/crash', (req, res) ->
	res.redirect '/stalkermode'
	setTimeout ->
		throw 'fatal error'
	, 1000

app.post '/stalkermode/announce', express.bodyParser(), (req, res) ->
	io.sockets.emit 'chat', {
		text: req.body.message, 
		session: Math.random().toString(36).slice(3), 
		user: '__' + req.body.name, 
		done: true,
		time: +new Date
	}
	res.redirect '/stalkermode'



app.get '/stalkermode', (req, res) ->
	if req.headers.host isnt "protobowl.com" and app.settings.env isnt 'development'
		options = url.parse(req.url)
		options.host = 'protobowl.com'
		res.writeHead 301, {Location: url.format(options)}
		res.end()
		return
	util = require('util')
	res.render 'admin.jade', {
		env: app.settings.env,
		mem: util.inspect(process.memoryUsage()),
		start: uptime_begin,
		reaped: reaped,
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
	if name isnt "offline"
		# console.log 'HOST', req.headers.host, req.url
		if req.headers.host isnt "protobowl.com" and app.settings.env isnt 'development'
			options = url.parse(req.url)
			options.host = 'protobowl.com'
			res.writeHead 301, {Location: url.format(options)}
			res.end()
			return

	# init_channel name
	# console.log "Requested /#{req.params.channel}", req.headers['user-agent']
	res.render 'room.jade', { name, env: app.settings.env }


port = process.env.PORT || 5000

restore_journal ->
	app.listen port, ->
		console.log "listening on port", port

