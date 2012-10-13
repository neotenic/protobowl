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
		
		# timekeeping and other stuff
		@time_spent = 0
		@last_action = @room.serverTime()

		# used to keep track of buzz limits
		@times_buzzed = 0
		
		# user settings
		@show_typing = true
		@team = ''
		@banned = false
		@sounds = false

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
		@banned = true
		@emit 'redirect', "/#{@room.name}-banned"


	emit: (name, data) ->
		@room.log 'QuizPlayer.emit(name, data) not implemented'



	rate_limit: ->
		witnesses = (id for id, user of @room.users when id[0] isnt "_" and user.active())
		return if witnesses.length <= 2 # under this case, you can just go to a new room!

		window_size = 6
		action_delay = 1000
		current_time = @room.serverTime()
		@__recent_actions.push current_time
		@__recent_actions = @__recent_actions.slice(-window_size) # get the last 10

		if @__recent_actions.length is window_size and !@tribunal
			s = 0; s += time for time in @__recent_actions;
			mean_elapsed = current_time - s / window_size
			if mean_elapsed < window_size * action_delay / 2
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

				@tribunal = { votes: [], time: current_time, witnesses }
				
				# @room.emit 'boxxy', {user: @id, time: current_time}
				@room.sync(1)


	vote_tribunal: (user) ->
		
		# Instruct democracy, if possible to reanimate its beliefs, to
		# purify its mores, to regulate its movements, to substitute
		# little by little the science of affairs for its
		# inexperience, and knowledge of its true instincts for its
		# blind instincts; to adapt its government to time and place;
		# to modify it according to circumstances and men: such is the
		# first duty imposed on those who direct society in our day

		tribunal = @room.users[user].tribunal
		if tribunal
			return unless @id in tribunal.witnesses

			votes = tribunal.votes
			votes.push(@id) if votes and @id not in votes
			if votes.length > (tribunal.witnesses.length - 1) / 2
				@room.users[user].verb 'got voted off the island', true
				clearTimeout @room.users[user].__timeout
				@room.users[user].tribunal = null
				@room.users[user].ban()

			else
				@verb 'voted to ban !@' + user

			@room.sync(1)


	verb: (action, no_rate_limit) -> 
		# dont send any messages for actions done by ninjas
		return if @id.toString().slice(0, 2) is '__'
		@rate_limit() unless no_rate_limit
		@room.emit 'log', {user: @id, verb: action, time: @room.serverTime() }

	
	disco: -> 0 # skeleton method, not actually implemented

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
		unless @room.attempt
			@room.new_question()
			@verb 'skipped a question'

	next: -> 
		@touch()
		@room.next()

	finish: ->
		@touch()
		unless @room.attempt
			@room.finish()
			@room.sync(1)

	pause: ->
		@touch()
		if !@room.attempt and @room.time() < @room.end_time
			@verb 'paused the game'
			@room.freeze()
			@room.sync()

	unpause: ->
		if !@room.attempt
			@verb 'resumed the game'
			@room.new_question() if !@room.question
			@room.unfreeze()
		@room.sync()


	set_name: (name) ->
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
		@room.max_buzz = data
		@touch()
		if @room.max_buzz isnt data
			if data is 0
				@verb 'allowed players to buzz multiple times'
			else if data is 1
				@verb 'restricted players and teams to a single buzz per question'
			else if data > 1
				@verb "restricted players and teams to #{data} buzzes per question"
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
		@room.sync(2)

	set_show_typing: (data) ->
		@show_typing = data
		@room.sync(2)

	set_sounds: (data) ->
		@sounds = data
		@room.sync(2)

	reset_score: ->
		@seen = @interrupts = @guesses = @correct = @early = 0
		@room.sync(1)

	report_question: ->
		@verb "did something unimplemented (report question)"

	report_answer: ->
		@verb "did something unimplemented (report answer)"

	check_public: ->
		@verb "did something unimplemented (check public)"




exports.QuizPlayer = QuizPlayer if exports?