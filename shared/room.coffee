"""
	QuizRoom 2 Design:
	room = new QuizRoom(name)
	users = new User()
"""


class QuizPlayer
	constructor: (room, id) ->
		@id = id
		@room = room
		@guesses = 0
		@interrupts = 0
		@early = 0
		@seen = 0
		@time_spent = 0
		@last_action = +new Date
		@times_buzzed = 0
		@show_typing = true
		@team = 0
		@banned = false
		@sounds = false


	touch: ->
		@last_action = +new Date

	verb: (action) ->
		@room.emit 'log', {user: @id, verb: action}

	# disco: (data) ->
	# 	if data.old_socket and io.sockets.socket(data.old_socket)
	# 		io.sockets.socket(data.old_socket).disconnect()
	
	echo: (data, callback) ->
		callback +new Date
	
	set_name: (name) ->
		@name = name
		@touch()
		@room.sync(1)

	skip: ->
		unless @room.attempt
			@room.skip()
			@verb 'skipped a question'

	finish: ->
		unless @room.attempt
			@room.finish()
			@room.sync(1)

	set_distribution: (data) ->
		for cat, count of (data || default_distribution)
			if @room.distribution[cat] == 0 and count > 0
				@verb 'enabled category ' + cat
			if @room.distribution[cat] > 0 and count == 0
				@verb 'disabled category ' + cat
		@room.distribution = data || default_distribution
		@room.sync(3)

	next: ->
		@room.next()

	pause: ->
		@room.pause()
		@room.sync()

	unpause: ->
		@room.unpause()
		@room.sync()

	set_difficulty: (data) ->
		@verb 'is doing something with difficulty'
		@room.difficulty = data
		@room.sync()
		# category = (if @category is 'custom' then @distribution else @category)
		# remote.count_questions room.type, room.difficulty, category, (count) ->
		# 	room.emit 'log', {user: publicID, verb: 'set difficulty to ' + (data || 'everything') + ' (' + count + ' questions)'}
		# 	room.sync(3)

	set_category: (data) ->
		@verb 'changed the category to something which needs to be changed'
		@room.category = data
		@room.sync()
		# if !data
		# 	room.distribution = default_distribution # reset to the default question distribution 
		# log 'category', [room.name, publicID + '-' + room.users[publicID].name, room.category]
		# if data is "custom"
		# 	category = (if @category is 'custom' then @distribution else @category)
		# 	remote.count_questions room.type, room.difficulty, category, (count) ->
		# 		room.emit 'log', {user: publicID, verb: 'enabled a custom category distribution' + ' (' + count + ' questions)'}
		# 	room.sync(3)
		# else
		# 	remote.count_questions room.type, room.difficulty, room.category, (count) ->
		# 		room.emit 'log', {user: publicID, verb: 'set category to ' + (data.toLowerCase() || 'potpourri') + ' (' + count + ' questions)'}
		
	set_max_buzz: (data) ->
		@room.max_buzz = data
		@room.sync()

	set_speed: (speed) ->
		return unless speed
		@room.set_speed speed
		@room.sync()

	set_team: (name) ->
		if name
			@verb "switched to team #{name}"
		else
			@verb "is playing as an individual"
		@team = name
		@room.sync(2)

	set_show_typing: (data) ->
		@show_typing = data
		@room.sync(2)

	set_sounds: (data) ->
		@sounds = data
		@room.sync(2)

	buzz: (data, fn) ->
		@room.buzz @id, fn

	guess: (data) ->
		@room.guess @id, data

	chat: ({text, done, session}) ->
		@touch()
		@room.emit 'chat', {text, session, user: @id, done, time: +new Date}

	reset_score: ->
		@seen = @interrupts = @guesses = @correct = @early = 0
		@room.sync(1)

	report_question: ->
		@verb "did something unimplemented (report question)"

	report_answer: ->
		@verb "did something unimplemented (report answer)"

	check_public: ->
		@verb "did something unimplemented (check public)"



# i really wanted to have it calculate the distribution of things dynamically and generate this
# but the problem is that I don't have a system which is based on absolute percentages, so the
# problem is that you can't quite change absolute percentages or something
# i mean, technically it's possible to do the computation and it'd be pretty cool to be
# able to do that, and actually it's fairly trivial, but it's more effort than I'm currently
# willing to exert

default_distribution = {"Fine Arts":2,"Literature":4,"History":3,"Science":3,"Trash":1,"Geography":1,"Mythology":1,"Philosophy":1,"Religion":1,"Social Science":1}




class QuizRoom
	constructor: (name) ->
		@name = name
		@type = "qb"
		@answer_duration = 1000 * 5
		@time_offset = 0
		@rate = 1000 * 60 / 5 / 200
		@__timeout = -1
		@distribution = default_distribution
		
		@freeze()
		@new_question()
		@users = {}
		@difficulty = ''
		@category = ''
		@max_buzz = null

	get_difficulties: ->
		@emit 'log', {verb: 'NOT IMPLEMENTED (not async)'}

	get_categories: ->
		@emit 'log', {verb: 'NOT IMPLEMENTED (not async)'}

	get_question: (cb) ->
		@emit 'log', {verb: 'NOT IMPLEMENTED (async) get question'}
		# category = (if @category is 'custom' then @distribution else @category)
		# remote.get_question @type, @difficulty, category, (question) =>
		# 	cb(question || error_question)

	# add_socket: (id, socket) ->
	# 	unless id of @users
	# 		@users[id] = {
	# 			sockets: [],
	# 			guesses: 0,
	# 			interrupts: 0,
	# 			early: 0,
	# 			correct: 0,
	# 			seen: 0,
	# 			time_spent: 0,
	# 			last_action: 0,
	# 			times_buzzed: 0,
	# 			show_typing: true,
	# 			team: '',
	# 			banned: false,
	# 			sounds: false
	# 		}
	# 		# journal @name
	# 	user = @users[id]
	# 	user.id = id
	# 	@touch(id, true)
	# 	# user.last_action = @serverTime()
	# 	unless socket in user.sockets
	# 		user.sockets.push socket

	# 	whitelist = ['']
	

	emit_user: (id, args...) ->
		console.log 'room.emit_user(id, name, data) not implemented'
		# if id of @users
		# 	for sock in @users[id].sockets
		# 		s = io.sockets.socket(sock)
		# 		s.emit args...


	emit: (name, data) ->
		console.log 'room.emit(name, data) not implemented'
		# io.sockets.in(@name).emit name, data

	ban: (id) ->
		@users[id].banned = true
		@emit_user id, 'redirect', "/#{@name}-banned"
		@emit 'log', {user: id, verb: 'was banned from this room'}
		

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
		# journal @name

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
			@qid = question._id.toString()
			@info.tournament.replace(/[^a-z0-9]+/ig, '-') + "---" +
			@answer.replace(/[^a-z0-9]+/ig, '-').slice(0, 20)
			# console.log @qid

			@begin_time = @time()
			if SyllableCounter?
				syllables = SyllableCounter
			else
				syllables = require('./syllable').syllables

			@timing = (syllables(word) + 1 for word in @question.split(" "))
			@set_speed @rate #do the math with speeds
			# @end_time = @begin_time + @cumulative[@cumulative.length - 1] + @answer_duration
			for id, user of @users
				user.times_buzzed = 0
				if user.sockets.length > 0 and new Date - user.last_action < 1000 * 60 * 10
					user.seen++

			@sync(2)


	set_speed: (rate) ->
		return unless rate # prevent weird instances where you set_speed to null

		cumsum = (list, rate) ->
			sum = 0 #start nonzero, allow pause before rendering
			for num in [5].concat(list).slice(0, -1)
				sum += Math.round(num) * rate #always round!


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

				@emit 'log', {user: @attempt.user, verb: "won the lottery, hooray! 1% of buzzes which would otherwise be deemed wrong are randomly selected to be prompted, that's because the user interface for prompts has been developed (and thus needs to be tested), but the answer checker algorithm isn't smart enough to actually give prompts."}
				
				@timeout @serverTime, @attempt.realTime + @attempt.duration, =>
					@end_buzz session
			@sync()
		else
			@attempt.done = true
			@attempt.correct = checkAnswer @attempt.text, @answer, @question
			
			if @attempt.correct is 'prompt'
				@attempt.correct = false

			@sync()

		if @attempt.done
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
				teams = {}
				for id, user of @users when id[0] isnt "_" # skip secret ninja
					if user.sockets.length > 0 and (new Date - user.last_action) < 1000 * 60 * 10
						teams[user.team || id] = (teams[user.team || id] || 0)
						teams[user.team || id] += user.times_buzzed
				for team, times_buzzed of teams
					if times_buzzed >= @max_buzz and @max_buzz
						buzzed++
					pool++
				if @max_buzz
					# console.log 'people buzzed', buzzed, 'of', pool
					if buzzed >= pool 
						@finish() # if everyone's buzzed and nobody can buzz, then why continue reading

			# journal @name
			@attempt = null #g'bye
			@sync(1) #two syncs in one request!


	buzz: (user, fn) -> #todo, remove the callback and replace it with a sync listener
		@touch user
		team_buzzed = 0
		for id, member of @users when (member.team || id) is (@users[user].team || user)
            team_buzzed += member.times_buzzed
            
		if @max_buzz and @users[user].times_buzzed >= @max_buzz
			fn 'THE BUZZES ARE TOO DAMN HIGH' if fn
			@emit 'log', {user: user, verb: 'has already buzzed'}

		else if @max_buzz and team_buzzed >= @max_buzz
			fn 'THE BUZZES ARE TOO DAMN HIGH' if fn
			@emit 'log', {user: user, verb: 'is in a team which has already buzzed'}

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
			@emit 'log', {user: user, verb: 'lost the buzzer race'}
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
		
		blacklist = ["question", "answer", "timing", "voting", "info", "cumulative", "users", "__timeout", "generating_question", "distribution"]
		user_blacklist = ["sockets"]
		for attr of this when typeof this[attr] != 'function' and attr not in blacklist
			data[attr] = this[attr]

		if level >= 1
			data.users = for id of @users when !@users[id].ninja
				user = {}
				for attr of @users[id] when attr not in user_blacklist and typeof @users[id][attr] not in ['function', 'object']
					user[attr] = @users[id][attr] 
				user.online = @users[id].sockets.length > 0
				user

		if level >= 2
			data.question = @question
			data.answer = @answer
			data.timing = @timing
			data.info = @info

		if level >= 3
			data.difficulties = @get_difficulties(@type)
			data.categories = @get_categories(@type, @difficulty)
			data.distribution = @distribution
			
		@emit 'sync', data
	
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
		settings = ["name", "difficulty", "category", "rate", "answer_duration", "max_buzz", "distribution"]
		for field in settings
			data[field] = @[field]
		# actually save stuff
		return data

exports.QuizRoom = QuizRoom if exports?
exports.QuizPlayer = QuizPlayer if exports?