express = require('express')
app = express.createServer express.logger()
io = require('socket.io').listen(app)
io.configure ->
	# now this is meant to run on nodejitsu rather than heroku
	#io.set "transports", ["xhr-polling"]
	#io.set "polling duration", 10
	io.set "log level", 2

fs = require('fs')
damlev = require('./levenshtein').levenshtein
syllables = require('./syllable').syllables

questions = []

fs.readFile 'sample.txt', 'utf8', (err, data) ->
	throw err if err
	questions = (JSON.parse(line) for line in data.split("\n"))
	# questions = [{question: "to galvanization to galvanization to galvanization to galvanization to galvanization to galvanization to galvanization"}]

app.set 'views', __dirname
app.set 'view options', {
  layout: false
}
app.use require('less-middleware')({src: __dirname})
app.use express.static(__dirname)

# Array::amap = (fn, callback) ->
# 	count = 0
# 	result = []
# 	len = @length
# 	for i in [0...len]
# 		el = this[i]
# 		do (i, el) ->
# 			fields = 0
# 			object = {}
# 			fn el, (field) ->
# 				fields++
# 				(value) ->
# 					object[field] = value
# 					fields--
# 					if fields.length is 0
# 						result[i] = object
# 						count++
# 						callback(result) if count is len
# 	null


cumsum = (list, rate) ->
	sum = 0
	for num in list
		sum += Math.round(num) * rate #always round!


class QuizRoom
	constructor: (name) ->
		@name = name
		@time_offset = 0
		@new_question()
		@attempt = null
		@freeze()

	time: ->
		return if @time_freeze then @time_freeze else new Date - @time_offset

	freeze: ->
		@time_freeze = @time()

	unfreeze: ->
		if @time_freeze
			@time_offset = new Date - @time_freeze
			@time_freeze = 0

	new_question: ->
		@attempt = null

		answer_time = 1000 * 5
		@begin_time = @time()
		question = questions[Math.floor(questions.length * Math.random())]
		@info = {
			category: question.category, 
			difficulty: question.difficulty, 
			tournament: question.tournament, 
			num: question.question_num, 
			year: question.year, 
			round: question.round
		}
		@question = question.question
			.replace(/FTP/g, 'For 10 points')
			.replace(/^\[.*?\]/, '')
			.replace(/\n/g, ' ')
		@answer = question.answer
			.replace(/\<\w\w\>/g, '')
			.replace(/\[\w\w\]/g, '')
		@timing = {
			list: syllables(word) for word in @question.split(" "),
			rate: 1000 * 60 / 2 / 300
		}
		{list, rate} = @timing
		cumulative = cumsum list, rate
		@end_time = @begin_time + cumulative[cumulative.length - 1] + answer_time
		@sync(true)

	skip: ->
		@new_question()

	emit: (name, data) ->
		io.sockets.in(@name).emit name, data

	buzz: (user, fn) ->
		if @attempt is null
			@attempt = {
				user: user,
				start: +new Date, # oh god so much time crap
				duration: 5 * 1000,
				session: Math.random().toString(36).slice(2), # generate 'em server side 
				guess: ''
			}
			fn 'http://www.whosawesome.com/'
			@freeze()
			@sync() #partial sync
		else if @owner is user
			fn 'wai?'
		else
			fn 'narp'

	guess: (user, data) ->
		if @attempt?.user is user
			@attempt.text = data.text
			# lets just ignore the input session attribute
			# because that's more of a chat thing since with
			# buzzes, you always have room locking anyway
			if data.final
				# do final stuff
				console.log 'omg final clubs are so cool ~ zuck'
			@sync()		

	sync: (full) ->
		data = {
			real_time: +new Date,
			voting: {}
		}
		voting = ['skip', 'freeze', 'unfreeze']
		for action in voting
			yay = 0
			nay = 0
			actionvotes = []
			for client in io.sockets.clients(@name)
				vote = client.store.data[action]
				if vote is 'yay'
					yay++
					actionvotes.push client.id
				else
					nay++
			# console.log yay, 'yay', nay, 'nay', action
			if actionvotes.length > 0
				data.voting[action] = actionvotes
			# console.log yay, nay, "VOTES FOR", action
			if yay / (yay + nay) > 0
				client.del(action) for client in io.sockets.clients(@name)
				this[action]()
		blacklist = ["name", "question", "answer", "timing", "voting"]
		for attr of this when typeof this[attr] != 'function' and attr not in blacklist
			data[attr] = this[attr]
		if full
			data.question = @question
			data.answer = @answer
			data.timing = @timing
			data.users = for client in io.sockets.clients(@name)
				{
					id: client.id,
					name: client.store.data.name
				}

		io.sockets.in(@name).emit 'sync', data



rooms = {}
io.sockets.on 'connection', (sock) ->
	room = null
	sock.on 'join', (data) ->
		if data.old_socket and io.sockets.socket(data.old_socket)
			io.sockets.socket(data.old_socket).disconnect()

		room_name = data.room_name
		sock.set 'name', data.public_name
		sock.join room_name
		rooms[room_name] = new QuizRoom(room_name) unless room_name of rooms
		room = rooms[room_name]
		room.sync(true)
		room.emit 'introduce', {user: sock.id}

	sock.on 'echo', (data, callback) =>
		callback +new Date

	sock.on 'rename', (name) ->
		sock.set 'name', name
		room.sync(true)

	sock.on 'skip', (vote) ->
		sock.set 'skip', vote
		room.sync()

	sock.on 'pause', (vote) ->
		sock.set 'freeze', vote
		room.sync()

	sock.on 'unpause', (vote) ->
		sock.set 'unfreeze', vote
		room.sync()

	sock.on 'buzz', (data, fn) ->
		room.buzz sock.id, fn

	sock.on 'guess', (data) ->
		room.guess sock.id, data

	sock.on 'chat', ({text, final, session}) ->
		room.emit 'chat', {text: text, session:  session, user: sock.id, final: final}

	sock.on 'disconnect', ->
		id = sock.id
		console.log "someone", id, "left"
		setTimeout ->
			console.log !!room, 'rooms'
			if room
				room.sync(true)
				room.emit 'leave', {user: id}
		, 100


app.get '/:channel', (req, res) ->
	name = req.params.channel
	# init_channel name
	res.render 'index.jade', { name }

app.get '/', (req, res) ->
	people = 'kirk,feynman,huxley,robot,ben,batman,panda,pinkman,superhero,celebrity,traitor,alien,lemon,police,whale,astronaut'
	verb = 'on,enveloping,eating,drinking,in,near,sleeping,destruction,arresting,cloning,around,jumping,scrambling'
	noun = 'mountain,drugs,house,asylum,elevator,scandal,planet,school,brick,lamp,water,paper,friend,toilet,airplane,cow,pony'
	pick = (list) -> 
		n = list.split(',')
		n[Math.floor(n.length * Math.random())]
	res.redirect '/' + pick(people) + "-" + pick(verb) + "-" + pick(noun)


port = process.env.PORT || 5000
app.listen port, ->
	console.log "listening on", port

