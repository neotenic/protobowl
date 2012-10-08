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




exports.QuizPlayer = QuizPlayer if exports?