questions = [{"category": "Meta", "question_num": 666, "tournament": "Metaception Bowl", "question": "This application was intended to act as a chat client which could handle single user sessions offline by pretending the user was schizophrenic. It was started primarily because of an argument about how to implement multiplayer and whether or not the DC comics character, the Joker, might say \"Singleplayer is Multiplayer without balls\". For 10 points, name this application that you are almost certainly using right now.", "accept": null, "difficulty": "HS", "year": 2012, "answer": "protobowl", "round": "Round_10_HSAPQ4Q.pdf"}
]

fisher_yates = (i) ->
	return [] if i is 0
	arr = [0...i]
	while --i
		j = Math.floor(Math.random() * (i+1))
		[arr[i], arr[j]] = [arr[j], arr[i]] 
	arr

question_schedule = []
getQuestion = ->
	#todo, dedup
	if question_schedule.length is 0
		question_schedule = fisher_yates(questions.length)
	return questions[question_schedule.shift()]
	# for i in [0...20]
	# 	num = Math.floor(questions.length * Math.random())
	# 	break unless num in previous_questions
	# previous_questions.push num
	# return questions[num]

# checkAnswer = (attempt, correct) ->
# 	attempt.toLowerCase()
# 	return Math.random() > 0.5

# maybe it would be advantageous to find a way
# to actually sy
virtual_server = {
	pause: ->
		@freeze() unless sync.attempt or time() > sync.end_time
	unpause: ->
		this.unfreeze() unless sync.attempt

	set_time: (ts) ->
		sync.time_offset = serverTime() - ts

	freeze: ->
		sync.time_freeze = time()

	unfreeze: ->
		if sync.time_freeze
			@set_time sync.time_freeze
			sync.time_freeze = 0

	skip: ->
		@new_question()

	###### THE ABOVE SECTION IS PRACTICALLY VERBATIM
	init_offline: -> #this function does not exist server side
		loadQuestions()

	rename: (name) ->
		users[public_id].name = name

	join: (data) ->
		publicID = "offline"
		publicName = require('lib/names').generateName()
		console.log "joining stuff", data
		
		sync.answer_duration = 1000 * 5
		sync.time_offset = 0
		sync.users = [{ #you're the only one here, solipsistic eh?
			guesses: 0,
			interrupts: 0,
			early: 0,
			correct: 0,
			last_action: 0,
			id: publicID,
			name: publicName
		}]

		@freeze()
		@new_question()

		sock.server_emit 'introduce', {user: publicID}
		
		setTimeout ->
			synchronize()
		, 10
		return {
			name: publicName,
			id: publicID
		}

	chat: (msg) ->
		sock.server_emit 'chat', {text: msg.text, session: msg.session, user: public_id, final: msg.final, time: serverTime()}

		if msg.final
			if replies? or /lonely/.test msg.text
				session = Math.random().toString(36).slice(2)
				if replies?
					pick = (list) -> list[Math.floor(list.length * Math.random())]
					if msg.text of replies
						reply = pick replies[msg.text]
					else
						reply = pick Object.keys(replies)
				else
					$('<script>').attr('src', 'lib/chatbot.js').appendTo('head')
					reply = "I'm lonely too. Plz talk to meeeee"
				count = 0
				writeLetter = ->
					if ++count <= reply.length
						sock.server_emit 'chat', {text: reply.slice(0, count), session, user: public_id, final: count == reply.length, time: serverTime()}
						setTimeout writeLetter, 1000 * 60 / 6 / 130
				writeLetter()


	new_question: ->
		sync.attempt = null
		
		sync.begin_time = time()
		question = getQuestion()
		sync.info = {
			category: question.category, 
			difficulty: question.difficulty, 
			tournament: question.tournament, 
			num: question.question_num, 
			year: question.year, 
			round: question.round
		}
		sync.question = question.question
			.replace(/FTP/g, 'For 10 points')
			.replace(/^\[.*?\]/, '')
			.replace(/\n/g, ' ')
		sync.answer = question.answer
			.replace(/\<\w\w\>/g, '')
			.replace(/\[\w\w\]/g, '')
		
		# lightweight version for when we have no supporting libraries

		# syllables = (word) ->
		# 	# avg(sync.question.split(' ').map(function(e, i){return (sync.timing[i] - 1) / e.length}))
		# 	Math.round(word.length * 0.35636480798038367)

		syllables = require('./lib/syllable').syllables
		sync.timing = (syllables(word) + 1 for word in sync.question.split(" "))
		sync.rate = Math.round(1000 * 60 / 3 / 300)
		cumulative = cumsum sync.timing, sync.rate
		sync.end_time = sync.begin_time + cumulative[cumulative.length - 1] + sync.answer_duration
		# @sync(2)
		synchronize()

	guess: (data) ->
		if sync.attempt
			sync.attempt.text = data.text
			if data.final
				@end_buzz sync.attempt.session

	end_buzz: (session) ->
		if sync.attempt?.session is session
			sync.attempt.final = true
			checkAnswer = require('./lib/answerparse').checkAnswer
			sync.attempt.correct = checkAnswer sync.attempt.text, sync.answer
			
			# @sync()
			synchronize()
			@unfreeze()
			if sync.attempt.correct
				users[public_id].correct++
				if sync.attempt.early 
					users[public_id].early++
				@set_time sync.end_time
			else if sync.attempt.interrupt
				users[public_id].interrupts++
			sync.attempt = null
			synchronize()

	buzz: ->
		if time() <= sync.end_time
			session = Math.random().toString(36).slice(2)
			early_index = sync.question.replace(/[^ \*]/g, '').indexOf('*')
			cumulative = cumsum sync.timing, sync.rate
			sync.attempt = {
				user: public_id,
				realTime: serverTime(), # oh god so much time crap
				start: time(),
				duration: 8 * 1000,
				session, # generate 'em server side 
				text: '',
				early: early_index and time() < sync.begin_time + cumulative[early_index],
				interrupt: time() < sync.end_time - sync.answer_duration,
				final: false
			}
			users[public_id].guesses++
			@freeze()
			@timeout serverTime, sync.attempt.realTime + sync.attempt.duration, =>
				@end_buzz session

	timeout: (metric, time, callback) ->
		diff = time - metric()
		if diff < 0
			callback()
		else
			setTimeout =>
				@timeout(metric, time, callback)
			, diff
}

loadQuestions = (fn) ->
	$.ajax('sample.txt').done (text) ->
		# console.log text.slice(0, 100)
		questions = (JSON.parse(line) for line in text.split('\n'))
		console.log 'got questions', questions.length
		fn() if fn

if !io? #if this is being loaded and socket io exists not
	console.log "initializing server!"
	loadQuestions ->
		sock.server_emit "connect"