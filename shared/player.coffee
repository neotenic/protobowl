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
		@last_session = @room.serverTime()
		@created = @room.serverTime()
		@idle = false

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
		@elect = null
		# @__tribunal_timeout = null
		# @__elect_timeout = null
		@__recent_actions = []
		@__rate_limited = 0

	# keep track of how long someone's been online

	touch: (no_add_time) ->
		@idle = false
		current_time = @room.serverTime() 
		unless no_add_time
			elapsed = current_time - @last_action
			if elapsed < 1000 * 60 * 10
				@time_spent += elapsed
		@last_action = current_time
		@room.check_timeout()

	active: -> @online() and (@room.serverTime() - @last_action) < 1000 * 60 * 10 and !@idle

	online: -> true

	authorized: ->
		return true unless @room.locked()
		return @id[0] == '_' or @id in @room.admins or @elect?.term > @room.serverTime()


	score: ->
		CORRECT = 10
		EARLY = 15
		INTERRUPT = -5
		return @early * EARLY + (@correct - @early) * CORRECT + @interrupts * INTERRUPT

	ban: -> 1

	emit: (name, data) ->
		@room.log 'QuizPlayer.emit(name, data) not implemented'

	bookmark: ({ value, id }) -> 0 # not implemented

	disco: -> 0 # skeleton method, not actually implemented

	rate_limited: ->
		witnesses = (id for id, user of @room.users when id[0] isnt "_" and user.active())
		action_delay = 856
		action_delay = 612 if witnesses.length <= 2 # under this case, you can just go to a new room!
		throttle_delay = 316
		window_size = 10
		current_time = @room.serverTime()

		@__recent_actions = @__recent_actions.slice(-window_size) # get the last 10

		if @__recent_actions.length is window_size
			s = 0; s += time for time in @__recent_actions;
			mean_elapsed = current_time - s / window_size

			if mean_elapsed < window_size * throttle_delay / 2
				@throttle()

			if mean_elapsed < window_size * action_delay / 2
				return true

	throttle: ->
		new_time = @room.serverTime() + 1000 * 5
		if new_time - @__rate_limited > 762
			@emit 'throttle', @__rate_limited
			@__recent_actions.push @room.serverTime()

		@__rate_limited = new_time
		


	rate_limit: ->
		@__recent_actions.push @room.serverTime()
		
		if @rate_limited()
			@create_tribunal()


	nominate: ->
		if !@elect
			# @verb "TERMPOEWJROSIJWER THIS PERSON IS A NARCONARC"
			current_time = @room.serverTime()
			witnesses = (id for id, user of @room.users when id[0] isnt "_" and user.active())
			@__elect_timeout = setTimeout =>
				@verb 'got romneyed', true
				@elect = null
				@room.sync 1
			, 1000 * 60

			@elect = { votes: [], against: [], time: current_time, witnesses }
			@room.sync 1



	create_tribunal: ->
		if !@tribunal
			current_time = @room.serverTime()
			witnesses = (id for id, user of @room.users when id[0] isnt "_" and user.active())
			return if witnesses.length <= 1

			# Ummmm ahh such as like, 
			# like the one where I'm like mmm and it says, 
			# "I saw watchoo did there!" 
			# And like and and then like you peoples were all like, 
			# "YOU IS TROLLIN!" and I was like 
			# "I AM NOT TROLLING!! I AM BOXXY YOU SEE!"
			
			@__tribunal_timeout = setTimeout =>
				@verb 'survived the tribunal', true
				@tribunal = null
				@room.sync(1)
			, 1000 * 60

			@tribunal = { votes: [], against: [], time: current_time, witnesses, term: 0 }
			
			@room.sync(1)


	trigger_tribunal: (user) ->
		is_admin = @id in @room.admins or @id[0] is '_'
		if is_admin or @score() > 50
			@verb 'created a ban tribunal for !@' + user
			@room.users[user]?.create_tribunal()

	ban_user: (user) ->
		is_admin = @id in @room.admins or @id[0] is '_'
		if is_admin
			@verb 'banned !@' + user + ' from /' + @room.name
			@room.users[user]?.ban(1000 * 60 * 5)

	vote_election: ({user, position}) ->
		@touch()
		elect = @room.users[user]?.elect
		return if !elect

		if !elect.term
			{votes, against, witnesses} = elect
			return unless @id in witnesses
 			return if @id in votes or @id in against
			if position is 'elect'
				votes.push @id
				# @verb 'voted to elect !@' + user
			else if position is 'deny'
				against.push @id
				# @verb 'voted to impeach !@' + user
			else
				@verb 'voted from a diebold machine'

			if votes.length > (witnesses.length - 1) / 2 + against.length
				# @room.users[user].verb 'gots the blanc haus', true
				
				term_length = 1000 * 60

				# there is a new species in new york; it can be aggressive if threatened
				witnesses = (id for id, u of @room.users when id[0] isnt "_" and u.active())

				@room.users[user].elect = { impeach: [], witnesses, term: @room.serverTime() + term_length }

				# let's go to the mall!
				@room.users[user].inaugurate()

			undecided = (witnesses.length - against.length - votes.length - 1)
			if votes.length + undecided <= (witnesses.length - 1) / 2 + against.length
				@room.users[user].verb 'was not elected', true
				@room.users[user].impeach()

			@room.sync(1)
		else if elect.term > @room.serverTime()
			{impeach, witnesses} = elect
			return unless @id in witnesses
			return if @id in impeach
			if position is 'impeach'
				impeach.push @id
				# @verb 'hates bill clinton'
				votes_needed = Math.floor((witnesses.length - 1)/2 + 1) - impeach.length
				if votes_needed <= 0
					@room.users[user].verb 'was impeached from office', true
					@room.users[user].impeach()
				else
					@room.sync 1

	# Come on Jessica, come on Tori,
	# Let's go to the mall, you won't be sorry
	# Put on your jelly bracelets
	# And your cool graffiti coat
	# At the mall, having fun is what it's all about

	inaugurate: ->
		return if !@elect?.term # this should be enough

		# must be quasi-protected method because we dont want to defeat the purpose
		# of having a convoluted system of bureaucracy!
		clearTimeout @__elect_timeout

		@__elect_timeout = setTimeout =>
			if @authorized()
				@verb 'is no longer commander in chief', true
				@impeach()
		, @elect.term - @room.serverTime()


	impeach: ->
		@elect = null
		clearTimeout @__elect_timeout
		@room.sync(1)

	# also, that reference *did* actually make sense
	# As in, inaugurations take place on the national mall.

	finish_term: ->
		return if !@elect?.term # this should be enough		
		@verb 'has finished tenure in office', true
		@elect = null
		@room.sync(1)

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
				clearTimeout @room.users[user].__tribunal_timeout
				@room.users[user].tribunal = null
				# @room.users[user].verb "was banned from #{@room.name}", true
				@room.users[user].ban(1000 * 60 * 15)

			undecided = (witnesses.length - against.length - votes.length - 1)
			if votes.length + undecided <= (witnesses.length - 1) / 2 + against.length
				@room.users[user].verb 'was freed because of a hung jury', true
				@room.users[user].tribunal = null
				clearTimeout @room.users[user].__tribunal_timeout


			@room.sync(1)


	verb: (action, no_rate_limit) -> 
		# dont send any messages for actions done by ninjas
		return if @id.toString().slice(0, 2) is '__'
		@rate_limit() unless no_rate_limit
		@room.emit 'log', {user: @id, verb: action, time: @room.serverTime() }

	
	disconnect: ->
		@touch()
		if @sockets.length is 0
			seconds = (@room.serverTime() - @last_session) / 1000
			if seconds > 90
				@verb "left the room (logged on #{Math.round(seconds/60)} minutes ago)"
			else if seconds > 1
				@verb "left the room (logged on #{Math.round(seconds)} seconds ago)"
			else
				@verb "left the room"
				
		@room.sync(1)

	echo: (data, callback) -> 
		if data.avg and data.std and data.n
			@_latency = [data.avg, data.std, data.n]
		callback @room.serverTime()

	buzz: (data, fn) -> 
		@touch()

		if @room.qid is data and @room.buzz(@id, fn)
			@rate_limit()

	guess: (data) -> 
		@touch()
		@room.guess @id, data

	chat: ({text, done, session}) ->
		@touch()
		# at this moment private messages are enforced on the end of the recipient
		# which is not a good thing because technically anyone can see the messages
		# and they aren't actually private, but that's probably okay for now


		id = @id # ninjas should be able to choose their names
		id = '__' + @name.replace(/\s+/g, '_') if id[0] is '_'

		@room.emit 'chat', { text, session, user: id, done, time: @room.serverTime() }	
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
		return if @attempt or @room.no_skip or @room.time() >= @room.end_time or @room.time_freeze
	
		@verb 'skipped to the end of a question'
		@room.finish()
		@room.sync(1)

	pause: ->
		@touch()
		
		return if @room.time_freeze

		if !@room.attempt and @room.time() < @room.end_time
			@rate_limit()
			@verb 'paused the game'
			@room.freeze()
			@room.sync()

	unpause: ->
		@touch()
		return if !@room.time_freeze

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

	set_idle: (val) ->  
		# old_lock = @room.locked()
		@idle = !!val
		# lets update people if it affects their interests
		# if @room.locked() != old_lock
		# 	@room.sync 1

	set_lock: (val) ->
		@lock = !!val
		@touch()
		@room.sync(1)

	set_name: (name) ->
		@touch()
		if (name + '').trim().length > 0
			@name = name.trim().slice(0, 140)
			@room.sync(1)

	set_distribution: (data) ->
		@touch()
		return unless @authorized()
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
		return unless @authorized()
		# @verb 'is doing something with difficulty'
		@room.difficulty = data
		@room.sync()
		@room.get_size (size) =>
			@verb "set difficulty to #{data || 'everything'} (#{size} questions)"

	set_category: (data) ->
		@touch()
		return unless @authorized()
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
		@touch()
		return unless @authorized()
		if @room.max_buzz isnt data
			if !data
				@verb 'allowed players to buzz multiple times'
			else if data is 1
				@verb 'restricted players and teams to a single buzz per question'
			else if data > 1
				@verb "restricted players and teams to #{data} buzzes per question"
		@room.max_buzz = data
		@room.sync()

	set_speed: (speed) ->
		@touch()
		return unless @authorized()
		return if isNaN(speed)
		return if speed <= 0
		@room.set_speed speed
		@room.sync()

	set_team: (name) ->
		@touch()
		if name
			@verb "switched to team #{name}"
		else
			@verb "is playing as an individual"
		@team = name
		@room.sync(1)

	set_type: (name) ->
		@touch()
		return unless @authorized()
		
		if name
			@room.type = name
			@room.category = ''
			@room.difficulty = ''
			@room.sync(3)
			@room.get_size (size) =>
				@verb "changed the question type to #{name} (#{size} questions)"

	set_show_typing: (data) ->
		@touch()
		@show_typing = !!data
		@room.sync(1)

	set_sounds: (data) ->
		@touch()
		@sounds = !!data
		@room.sync(1)

	set_movingwindow: (num) ->
		@touch()
		if num and !isNaN(num)
			@movingwindow = num
		else
			@movingwindow = false
		@room.sync(1)

	set_skip: (data) ->
		@touch()
		return unless @authorized()
		@room.no_skip = !data
		@room.sync(1)
		if @room.no_skip
			@verb 'disabled question skipping'
		else
			@verb 'enabled question skipping'

	set_bonus: (data) ->
		@touch()
		return unless @authorized()
		@room.show_bonus = !!data
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

	_apotheify: ->
		unless @id in @room.admins
			@verb 'is now an administrator of this room'
			@room.admins.push(@id) 
			@room.sync(1) # technically level-1 not necessary, but level-0 doesnt prompt user rerender

	cincinnatus: ->
		if @id in @room.admins
			@verb 'is no longer an administrator of this room'
			@room.admins = (id for id in @room.admins when id isnt @id)
			@room.sync(1) # technically level-1 not necessary, but level-0 doesnt prompt user rerender

	serialize: ->
		data = {}
		blacklist = ['sockets', 'room']
		for attr of this when attr not in blacklist and typeof this[attr] not in ['function'] and attr[0] != '_'
			data[attr] = this[attr]
		return data

	deserialize: (obj) ->
		blacklist = ['tribunal', 'elect']
		this[attr] = val for attr, val of obj when attr[0] != '_' and attr not in blacklist


exports.QuizPlayer = QuizPlayer if exports?