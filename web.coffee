express = require('express')
app = express.createServer express.logger()
io = require('socket.io').listen(app)
io.configure ->
	io.set "transports", ["xhr-polling"]
	io.set "polling duration", 10
	io.set "log level", 2


fs = require('fs')
damlev = require('./levenshtein').levenshtein

questions = []

fs.readFile 'sample.txt', 'utf8', (err, data) ->
	throw err if err
	questions = (JSON.parse(line) for line in data.split("\n"))
	# questions = [{question: "to galvanization to galvanization to galvanization to galvanization to galvanization to galvanization to galvanization"}]

app.set 'views', __dirname
app.set 'view options', {
  layout: false
}
app.use express.static(__dirname)

active_channels = {}
syllables = require('./syllable').syllables

cumsum = (list, rate) ->
	sum = 0
	for num in list
		sum += Math.round(num) * rate #always round!


class Channel 
	constructor: (name) ->
		console.log "initializing channel", name
		@ns = io.of(name)
		@timeOffset = 0
		@timeCallbacks = []
		@revealDelay = 2 * 1000
		@nextQuestion()
		@ns.on 'connection', (sock) =>
			@addUser(sock)

	onTime: (time, callback) ->
		@timeCallbacks.push [@getTime() + time, callback]
		@checkTime()

	checkTime: ->
		continuing = []
		execution_queue = []
		for [time, fn] in @timeCallbacks
			if time <= @getTime()
				execution_queue.push fn
			else
				setTimeout =>
					@checkTime()
				, time - @getTime()
				continuing.push [time, fn]
		@timeCallbacks = continuing
		fn() for fn in execution_queue

			

	getTime: ->
		if @timeFreeze
			return @timeFreeze
		else
			return +new Date - @timeOffset

	getTiming: ->
		{
			list: syllables(word) for word in @question.question.split(" "),
			rate: 1000 * 60 / 2 / 300
		}
		

	nextQuestion: ->
		@timeCallbacks = []
		@completed = false
		@timeFreeze = 0
		@countDuration = 0
		@countStart = 0
		@tableOwner = null
		@question = questions[Math.floor(questions.length * Math.random())]
		@question.question = @question.question
		.replace(/FTP/g, 'For 10 points')
		.replace(/^\[.*?\]/, '')
		.replace(/\n/g, ' ')
		delete @question.pKey
		@question.timing = @getTiming()
		@lastTime = @getTime()
		{list, rate} = @question.timing
		@ns.emit "sync", @synchronize(true)

		@onTime cumsum(list, rate).slice(-1)[0] + @revealDelay, =>
			setTimeout =>
				@nextQuestion()
			, 2000 #show the question for a few seconds

		
		


	buzz: (data, callback, sock) ->
		if @timeFreeze
			if sock is @tableOwner
				callback "you dont have too much time left!"
			else
				callback "you lost the game!"
		else
			@countDuration = 6 * 1000 # 10 seconds
			@countStart = +new Date #not that it's not server time!
			
			sock.name = data.name
			sock.guess = ""
			@tableOwner = sock

			@freeze()
			@freezeTimeout = setTimeout =>
				@unfreeze()
			, @countDuration
			
			callback "who's awesome? you are!" #tell the user he won the game

	freeze: ->
		@timeFreeze = @getTime() # freeze time at this point now
		@ns.emit "sync", @synchronize()
		


	unfreeze: ->
		if @timeFreeze
			clearTimeout @freezeTimeout
			@timeOffset = new Date - @timeFreeze
			@timeFreeze = 0
			@tableOwner = null
			@countDuration = 0
			@ns.emit "sync", @synchronize()
			console.log "time circuits", @timeOffset
		@checkTime()

	checkAnswer: (guess) ->
		a = guess.toLowerCase().replace(/[^a-z0-9]/g,'')
		b = @question.answer.toLowerCase()
		.replace(/\(.*\)/g, '')
		.replace(/\[.*\]/g, '')
		.replace(/[^a-z0-9]/g,'')
		return damlev(a, b) < 2

	guess: (data, callback, sock) ->
		if sock is @tableOwner
			sock.guess = data.guess
			if data.final is true
				@unfreeze()
				if @checkAnswer(data.guess)
					callback "yay"
					@completed = true
					@freeze()
					setTimeout =>
						@nextQuestion()
					, 2000

				else
					callback "nay"
			else
				callback "okay"
				@ns.emit "sync", @synchronize()
		else
			callback "not allowed to guess"

	addUser: (sock) ->
		console.log "Adding a new user to the channel"
		sock.emit 'sync', @synchronize(true)
		sock.on 'echo', (data, callback) =>
			callback +new Date
		sock.on 'disconnect', =>
			console.log "user disconnected"
		sock.on 'buzz', (data, callback) =>
			@buzz(data, callback, sock)
		sock.on 'guess', (data, callback) =>
			@guess(data, callback, sock)
		sock.on 'unpause', (data, callback) =>
			@unfreeze()
		sock.on 'pause', (data, callback) =>
			@freeze()
		sock.on 'skip', (data, callback) =>
			@completed = true
			@freeze()
			setTimeout =>
				@nextQuestion()
			, 2000


	synchronize: (all) ->
		data = {
			time: @getTime(), 
			lastTime: @lastTime, 
			revealDelay: @revealDelay, 
			tableOwner: @tableOwner?.name,
			completed: @completed,
			guess: @tableOwner?.guess,
			countDuration: Math.max(0, @countDuration - (new Date - @countStart)),
			timeFreeze: @timeFreeze
		}

		#only send the quesiton data if its necessary to keep the transactions
		#somewhat lightweight
		data.question = @question if all
		return data


# channelChecker = ->
# 	for channel of active_channels
# 		console.log channel
# 		if channel.getTime() > channel.nextTime


# setInterval channelChecker, 1000

init_channel = (name) ->
	unless name of active_channels
		active_channels[name] = new Channel(name)





io.sockets.on 'connection', (sock) ->
	console.log "got stuff as in connecting"

app.get '/:channel', (req, res) ->
	name = "/" + req.params.channel
	init_channel name
	res.render 'index.jade', { name, initial: JSON.stringify(active_channels[name].synchronize(true)) }

app.get '/', (req, res) ->
	people = 'kirk,feynman,huxley,robot,ben,batman,panda,pinkman,superhero,celebrity,traitor,alien,lemon'
	verb = 'on,enveloping,eating,drinking,in,near,sleeping,destruction'
	noun = 'mountain,drugs,house,asylum,elevator,scandal,planet,school,brick'
	pick = (list) -> 
		n = list.split(',')
		n[Math.floor(n.length * Math.random())]
	res.redirect '/' + pick(people) + "-" + pick(verb) + "-" + pick(noun)


port = process.env.PORT || 5000
app.listen port, ->
	console.log "listening on", port