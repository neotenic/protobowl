# A strange game. 
# The only winning move is not to play. 
# How about a nice game of chess? 

class QuizPlayer
	constructor: (room, id) ->
		# basic attributes: user id, room object
		@id = id
		@room = room

		# statistics
		@guesses = 0
		@interrupts = 0
		@early = 0
		@seen = 0
		@correct = 0
		@history = [] # todo: store history as a string?
		
		# timekeeping and other stuff
		@time_spent = 0
		@last_action = @room.serverTime()
		@created = @room.serverTime()

		# used to keep track of buzz limits
		@times_buzzed = 0
		
		# user settings
		@show_typing = true
		@team = ''
		@banned = 0
		@sounds = false
		@lock = false
		@movingwindow = false

		# rate limiting and banning
		@tribunal = null
		@__timeout = null
		@__recent_actions = []

	# keep track of how long someone's been online

	touch: (no_add_time) ->
		current_time = @room.serverTime() 
		unless no_add_time
			elapsed = current_time - @last_action
			if elapsed < 1000 * 60 * 10
				@time_spent += elapsed
		@last_action = current_time

	active: -> @online() and (@room.serverTime() - @last_action) < 1000 * 60 * 10

	online: -> true

	score: ->
		CORRECT = 10
		EARLY = 15
		INTERRUPT = -5
		return @early * EARLY + (@correct - @early) * CORRECT + @interrupts * INTERRUPT

	ban: ->
		@banned = @room.serverTime()
		@verb "was banned from #{@room.name}", true
		@emit 'redirect', "/#{@room.name}-banned"


	emit: (name, data) ->
		@room.log 'QuizPlayer.emit(name, data) not implemented'

	bookmark: ({ value, id }) -> 0 # not implemented

	disco: -> 0 # skeleton method, not actually implemented


	rate_limit: ->
		witnesses = (id for id, user of @room.users when id[0] isnt "_" and user.active())
		return if witnesses.length <= 2 # under this case, you can just go to a new room!

		window_size = 5
		action_delay = 876
		current_time = @room.serverTime()
		@__recent_actions.push current_time
		@__recent_actions = @__recent_actions.slice(-window_size) # get the last 10

		if @__recent_actions.length is window_size
			s = 0; s += time for time in @__recent_actions;
			mean_elapsed = current_time - s / window_size
			# console.log mean_elapsed, window_size * action_delay / 2
			if mean_elapsed < window_size * action_delay / 2
				@create_tribunal()

	create_tribunal: ->
		if !@tribunal
			current_time = @room.serverTime()
			witnesses = (id for id, user of @room.users when id[0] isnt "_" and user.active())
			# Ummmm ahh such as like, 
			# like the one where I'm like mmm and it says, 
			# "I saw watchoo did there!" 
			# And like and and then like you peoples were all like, 
			# "YOU IS TROLLIN!" and I was like 
			# "I AM NOT TROLLING!! I AM BOXXY YOU SEE!"
			
			# @verb 'is getting a boxxy tribunal', true

			@__timeout = setTimeout =>
				@verb 'survived the tribunal', true
				@tribunal = null
				@room.sync(1)
			, 1000 * 60

			@tribunal = { votes: [], against: [], time: current_time, witnesses }
			
			# @room.emit 'boxxy', {user: @id, time: current_time}
			@room.sync(1)


	trigger_tribunal: (user) ->
		@verb 'created a ban tribunal for !@' + user
		@room.users[user]?.create_tribunal()

	ban_user: (user) ->
		@room.users[user]?.ban()

	vote_tribunal: ({user, position}) ->
		
		# Instruct democracy, if possible to reanimate its beliefs, to
		# purify its mores, to regulate its movements, to substitute
		# little by little the science of affairs for its
		# inexperience, and knowledge of its true instincts for its
		# blind instincts; to adapt its government to time and place;
		# to modify it according to circumstances and men: such is the
		# first duty imposed on those who direct society in our day

		tribunal = @room.users[user]?.tribunal
		if tribunal
			{votes, against, witnesses} = tribunal
			return unless @id in witnesses
 			return if @id in votes or @id in against
			if position is 'ban'
				votes.push @id
				@verb 'voted to ban !@' + user
			else if position is 'free'
				against.push @id
				@verb 'voted to free !@' + user
			else
				@verb 'voted with a hanging chad'
			if votes.length > (witnesses.length - 1) / 2 + against.length
				@room.users[user].verb 'got voted off the island', true
				clearTimeout @room.users[user].__timeout
				@room.users[user].tribunal = null
				@room.users[user].ban()

			undecided = (witnesses.length - against.length - votes.length - 1)
			if votes.length + undecided <= (witnesses.length - 1) / 2 + against.length
				@room.users[user].verb 'was freed because of a hung jury', true
				@room.users[user].tribunal = null
				clearTimeout @room.users[user].__timeout


			@room.sync(1)


	verb: (action, no_rate_limit) -> 
		# dont send any messages for actions done by ninjas
		return if @id.toString().slice(0, 2) is '__'
		@rate_limit() unless no_rate_limit
		@room.emit 'log', {user: @id, verb: action, time: @room.serverTime() }

	
	disconnect: ->
		@verb 'left the room'
		@touch()
		@room.sync(1)

	echo: (data, callback) -> callback @room.serverTime()

	buzz: (data, fn) -> 
		if @room.buzz @id, fn
			@rate_limit()

	guess: (data) -> @room.guess @id, data

	chat: ({text, done, session}) ->
		@touch()
		# at this moment private messages are enforced on the end of the recipient
		# which is not a good thing because technically anyone can see the messages
		# and they aren't actually private, but that's problby okay for now
		@room.emit 'chat', { text, session, user: @id, done, time: @room.serverTime() }	
		@rate_limit() if done
	
	skip: ->
		@touch()
		if !@room.attempt and !@room.no_skip
			@room.new_question()
			@verb 'skipped a question'

	next: -> 
		@touch()
		@room.next()

	finish: ->
		@touch()
		if !@room.attempt and !@room.no_skip
			@verb 'skipped to the end of a question'
			@room.finish()
			@room.sync(1)

	pause: ->
		@touch()
		if !@room.attempt and @room.time() < @room.end_time
			@verb 'paused the game'
			@room.freeze()
			@room.sync()

	unpause: ->
		if !@room.question
			@room.new_question()
			@room.unfreeze()
		else if !@room.attempt
			duration = Math.round((@room.offsetTime() - @room.time_freeze)/1000)
			if duration > 2
				@verb "resumed the game (paused for #{duration} seconds}"
			else
				@verb "resumed the game"
			@room.unfreeze()
		@room.sync()


	set_lock: (val) ->
		@lock = !!val
		@touch()
		@room.sync(1)

	set_name: (name) ->
		# ensure no naming conflicts
		# for i, u of @room.users
		# 	return if name is u.name

		if name.trim().length > 0
			@name = name.trim().slice(0, 140)
			@touch()
			@room.sync(1)

	set_distribution: (data) ->
		@touch()
		return unless data
		enabled = []
		disabled = []
		for cat, count of data
			enabled.push cat if @room.distribution[cat] == 0 and count > 0
			disabled.push cat if @room.distribution[cat] > 0 and count == 0

		@room.distribution = data
		@room.sync(3)

		@room.get_size (size) =>
			if enabled.length > 0
				@verb "enabled #{enabled.join(', ')} (#{size} questions)"
			if disabled.length > 0
				@verb "disabled #{disabled.join(', ')} (#{size} questions)"



	set_difficulty: (data) ->
		@touch()
		# @verb 'is doing something with difficulty'
		@room.difficulty = data
		@room.sync()
		@room.get_size (size) =>
			@verb "set difficulty to #{data || 'everything'} (#{size} questions)"

	set_category: (data) ->
		@touch()
		# @verb 'changed the category to something which needs to be changed'
		@room.category = data
		@room.reset_distribution() unless data # reset to the default question distribution 
		@room.sync()
		@room.get_size (size) =>
			if data is 'custom'
				@verb "enabled a custom category distribution (#{size} questions)"
			else
				@verb "set category to #{data.toLowerCase() || 'potpourri'} (#{size} questions)"
		
	set_max_buzz: (data) ->
		if @room.max_buzz isnt data
			if !data
				@verb 'allowed players to buzz multiple times'
			else if data is 1
				@verb 'restricted players and teams to a single buzz per question'
			else if data > 1
				@verb "restricted players and teams to #{data} buzzes per question"
		@room.max_buzz = data
		@touch()
		@room.sync()

	set_speed: (speed) ->
		return unless speed
		@touch()
		@room.set_speed speed
		@room.sync()

	set_team: (name) ->
		if name
			@verb "switched to team #{name}"
		else
			@verb "is playing as an individual"
		@team = name
		@room.sync(1)

	set_type: (name) ->
		if name
			@room.type = name
			@room.category = ''
			@room.difficulty = ''
			@room.sync(3)
			@room.get_size (size) =>
				@verb "changed the question type to #{name} (#{size} questions)"

	set_show_typing: (data) ->
		@show_typing = data
		@room.sync(1)

	set_sounds: (data) ->
		@sounds = data
		@room.sync(1)

	set_movingwindow: (num) ->
		if num
			@movingwindow = num
		else
			@movingwindow = false
		@room.sync(1)

	set_skip: (data) ->
		@room.no_skip = !data
		@room.sync(1)
		if @room.no_skip
			@verb 'disabled question skipping'
		else
			@verb 'enabled question skipping'

	set_bonus: (data) ->
		@room.show_bonus = data
		if @room.show_bonus
			@verb 'enabled showing bonus questions'
		else
			@verb 'disabled showing bonus questions'
		@room.sync(1)

	reset_score: ->
		@verb "was reset from #{@score()} points (#{@correct} correct, #{@early} early, #{@guesses} guesses)"
		@seen = @interrupts = @guesses = @correct = @early = 0
		@history = []
		@room.sync(1)

	report_question: ->
		@verb "did something unimplemented (report question)"

	report_answer: ->
		@verb "did something unimplemented (report answer)"

	check_public: ->
		@verb "did something unimplemented (check public)"




exports.QuizPlayer = QuizPlayer if exports?