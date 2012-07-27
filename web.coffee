express = require('express')
app = express.createServer express.logger()
io = require('socket.io').listen(app)
io.configure ->
	io.set "transports", ["xhr-polling"]
	io.set "polling duration", 10
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




class QuizRoom
	constructor: (name) ->
		@name = name
		@time_offset = 0
		@new_question()
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
		@timing = {
			list: syllables(word) for word in @question.split(" "),
			rate: 1000 * 60 / 2 / 300
		}
		@sync(true)

	skip: ->
		@new_question()

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
			console.log yay, nay, "VOTES FOR", action
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

		console.log data
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

	sock.on 'disconnect', ->
		setTimeout ->
			room.sync(true) if room
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

