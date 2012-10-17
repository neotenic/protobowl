# i really wanted to have it calculate the distribution of things dynamically and generate this
# but the problem is that I don't have a system which is based on absolute percentages, so the
# problem is that you can't quite change absolute percentages or something
# i mean, technically it's possible to do the computation and it'd be pretty cool to be
# able to do that, and actually it's fairly trivial, but it's more effort than I'm currently
# willing to exert


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

default_distribution = {"Fine Arts":2,"Literature":4,"History":3,"Science":3,"Trash":1,"Geography":1,"Mythology":1,"Philosophy":1,"Religion":1,"Social Science":1}


# Tyger! Tyger! burning bright 
# In the forests of the night, 
# What immortal hand or eye 
# Could frame thy fearful symmetry? 

class QuizRoom
	constructor: (name) ->
		@name = name
		@type = "qb"
		@answer_duration = 1000 * 5
		@time_offset = 0
		@sync_offset = 0 # always zero for master installations
		@start_offset = 0 # to compensate for latency, etc.
		
		@end_time = 0
		@question = ''
		@answer = ''
		@timing = []
		@cumulative = []

		@rate = 1000 * 60 / 5 / 200
		@__timeout = -1
		@distribution = default_distribution

		@freeze()
		@users = {} 
		@difficulty = ''
		@category = ''
		@max_buzz = null

	log: (message) -> @emit 'log', { verb: message }

	get_parameters: (type, difficulty, cb) -> # cb(difficulties, categories)
		#  async version of get_difficulties and get_categories
		@emit 'log', {verb: 'NOT IMPLEMENTED (async get params)'}
		cb ['HS', 'MS'], ['Science', 'Trash']

	count_questions: (type, difficulty, category, cb) ->
		@log 'NOT IMPLEMENTED (question counting)'

	get_size: (cb, type = @type, difficulty = @difficulty, category = @category) ->
		@count_questions type, difficulty, (if category is 'custom' then @distribution else category), (count) ->
			cb count

	get_question: (cb) ->
		setTimeout ->
			cb error_question
		, 10
		@log 'NOT IMPLEMENTED (async get question)'

		
	# emit_user: (id, args...) ->
	# 	@log 'room.emit_user(id, name, data) not implemented'


	emit: (name, data) ->
		# note to self, do not change this into an @log, because thats recursive
		console.log 'room.emit(name, data) not implemented'

	reset_distribution: ->
		@distribution = default_distribution

	# ban: (id) ->
	# 	@users[id].banned = true
	# 	@emit_user id, 'redirect', "/#{@name}-banned"
	# 	@emit 'log', {user: id, verb: 'was banned from this room'}
		

	# vote: (id, action, val) ->
	# 	# room.add_socket publicID, sock.id
	# 	@users[id][action] = val
	# 	@sync()

	# touch: (id, no_add_time) ->
	# 	unless no_add_time
	# 		elapsed = @serverTime() - @users[id].last_action
	# 		if elapsed < 1000 * 60 * 10
	# 			@users[id].time_spent += elapsed
	# 	@users[id].last_action = @serverTime()

	# del_socket: (id, socket) ->
	# 	user = @users[id]
	# 	if user
	# 		@touch(id)
	# 		user.sockets = (sock for sock in user.sockets when sock isnt socket)
	# 	# journal @name

	time: -> if @time_freeze then @time_freeze else @offsetTime()

	offsetTime: -> @serverTime() - @time_offset

	serverTime: -> new Date - @sync_offset

	set_time: (ts) -> @time_offset = @serverTime() - ts

	freeze: -> @time_freeze = @time()

	unfreeze: ->
		if @time_freeze
			@set_time @time_freeze
			@time_freeze = 0

	# pause: -> @freeze() unless @attempt or @time() > @end_time
		
	#freeze with access controls	
	# unpause: -> @unfreeze() unless @attempt
	
	# timeout: (metric, time, callback) ->
	# 	@clear_timeout()

	# 	diff = time - metric()
	# 	if diff < 0
	# 		callback()
	# 	else
	# 		@__timeout = setTimeout =>
	# 			@timeout(metric, time, callback)
	# 		, diff

	timeout: (delay, callback) ->
		@clear_timeout()
		@__timeout = setTimeout callback, delay

	clear_timeout: -> clearTimeout @__timeout

	new_question: ->
		# question = questions[Math.floor(questions.length * Math.random())]
		@generating_question = true
		@get_question (question) =>
			if !question or !question.question or !question.answer
				question = error_question
				
			delete @generating_question;
			@generated_time = @serverTime() # like begin_time but doesnt change when speed is altered
			
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
			@qid = question?._id?.toString() || 'question_id'
			
			# @info.tournament.replace(/[^a-z0-9]+/ig, '-') + "---" +
			# @answer.replace(/[^a-z0-9]+/ig, '-').slice(0, 20)
			# console.log @qid

			@begin_time = @time() + @start_offset

			if SyllableCounter?
				syllables = SyllableCounter
			else
				syllables = require('./syllable').syllables

			@timing = (syllables(word) + 1 for word in @question.split(" "))
			@set_speed @rate #do the math with speeds
			# @end_time = @begin_time + @cumulative[@cumulative.length - 1] + @answer_duration
			for id, user of @users
				user.times_buzzed = 0
				# if user.sockets.length > 0 and new Date - user.last_action < 1000 * 60 * 10
				user.seen++ if user.active()

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


	finish: -> @set_time @end_time

	next: ->
		if @time() > @end_time - @answer_duration and !@generating_question and !@attempt
			@unfreeze()
			@new_question()
			

	check_answer: (attempt, answer, question) ->
		# this is a mock answer checker in lieu of an actual one
		return 'prompt' if Math.random() > 0.8
		return Math.random() > 0.3

	end_buzz: (session) -> #killit, killitwithfire

		return unless @attempt?.session is session
		# touch the user in weird places
		# @touch @attempt.user
		unless @attempt.prompt
			@clear_timeout()
			@attempt.done = true
			@attempt.correct = @check_answer @attempt.text, @answer, @question
			do_prompt = false
			
			if @attempt.correct is 'prompt'
				do_prompt = true
				@attempt.correct = false
			
			# if Math.random() > 0.99 and @attempt.correct is false
			# 	do_prompt = true

			# log 'buzz', [@name, @attempt.user + '-' + @users[@attempt.user].name, @attempt.text, @answer, @attempt.correct]
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

				# @emit 'log', {user: @attempt.user, verb: "won the lottery, hooray! 1% of buzzes which would otherwise be deemed wrong are randomly selected to be prompted, that's because the user interface for prompts has been developed (and thus needs to be tested), but the answer checker algorithm isn't smart enough to actually give prompts."}
				
				@timeout @attempt.duration, => #@serverTime, @attempt.realTime + @attempt.duration, =>
					@end_buzz session
			@sync()
		else
			@attempt.done = true
			@attempt.correct = @check_answer @attempt.text, @answer, @question
			@attempt.correct = false if @attempt.correct is 'prompt'
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
					if user.active()
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
			@journal()
			@attempt = null #g'bye
			@sync(1) #two syncs in one request!


	buzz: (user, fn) -> #todo, remove the callback and replace it with a sync listener
		# @touch user
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
			@timeout @attempt.duration, => #@serverTime, @attempt.realTime + @attempt.duration, =>
				@end_buzz session

			return true

		else if @attempt
			@emit 'log', {user: user, verb: 'lost the buzzer race'}
			fn 'THE GAME' if fn
		else
			@emit 'log', {user: user, verb: 'attempted an invalid buzz'}
			fn 'THE GAME' if fn

		return false

	guess: (user, data) ->
		# @touch user
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
			real_time: @serverTime() #,
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
		
		blacklist = ["question", "answer", "generated_time", "timing", "voting", "info", "cumulative", "users", "generating_question", "distribution", "sync_offset"]
		user_blacklist = ["sockets", "room"]
		for attr of this when typeof this[attr] != 'function' and attr not in blacklist and attr[0] != "_"
			data[attr] = this[attr]

		if level >= 1
			data.users = for id of @users when id[0] isnt '_'
				user = {}
				for attr of @users[id] when attr not in user_blacklist and typeof @users[id][attr] not in ['function'] and attr[0] != '_'
					user[attr] = @users[id][attr] 
				user.online_state = @users[id].online()
				# console.log user
				user

		if level >= 2
			data.question = @question
			data.answer = @answer
			data.timing = @timing
			data.info = @info
			data.generated_time = @generated_time

		if level >= 3
			data.distribution = @distribution
			# async stuff
			@get_parameters @type, @difficulty, (difficulties, categories) =>
				data.difficulties = difficulties
				data.categories = categories
				@emit 'sync', data

			@journal()
		else
			@emit 'sync', data
	
	journal: -> 0 # unimplemented

	journal_export: ->
		# this is like a simplified sync
		data = {}
		# user data!
		user_blacklist = ["sockets", "room"]
		data.users = for id of @users
			user = {}
			for attr of @users[id] when attr not in user_blacklist and typeof @users[id][attr] not in ['function'] and attr[0] != '_'
				user[attr] = @users[id][attr]
			user
		# global room settings
		settings = ["name", "difficulty", "category", "rate", "answer_duration", "max_buzz", "distribution"]
		for field in settings
			data[field] = @[field]
		# actually save stuff
		return data

exports.QuizRoom = QuizRoom if exports?