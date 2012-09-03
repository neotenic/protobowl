express = require('express')
fs = require('fs')
checkAnswer = require('./lib/answerparse').checkAnswer
syllables = require('./lib/syllable').syllables
parseCookie = require('express/node_modules/connect').utils.parseCookie
crypto = require('crypto')

app = express.createServer() 
io = require('socket.io').listen(app)

Cookies = require('cookies')
app.use require('less-middleware')({src: __dirname})
app.use express.favicon()
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
		return if filename in ["offline.appcache", "web.js", "web.coffee"] or /\.css$/.test(filename)
		console.log "changed file", filename
		unless scheduledUpdate
			scheduledUpdate = setTimeout updateCache, 500

	fs.watch __dirname, watcher
	fs.watch __dirname + "/lib", watcher
	fs.watch __dirname + "/less", watcher
	

setTimeout ->
	# when the server reboots, check for update in clients
	io.sockets.emit 'application_update', +new Date
, 1000 * 30

io.configure ->
	# now this is meant to run on nodejitsu rather than heroku
	#io.set "transports", ["xhr-polling"]
	#io.set "polling duration", 10
	io.set "log level", 2
	# io.set "connect timeout", 2000
	# io.set "max reconnection attempts", 1
	io.set "authorization", (data, fn) ->
		console.log data
		if !data.headers.cookie
			return fn 'No cookie header', false
		cookie = parseCookie(data.headers.cookie)
		if cookie and cookie['protocookie']
			console.log "GOT COOKIE", data.headers.cookie
			data.sessionID = cookie['protocookie']
			fn null, true #woot
		fn 'No cookie found', false



app.set 'views', __dirname
app.set 'view options', {
  layout: false
}

mongoose = require('mongoose')
# oh noes, plz dont hacxxors me
db = mongoose.createConnection 'mongodb://nodejitsu:87a9e43f3edd8929ef1e48ede1f0fc6d@alex.mongohq.com:10056/nodejitsudb560367656797'

QuestionSchema = new mongoose.Schema {
	category: String,
	num: Number,
	tournament: String,
	question: String,
	answer: String,
	difficulty: String,
	year: Number,
	round: String,
	random_loc: {type: [Number, Number], index: '2d'}
}

Question = db.model 'Question', QuestionSchema

fisher_yates = (i) ->
	return [] if i is 0
	arr = [0...i]
	while --i
		j = Math.floor(Math.random() * (i+1))
		[arr[i], arr[j]] = [arr[j], arr[i]] 
	arr

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

# getQuestion = (last_answer, difficulty, category, cb) ->
# 	# countQuestions difficulty, category, (count) ->
# 	# 	if count < 1000
# 	# TODO: use fisher yates

# 	num_attempts = 0

# 	runQuery = ->
# 		rand = Math.random()
# 		num_attempts++
# 		criterion = {
# 			random_loc: {
# 				$near: [rand, 0]
# 			}
# 		}
# 		if difficulty
# 			criterion.difficulty = difficulty
# 		if category
# 			criterion.category = category

# 		Question.findOne criterion, (err, doc) ->
# 			console.log rand, num_attempts, doc
# 			if doc is null
# 				cb error_question
# 				return
# 			if doc.answer is last_answer and num_attempts < 10
# 				runQuery()
# 			else
# 				cb(doc) if cb
# 	runQuery()


getQuestion = (difficulty, category, cb) ->
	rand = Math.random()
	criterion = {
		random_loc: {
			$near: [rand, 0]
		}
	}
	if difficulty
		criterion.difficulty = difficulty
	if category
		criterion.category = category

	Question.findOne criterion, (err, doc) ->
		if doc is null
			cb error_question
			return
		console.log "RANDOM PICK", rand, doc.random_loc[0], doc.random_loc[0] - rand
		cb(doc) if cb


countCache = {}
countQuestions = (difficulty, category, cb) ->
	id = difficulty+'-'+category
	if id of countCache
		return cb(countCache[id])
	criterion = {}
	if difficulty
		criterion.difficulty = difficulty
	if category
		criterion.category = category
	Question.count criterion, (err, doc) ->
		countCache[id] = doc
		cb(doc)

# Question.collection.drop()
# questions = []
# count = 0
# fs.readFile '../quiz/questions.json', 'utf8', (err, data) ->
# 	throw err if err
# 	# questions = (JSON.parse(line) for line in data.split("\n"))

# 	for line in data.split("\n")
# 		# console.log line
# 		continue if line is ''
# 		j = JSON.parse(line)
# 		silence = new Question {
# 			category: j.category,
# 			num: j.question_num,
# 			tournament: j.tournament,
# 			question: j.question,
# 			difficulty: j.difficulty,
# 			answer: j.answer,
# 			year: j.year,
# 			round: j.round,
# 			random_loc: [Math.random(), 0]
# 		}
# 		silence.save (err) ->
# 			console.log 'meow', count++
# 	# questions = (q for q in questions when q.question.indexOf('*') != -1)
# 	# questions = [{answer: "ponies", question: "tu tu to galvanizationationationationation to galvanization to galvin to galvanization to galvanization two galvanization moo galvanization"}]


categories = []
difficulties = []

Question.collection.distinct 'category', (err, docs) ->
	categories = docs

Question.collection.distinct 'difficulty', (err, docs) ->
	difficulties = docs

Question.collection.ensureIndex { random: 1, category: 1, difficulty: 1, random_loc: '2d' }

cumsum = (list, rate) ->
	sum = 0 #start nonzero, allow pause before rendering
	for num in [5].concat(list).slice(0, -1)
		sum += Math.round(num) * rate #always round!


class QuizRoom
	constructor: (name) ->
		@name = name
		@answer_duration = 1000 * 5
		@time_offset = 0
		@rate = 1000 * 60 / 5 / 200
		@__timeout = -1

		@freeze()
		@new_question()
		@users = {}
		@difficulty = ''
		@category = ''

		# the following are nasty database hacks
		@question_schedule = []
		@history = []

	# this function really doesn't belong in here, because it sort of screws
	# up the database abstractions, but this app wasn't even supposed to have
	# a database, so I don't really care how disgustingly un-cool and bad
	# this is
	reset_schedule: ->
		countQuestions @difficulty, @category, (num) =>
			if num < 300
				@question_schedule = fisher_yates(num)
			else
				@question_schedule = []

	get_question: (cb) ->
		num_attempts = 0
		attemptQuestion = =>
			num_attempts++
			getQuestion @difficulty, @category, (question) =>
				# console.log(typeof question._id, @history,  "ATTEMPTS", num_attempts)
				if question._id.toString() in @history and num_attempts < 15
					return attemptQuestion()
				@history.splice 100
				@history.splice 0, 0, question._id.toString()
				cb(question)

		countQuestions @difficulty, @category, (num) =>
			if num < 300
				if @question_schedule.length is 0
					@question_schedule = fisher_yates(num)

				index = @question_schedule.shift()
				criterion = {}
				if @difficulty
					criterion.difficulty = @difficulty
				if @category
					criterion.category = @category
				console.log 'FISHER YATES SCHEDULED', index, 'REMAINING', @question_schedule.length
				Question.find(criterion).skip(index).limit(1).exec (err, docs) ->
					cb(docs[0] || error_question)

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
				last_action: 0
			}
		user = @users[id]
		user.id = id
		user.last_action = @serverTime()
		unless socket in user.sockets
			user.sockets.push socket

	vote: (id, action, val) ->
		# room.add_socket publicID, sock.id
		@users[id][action] = val
		@sync()

	touch: (id) ->
		@users[id].last_action = @serverTime()

	del_socket: (id, socket) ->
		user = @users[id]
		if user
			user.sockets = (sock for sock in user.sockets when sock isnt socket)

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

			@begin_time = @time()
			@timing = (syllables(word) + 1 for word in @question.split(" "))
			@set_speed @rate #do the math with speeds
			# @cumulative = cumsum @timing, @rate #todo: comment out
			# @end_time = @begin_time + @cumulative[@cumulative.length - 1] + @answer_duration
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


	end_buzz: (session) -> #killit, killitwithfire
		return unless @attempt?.session is session
		# touch the user in weird places
		@touch @attempt.user
		unless @attempt.prompt
			@clear_timeout()
			@attempt.done = true
			@attempt.correct = checkAnswer @attempt.text, @answer, @question
			log 'buzz', [@name, @attempt.user, @attempt.text, @answer, @attempt.correct]
			# conditionally set this based on stuff
			if Math.random() > 0.999
				@attempt.correct = "prompt" # quasi hack i know

				@sync() # sync to create a new line in the annotats

				@attempt.prompt = true

				@attempt.done = false
				@attempt.realTime = @serverTime()
				@attempt.start = @time()
				@attempt.text = ''
				@attempt.duration = 10 * 1000

				io.sockets.in(@name).emit 'log', {user: @attempt.user, verb: "won the lottery, hooray! 0.1% of all buzzes are randomly selected to be prompted, that's because the user interface for prompts has been developed (and thus needs to be tested), but the answer checker algorithm isn't smart enough to actually give prompts."}
				
				@timeout @serverTime, @attempt.realTime + @attempt.duration, =>
					@end_buzz session
			@sync()
		else
			# io.sockets.in(@name).emit 'log', {user: @attempt.user, verb: "lost prompt powers"}
			@attempt.done = true
			@attempt.correct = checkAnswer @attempt.text, @answer, @question

			@sync()

		if @attempt.done
			# io.sockets.in(@name).emit 'log', {user: @attempt.user, verb: "finished buzzing"}
			@unfreeze()
			if @attempt.correct
				@users[@attempt.user].correct++
				if @attempt.early 
					@users[@attempt.user].early++
				@set_time @end_time
			else if @attempt.interrupt
				@users[@attempt.user].interrupts++
			@attempt = null #g'bye
			@sync(1) #two syncs in one request!


	buzz: (user, fn) -> #todo, remove the callback and replace it with a sync listener
		@touch user
		if @attempt is null and @time() <= @end_time
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

			@users[user].guesses++
			
			@freeze()
			@sync(1) #partial sync
			@timeout @serverTime, @attempt.realTime + @attempt.duration, =>
				@end_buzz session
		else
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
				console.log 'omg done clubs are so cool ~ zuck'
				@end_buzz @attempt.session
			else
				@sync()

	sync: (level = 0) ->
		data = {
			real_time: +new Date,
			voting: {}
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
		
		blacklist = ["name", "question", "answer", "timing", "voting", "info", "cumulative", "users", "question_schedule", "history", "__timeout"]
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
			data.categories = categories
			data.difficulties = difficulties
			
		io.sockets.in(@name).emit 'sync', data


sha1 = (text) ->
	hash = crypto.createHash('sha1')
	hash.update(text)
	hash.digest('hex')


http = require('http')
log = (action, obj) ->
	req = http.request {
		host: 'inception.pi.antimatter15.com',
		port: 3140,
		path: '/log',
		method: 'POST'
	}, ->
		console.log "saved log"
	req.on 'error', ->
		console.log "logging error"
	req.write((+new Date) + ' ' + action + ' ' + JSON.stringify(obj) + '\n')
	req.end()


rooms = {}
io.sockets.on 'connection', (sock) ->
	sessionID = sock.handshake.sessionID
	publicID = null
	room = null

	sock.on 'join', (data, fn) ->
		if data.old_socket and io.sockets.socket(data.old_socket)
			io.sockets.socket(data.old_socket).disconnect()
		
		room_name = data.room_name
		if data.ninja
			publicID = '__secret_ninja' # no spaces
		else
			publicID = sha1(sessionID + room_name) #preserves a sense of privacy
		
		if data.god
			publicID += "_god"
			for room of rooms
				sock.join room
		else
			sock.join room_name

		rooms[room_name] = new QuizRoom(room_name) unless room_name of rooms
		room = rooms[room_name]
		room.add_socket publicID, sock.id
		if data.ninja
			room.users[publicID].ninja = true
			room.users[publicID].name = publicID

		unless 'name' of room.users[publicID]
			room.users[publicID].name = require('./lib/names').generateName()
		fn {
			id: publicID,
			name: room.users[publicID].name
		}
		room.sync(3)
		unless data.ninja
			room.emit 'log', {user: publicID, verb: 'joined the room'}

	sock.on 'echo', (data, callback) =>
		callback +new Date

	sock.on 'rename', (name) ->
		# sock.set 'name', name
		if room
			room.users[publicID].name = name
			room.touch(publicID)
			room.sync(1)

	sock.on 'skip', (vote) ->
		# sock.set 'skip', vote
		# room.add_socket publicID, sock.id
		# room.users[publicID].skip = vote
		# room.sync() if room
		# room.vote publicID, 'skip', vote
		if room
			room.skip()
			room.emit 'log', {user: publicID, verb: 'skipped a question'}

	sock.on 'next', ->
		room.next() # its a more restricted kind of skip

	sock.on 'pause', (vote) ->
		# sock.set 'pause', vote
		# room.users[publicID].pause = vote
		
		# room.vote publicID, 'pause', vote
		if room
			room.pause()
			room.sync()

	sock.on 'unpause', (vote) ->
		# sock.set 'unpause', vote
		# room.vote publicID, 'unpause', vote
		room.unpause()
		# room.users[publicID].unpause = vote
		room.sync() if room

	sock.on 'difficulty', (data) ->
		room.difficulty = data
		room.reset_schedule()
		room.sync()
		log 'difficulty', [room.name, publicID, room.difficulty]
		countQuestions room.difficulty, room.category, (count) ->
			room.emit 'log', {user: publicID, verb: 'set difficulty to ' + (data || 'everything') + ' (' + count + ' questions)'}
		

	sock.on 'category', (data) ->
		if room
			room.category = data
			room.reset_schedule()
			room.sync()
			log 'category', [room.name, publicID, room.category]
			countQuestions room.difficulty, room.category, (count) ->
				room.emit 'log', {user: publicID, verb: 'set category to ' + (data.toLowerCase() || 'potpourri') + ' (' + count + ' questions)'}
		
	sock.on 'speed', (data) ->
		if room
			room.set_speed data
			room.sync()

	sock.on 'buzz', (data, fn) ->
		room.buzz(publicID, fn) if room

	sock.on 'guess', (data) ->
		room.guess(publicID, data)  if room

	sock.on 'chat', ({text, done, session}) ->
		if room
			room.touch publicID
			log 'chat', [room.name, publicID, text] if done
			room.emit 'chat', {text: text, session:  session, user: publicID, done: done, time: room.serverTime()}

	sock.on 'resetscore', ->
		if room and room.users[publicID]
			u = room.users[publicID]
			
			room.emit 'log', {user: publicID, verb: "was reset from #{u.correct} correct of #{u.guesses}"}

			u.interrupts = u.guesses = u.correct = u.early = 0
			room.sync(1)


	sock.on 'report_question', (data) ->
		log 'report_question', data

	sock.on 'report_answer', (data) ->
		log 'report_answer', data

	sock.on 'disconnect', ->
		# id = sock.id
		
		console.log "someone", publicID, sock.id, "left"
		if room
			log 'disconnect', [room.name, publicID, sock.id]

			room.del_socket publicID, sock.id
			room.sync(1)
			if room.users[publicID].sockets.length is 0 and !room.users[publicID].ninja
				room.emit 'log', {user: publicID, verb: 'left the room'}


setInterval ->
	clearInactive 1000 * 60 * 60 * 24 
, 1000 * 10 # every ten seconds


clearInactive = (threshold) ->
	# garbazhe collectour
	for name, room of rooms
		len = 0
		for username, user of room.users
			len++
			if user.sockets.length is 0
				if user.last_action < new Date - threshold or (user.last_action < new Date - 1000 * 60 * 30 and user.guesses is 0)
					console.log 'kicking user of inactivity', user.name
					len--
					delete room.users[username]
		if len is 0
			console.log 'removing empty room', name
			delete rooms[name]

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
	util = require('util')
	res.render 'admin.jade', {
		env: app.settings.env,
		mem: util.inspect(process.memoryUsage()),
		start: uptime_begin,
		rooms: rooms
	}


app.get '/new', (req, res) ->
	res.redirect '/' + require('./lib/names').generatePage()


app.get '/', (req, res) ->
	res.redirect '/lobby'


app.get '/:channel', (req, res) ->
	name = req.params.channel
	# init_channel name
	console.log "Requested /#{req.params.channel}", req.headers['user-agent']
	res.render 'index.jade', { name, env: app.settings.env }


port = process.env.PORT || 5000
app.listen port, ->
	console.log "listening on", port

