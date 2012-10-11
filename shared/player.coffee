# class Player
# 	constructor: (room, id) ->
# 		# @id = id
# 		# @room = room
# 		@guesses = 0
# 		@interrupts = 0
# 		@early = 0
# 		@seen = 0
# 		@time_spent = 0
# 		@last_action = +new Date
# 		@times_buzzed = 0
# 		@show_typing = true
# 		@team = 0
# 		@banned = false
# 		@sounds = false


class QuizPlayer
	constructor: (room, id) ->
		@id = id
		@room = room
		@guesses = 0
		@interrupts = 0
		@early = 0
		@seen = 0
		@time_spent = 0
		@last_action = @room.serverTime()
		@times_buzzed = 0
		@show_typing = true
		@team = 0
		@banned = false
		@sounds = false

	# keep track of how long someone's been online

	touch: (no_add_time) ->
		current_time = @room.serverTime() 
		unless no_add_time
			elapsed = current_time - @last_action
			if elapsed < 1000 * 60 * 10
				@time_spent += elapsed
		@last_action = current_time

	active: -> (@room.serverTime() - @last_action) < 1000 * 60 * 10

	verb: (action) -> @room.emit 'log', {user: @id, verb: action} unless @id.toString().slice(0, 2) is '__'
	
	disco: -> 0 # skeleton method, not actually implemented

	disconnect: ->
		@verb 'left the room'
		@room.sync(1)

	echo: (data, callback) -> callback @room.serverTime()

	buzz: (data, fn) -> @room.buzz @id, fn

	guess: (data) -> @room.guess @id, data

	chat: ({text, done, session}) ->
		@touch()
		@room.emit 'chat', { text, session, user: @id, done, time: @room.serverTime() }	
	
	skip: ->
		@touch()
		unless @room.attempt
			@room.skip()
			@verb 'skipped a question'

	next: -> @room.next()

	finish: ->
		@touch()
		unless @room.attempt
			@room.finish()
			@room.sync(1)

	pause: ->
		@touch()
		@room.pause()
		@room.sync()

	unpause: ->
		@room.unpause()
		@room.sync()


	set_name: (name) ->
		@name = name
		@touch()
		@room.sync(1)

	set_distribution: (data) ->
		@touch()
		if data
			for cat, count of data
				if @room.distribution[cat] == 0 and count > 0
					@verb 'enabled category ' + cat
				if @room.distribution[cat] > 0 and count == 0
					@verb 'disabled category ' + cat
			@room.distribution = data
			@room.sync(3)



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