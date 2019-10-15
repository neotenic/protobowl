# A strange game. 
# The only winning move is not to play. 
# How about a nice game of chess? 

class QuizPlayer
	constructor: (room, id) ->
		# basic attributes: user id, room object
		@id = id
		@room = room

		# statistics
		@corrects = {}
		@wrongs = {}
		@prompts = 0

		@earlyseen = 0
		@seen = 0

		@streak = 0
		@streak_record = 0
		
		@negstreak = 0
		@negstreak_record = 0

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
		@team = ''
		@banned = 0

		@auth = null
		@moderator = false

		# @demoted = 0
		@bubble = 0

		@prefs = {
			typing: true
		}

		if @room.dystopia
			@prefs.distraction = true

		@lock = false

		# sort of half a setting but not really
		@muwave = false

		# rate limiting and banning
		# @tribunal = null
		# @elect = null
		# @__tribunal_timeout = null
		# @__elect_timeout = null
		@__recent_actions = []
		@__rate_limited = 0

	link: (name) ->
		@room.log 'QuizPlayer.link(name) not implemented'


	emit: (name, data) ->
		@room.log 'QuizPlayer.emit(name, data) not implemented'

	modlog: (event, details) -> null

	# keep track of how long someone's been online
	# this function is called on user initiated actions
	touch: (no_add_time) ->
		@idle = false
		current_time = @room.serverTime() 
		unless no_add_time
			elapsed = current_time - @last_action
			if elapsed < 1000 * 60 * 10
				@time_spent += elapsed
		@last_action = current_time
		@room.touch()
		@room.check_timeout()


	active: -> @online() and (@room.serverTime() - @last_action) < 1000 * 60 * 10 and !@idle

	online: -> true

	level: ->
		x = @room.acl
		# returns the user's highest authorization level
		# you're a secret ninja
		return x.ninja if @id[0] is '_'
		
		# # this is kind of weird ordinally, but yeah
		# if @demoted and @demoted < x.baseline
		# 	return @demoted

		# you're a moderator/admin, we should decide on a term for this
		return x.moderator if @moderator # @id in @room.admins

		# an elected official
		return x.elected if @elect?.term > @room.serverTime()
		# in a failed democracy
		return x.unlocked if !@room.locked()
		# people with lots of points are special
		return x.fifty if @score() >= 50
		# at least the score is positive
		return x.positive if @score() > 0

		# lowly peon
		return x.baseline

	authorized: (level = @room.escalate) -> 
		level = @room.acl[level] if typeof level is 'string'
		@level() >= level

	score: ->
		sum = 0
		for key, [plus, neg] of @room.scoring
			sum += (@corrects[key] || 0) * plus + (@wrongs[key] || 0) * neg
		return sum
	
	metrics: ->
		epsilon = 0.001

		scoring = @room.scoring
		col_sum = (col) ->
			sum = 0
			sum += (col[key] || 0) for key of scoring
			return sum
		m = {
			score: @score()
			seen: @seen
			correct: col_sum(@corrects)
			wrong: col_sum(@wrongs)
		}
		m.guesses = m.correct + m.wrong

		m.precision = m.correct / (m.guesses + epsilon)
		m.recall = m.correct / (m.seen + epsilon)
		m.f1 = (2 * (m.precision * m.recall) / (m.precision + m.recall + epsilon))

		if @room?.scoring?.interrupt
			m.interrupts = (@wrongs.interrupt || 0) + (@wrongs.early || 0)
			m.early = (@corrects.early || 0)

		return m


	reset_score: ->
		m = @metrics()
		@verb "was reset from #{@score()} points (#{m.correct} correct, #{m.wrong} wrong, #{m.guesses} guesses)"
		@negstreak_record = @negstreak = @streak_record = @streak = @earlyseen = @seen = 0
		
		@wrongs = {}
		@corrects = {}

		@history = []
		@sync(true)

	bookmark: ({ value, id }) -> 0 # not implemented

	ban: -> 1

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


	reprimand: ({user, reason}) ->
		if @reprimand_embargo > @room.serverTime()
			@notify "can not reprimand anyone for #{Math.ceil((@reprimand_embargo - @room.serverTime())/1000)} seconds"
			return

		# lets limit the amount of spanks people can give
		unless @authorized @room.acl.moderator
			# unless you're a registered sex offender- erm. i mean moderator
			@reprimand_embargo = @room.serverTime() + 1000 * 60
			# propagate the bans you can not make
			@sync()
			
		# todo, make this less crude
		@room.users[user]?.emit 'reprimand', {
			trigger: @id,
			time: @room.serverTime(),
			reason: reason
		}


	gestapo: (string) ->
		return unless typeof string is 'string'
		return unless @room.dystopia
		for check in [/ni+gg+e+r/i, /n\s*i\s*g\s*g\s*e\s*r/i, /nigga/i]
			if string.match(check)
				@ban(1000 * 60 * 5)
				@sync(true)
				return true
		return false


	nominate: ->
		@touch()
		return if @room.escalate > @room.acl.unlocked

		if @elect_embargo and @elect_embargo > @room.serverTime()
			@notify 'can not run for reelection for another ' + Math.ceil((@elect_embargo - @room.serverTime()) / (1000 * 60)) + ' minutes'
			return 

		if !@elect
			# @verb "TERMPOEWJROSIJWER THIS PERSON IS A NARCONARC"
			current_time = @room.serverTime()
			witnesses = (id for id, user of @room.users when id[0] isnt "_" and user.active() and !user.prefs.distraction)
			@__elect_timeout = setTimeout =>
				@verb 'got romneyed', true
				
				@elect_embargo = @room.serverTime() + 1000 * 60 * 4 # romney can't run until 2016, no?

				@elect = null
				@sync(true)
			, 1000 * 60

			@elect = { votes: [], against: [], time: current_time, witnesses }
			# @sync(true)

			@vote_election { user: @id, position: 'elect' }

			# vote fer yerself





	create_tribunal: (initiator = false) ->
		@touch()
		if !@tribunal
			current_time = @room.serverTime()
			witnesses = (id for id, user of @room.users when id[0] isnt "_" and user.active() and !user.prefs.distraction)
			return if witnesses.length <= 1

			# Ummmm ahh such as like, 
			# like the one where I'm like mmm and it says, 
			# "I saw watchoo did there!" 
			# And like and and then like you peoples were all like, 
			# "YOU IS TROLLIN!" and I was like 
			# "I AM NOT TROLLING!! I AM BOXXY YOU SEE!"
			
			if @room.users[@tribunal?.initiator] and !@room.users[@tribunal?.initiator].authorized('moderator')
				@room.users[@tribunal.initiator].tribunal_embargo = @room.serverTime() + 1000 * 60

			@__tribunal_timeout = setTimeout =>
				if @room.users[@tribunal?.initiator] and !@room.users[@tribunal?.initiator].authorized('moderator')
					@room.users[@tribunal.initiator].tribunal_embargo = @room.serverTime() + 1000 * 60 * 4
					@room.users[@tribunal.initiator].sync()

				@verb 'survived the tribunal', true
				@tribunal = null
				@sync(true)
			, 1000 * 60

			@tribunal = { votes: [], against: [], time: current_time, witnesses, term: 0, initiator }
			
			@sync(true)

	trigger_tribunal: (user) ->
		@touch()
		return unless user and @room?.users[user]
		return unless @authorized('elected')

		if user is @id
			@notify 'is somewhat of a masochist'
			return

		if @tribunal_embargo and @tribunal_embargo > @room.serverTime()
			@notify 'can not trigger a ban tribunal for another ' + Math.ceil((@tribunal_embargo - @room.serverTime()) / (1000 * 60)) + ' minutes'
			return 

		if @room.users[user].authorized('moderator')
			@notify 'cannot fell a god with a mortal sword'
			return
		@verb 'created a ban tribunal for !@' + user
		
		# @modlog 'tribunal', "created ban tribunal for @#{user}"
		@room.users[user]?.create_tribunal @id

	ban_user: (user) ->
		if @authorized('moderator')
			if !@room.users[user]?.banned or @room.serverTime() > @room.users[user]?.banned
				# only wear the badge of accomplishment if you've done something new
				@verb('banned !@' + user + ' from /' + @room.name, true)

			@modlog 'ban', "banned @#{user} (#{!room.users[user]?.name}) from /#{room.name}"
			@room.users[user]?.ban(1000 * 60 * 15)

	# exercise your right and duty

	vote_election: ({user, position}) ->
		@touch()
		
		elect = @room.users[user]?.elect
		return unless elect

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

			if votes.length > (witnesses.length) / 2 + against.length
				# @room.users[user].verb 'gots the blanc haus', true
				term_length = 1000 * 60
				# there is a new species in new york; it can be aggressive if threatened
				witnesses = (id for id, u of @room.users when id[0] isnt "_" and u.active())
				@room.users[user].elect = { impeach: [], witnesses, term: @room.serverTime() + term_length }
				# let's go to the mall!
				@room.users[user].inaugurate()

			undecided = (witnesses.length - against.length - votes.length)
			if votes.length + undecided <= (witnesses.length) / 2 + against.length
				@room.users[user].verb 'was not elected', true
				@room.users[user].elect_embargo = @room.serverTime() + 1000 * 60 * 10
				@room.users[user].impeach()

			@room.users[user].sync(true)

		else if elect.term > @room.serverTime()
			{impeach, witnesses} = elect
			return unless @id in witnesses
			return if @id in impeach
			if position is 'impeach'
				impeach.push @id
				# @verb 'hates bill clinton'
				votes_needed = Math.floor((witnesses.length)/2 + 1) - impeach.length
				if votes_needed <= 0
					@room.users[user].verb 'was impeached from office', true
					@room.users[user].impeach()
				else
					@room.users[user].sync(true)

	# Come on Jessica, come on Tori,
	# Let's go to the mall, you won't be sorry
	# Put on your jelly bracelets
	# And your cool graffiti coat
	# At the mall, having fun is what it's all about

	inaugurate: ->
		return unless @elect?.term # this should be enough

		# must be quasi-protected method because we dont want to defeat the purpose
		# of having a convoluted system of bureaucracy!
		clearTimeout @__elect_timeout

		@__elect_timeout = setTimeout =>
			@verb 'is no longer commander in chief', true
			@impeach()
		, @elect.term - @room.serverTime()

	# also, that reference *did* actually make sense
	# As in, inaugurations take place on the national mall.


	impeach: ->
		# I Did Not Have Sexual Relations With That Woman
		@elect = null
		clearTimeout @__elect_timeout
		@sync(true)

	finish_term: ->
		# A True Cincinnatus you are
		return if !@elect?.term # this should be enough		
		@verb 'has finished tenure in office', true
		@impeach()

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
				@modlog 'tribunal', "user was banned by vote @#{user}"

				@room.users[user].verb 'got voted off the island', true
				clearTimeout @room.users[user].__tribunal_timeout
				@room.users[user].tribunal = null
				# @room.users[user].verb "was banned from #{@room.name}", true
				@room.users[user].ban(1000 * 60 * 15)

			undecided = (witnesses.length - against.length - votes.length - 1)
			if votes.length + undecided <= (witnesses.length - 1) / 2 + against.length

				if @room.users[@room.users[user]?.tribunal?.initiator]
					@room.users[@room.users[user].tribunal.initiator].tribunal_embargo = @room.serverTime() + 1000 * 60 * 8

				@modlog 'tribunal', "user was freed @#{user}"
				@room.users[user].verb 'was freed because of a hung jury', true
				@room.users[user].tribunal = null
				clearTimeout @room.users[user].__tribunal_timeout

			@room.users[user].sync(true)


	verb: (action, no_rate_limit) -> 
		# what happens to a ninja, stays to a ninja
		return @notify(action) if @id.toString()[0] is '_'

		@rate_limit() unless no_rate_limit

		@modlog 'verb', action if @room.escalate >= @room.acl.moderator and @authorized() and !no_rate_limit
		@room.emit 'log', { user: @id, verb: action, time: @room.serverTime() }

	notify: (action) ->
		# this is basically verb, but directed back at only the user
		@emit 'log', { user: @id, verb: action, time: @room.serverTime(), notify: true }

	disconnect_all: ->
		@room.log "QuizPlayer::disconnect_all() not implemented"

	disconnected: ->
		@touch()

		if @sockets.length is 0
			seconds = (@room.serverTime() - @last_session) / 1000
			if seconds > 90
				@verb "left the room (logged on #{Math.round(seconds/60)} minutes ago)"
			else if seconds > 1
				@verb "left the room (logged on #{Math.round(seconds)} seconds ago)"
			else
				@verb "left the room"
				
		@sync(true)

	echo: (data, callback) -> 
		if data.avg and data.std and data.n
			@__latency = [data.avg, data.std, data.n]
		callback @room.serverTime()

	buzz: (data, fn) -> 
		@touch()
		if @room.qid is data and @room.buzz(@id, fn)
			@rate_limit()

	guess: (data) -> 
		@touch()
		@room.guess @id, data
		@gestapo data?.text


	command: (name, args) ->
		if name is 'auth'
			if args[0]?.trim()
				@notify "
					Protobowl no longer uses escalation codes to authenticate
					moderators. The authentication system has been folded
					into the main system for logging into protobowl. Email
					info@protobowl.com with your old auth codes, rooms that 
					you can moderate, username and state the email address
					you use to login to protobowl. After that has been set up,
					you only need to type @$> auth without a password to escalate.
				"
			else if @auth
				if !@_check_moderator
					@notify "privilege escalation not implemented"
				else
					@_check_moderator (result) =>
						if @room?.name?.toLowerCase() in (result?.jurisdiction || [])
							@_apotheify(result.name)
						else
							@notify "is not authorized for this room"
			else
				@notify "You must be logged in to attempt moderator login."
		else if name in ['ragequit', 'qq', 'corgi', 'super', 'quit', 'dog', 'cute']
			@emit 'redirect', 'http://i.imgur.com/4Dx75Bq.jpg'
		else if name in ['deauth', 'unauth', 'resign', 'leave', 'quit', 'nixon']
			@cincinnatus()
		else if name in ['rename', 'name']
			@set_name args[0]?.trim()
		else
			@notify "no command named `#{name}` exists"

		# @notify "the computer has the evidence `#{name}` for `#{args}`"

	chat: ({text, done, first, session}) ->
		@touch()

		# obviously malformed things are bad
		return if typeof text != 'string'

		if @gestapo text
			text = '****'

		# discard chat messages if a radio silence is enforced
		return unless @authorized @room.mute
 		
		# Standing there alone,
		# the ship is waiting.
		# All systems are go.
		# "Are you sure?"
		# Control is not convinced,
		# but the computer
		# has the evidence.
		# No need to abort.
		# The countdown starts.

		if text.substr(0, 3) == '@$>' and done
			[name, args...] = text.substr(3).trim().split(' ')
			@command name, args
			return


 		# server enforced limit is 10x the client enforced limit
 		# is this a formulation of postel's rule?
 		# I don't know and I don't really care.
		text = text.slice(0, 10000)

		id = @id # ninjas should be able to choose their names
		id = '__' + @name.replace(/\s+/g, '_') if id[0] is '_'
		
		packet = { text, session, user: id, first, done, time: @room.serverTime() }

		# broadcast things to certain people
		if first
			# do a shallow object clone
			alt_packet = {}
			alt_packet[key] = val for key, val of packet
			alt_packet.text = '(typing)'

		# at this moment private messages are enforced on the end of the recipient
		# which is not a good thing because technically anyone can see the messages
		# and they aren't actually private, but that's probably okay for now
		
		if @room.serverTime() < @bubble
			@emit 'chat', packet
			return
		
		if done or text is '(typing)'
			# tell errybody!
			@rate_limit()
			@room.emit 'chat', packet

			if @authorized('moderator') and text isnt '(typing)'
				@modlog 'chat', text
		else
			# progressive chat updates (i.e. letter by letter)
			# are saved for websocket based connections
			for id, user of @room.users 
				if user.prefs.typing and !user.muwave
					user.emit 'chat', packet
				else if first
					user.emit 'chat', alt_packet


	
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
		@room.sync()

	preempt: ->
		@touch()
		# TODO: preemptive pausing, for when you're expecting to buzz immediately afterwards
		# this is more of a message to be communicated to all the other peers while waiting
		# for the authoritative peer (server) to process everything

	pause: ->
		@touch()
		return if @room.no_pause

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

	transfer_account: (cookie) -> @room.log 'QuizPlayer.transfer_account(cookie) not implemented'


	accelerate_cleanup: ->
		# warning! weird things happen sometimes because this doesn't
		# ensure first that all the sockets are closed
		if @score() <= 20
			@room.delete_user @id

	rtc_signal: (message) ->
		@room.users[message.target]?.emit 'rtc', { message: message, source: @id }

	##############################################################
	# Here are the things which are global settings
	##############################################################

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
		@room.sync(4)

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
		@room.sync(4)
		@room.get_size (size) =>
			@verb "set difficulty to #{data || 'everything'} (#{size} questions)"
			if size is 0 and @room.category
				@set_category ''

	set_category: (data) ->
		@touch()
		return unless @authorized()
		# @verb 'changed the category to something which needs to be changed'
		@room.category = data
		@room.reset_distribution() unless data # reset to the default question distribution 
		if data is 'custom'
			@room.sync(4)
		else
			@room.sync(1)
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

	set_pause: (state) ->
		@touch()
		return unless @authorized()
		@unpause()
		if state
			@verb 'enabled pausing questions'
		else
			@verb 'disabled pausing questions'
		@room.no_pause = !state
		@room.sync(1)


	set_bonus: (data) ->
		@touch()
		return unless @authorized()
		@room.show_bonus = !!data
		if @room.show_bonus
			@verb 'enabled showing bonus questions'
		else
			@verb 'disabled showing bonus questions'
		@room.sync(1)

	set_speed: (speed) ->
		@touch()
		return unless @authorized()
		return if isNaN(speed)
		return if speed <= 0
		@room.set_speed speed
		@room.sync(1)


	##############################################################
	# Here are global settings which aren't user-accessible
	# Hence the higher authentication necessary to enable them
	# because it's hard to disable them if some user were able
	# to somehow manually trigger them
	# If and when these settings gain user-accessible control
	# then their authorization criterion should be reduced and
	# moved away from this section.
	##############################################################

	set_duration: (duration) ->
		@touch()
		return unless @authorized 'ninja'
		return if isNaN(duration)
		return if duration <= 0
		@room.answer_duration = duration
		@room.set_speed @room.rate
		@room.sync(1)

	set_prompt_duration: (duration) ->
		@touch()
		return unless @authorized 'ninja'
		return if isNaN(duration)
		return if duration <= 0
		@room.prompt_duration = duration
		@room.sync(1)

	set_attempt_duration: (duration) ->
		@touch()
		return unless @authorized 'ninja'
		return if isNaN(duration)
		return if duration <= 0
		@room.attempt_duration = duration
		@room.sync(1)

	set_scoring: (matrix) ->
		@touch()
		return unless @authorized 'ninja'
		@verb 'changed scoring matrix'
		@room.scoring = matrix
		@room.sync(4)

	set_semi: (state) ->
		@touch()
		return unless @authorized 'ninja'
		if state
			@verb 'enabled semi-transparent readouts'
		else
			@verb 'disabled semi-transparent readouts'
		@room.semi = !!state
		@room.sync(1)

	set_type: (name) ->
		# well, this is sort of different
		# might not belong here
		@touch()
		return unless @authorized 'ninja'
		return @notify "error `#{state}` is not string" unless typeof name is 'string'
		if name
			@room.type = name
			@room.category = ''
			@room.difficulty = ''
			@room.sync(4)
			@room.get_size (size) =>
				@verb "changed the question type to #{name} (#{size} questions)"

	set_escalate: (state) ->
		# this should not ever be made user accessible for obvious reasons
		@touch()
		return unless @authorized 'ninja'
		return @notify "error `#{state}` is not number" unless typeof state is 'number'
		@room.escalate = state
		@room.sync(2)
		@verb "changed minimum escalation permission level to `#{state}`"
		# technically it's only a class 1 action, but requires a re-render of the 
		# leaderboard.

	set_mute: (state) ->
		@touch()
		return unless @authorized 'ninja'
		return @notify "error `#{state}` is not number" unless typeof state is 'number'
		@room.mute = state
		@room.sync(1)


	set_topic: (topic) ->
		@touch()
		return unless @authorized 'ninja'
		return @notify "error `#{state}` is not string" unless typeof topic is 'string'
		@room.topic = topic
		@room.sync(4)

	set_dystopia: (level) ->
		@touch()
		return unless @authorized 'ninja'
		@room.dystopia = level
		@room.sync(4)
		@verb "set dystopia mode to #{level}"

	##############################################################
	# Here are the user settings, no auth required
	##############################################################

	pref: (name, value) ->
		@touch()
		return unless typeof name is 'string'
		return if name in ['toString', 'toLocaleString', 'valueOf', 'hasOwnProperty', 'isPrototypeOf', 'propertyIsEnumerable', 'constructor']
		
		if name[0] != '_'
			@prefs[name] = value
			@sync(true)


	set_team: (name) ->
		@touch()
		if name
			@verb "switched to team #{name}"
		else if name isnt @name
			@verb "is playing as an individual"
		if name
			@team = name.slice(0, 100)
		else
			@team = name
		@sync(true)


	set_idle: (val) ->  
		# idle state doesn't matter and it's really a waste of packets
		# so dont send it until its convenient, that is, the next update
		@idle = !!val

	set_lock: (val) ->
		@lock = !!val
		@touch()
		@sync(true)

	set_name: (name) ->
		@touch()
		return if @moderator
		name = name + ''
		@gestapo(name)

		if name.trim().length > 0
			name_limit = 140
			
			if @room.dystopia
				name_limit = 30

			@name = name
				.trim() # remove whitespace
				.slice(0, name_limit) # limit to tweet size
				.replace(/\u202e|\u2606|\u2605|\u269d/g, '') # get rid of stars, and get rid of unicode rtl chars
			@sync(true)


	# for when the db is wrong
	report_question: -> @verb "QuizPlayer::report_question({id, tags}) not implemented"
	tag_question: -> @verb "QuizPlayer::tag_question({id, tags}) not implemented"
	change_bold: ->  @verb "QuizPlayer::change_bold({id, answer}) not implemented"
	# for when people think my algorith sucks
	report_answer: -> @verb "QuizPlayer::report_answer(data) not implemented"
	# well, that's kind of self explanatory
	check_public: -> @verb "QuizPlayer::check_public() not implemented"

	# underscore means it's not a publically accessibl emethod
	_apotheify: (admin_name) ->
		unless @moderator
			@mortal_nomen = @name
			@set_name admin_name
			@admin_begin = Date.now()

			@modlog 'mod', "now a moderator (nee #{@mortal_nomen})"
			@verb 'is now a moderator of this room'
			
			# @room.admins.push(@id)
			@moderator = true
			@room.sync(2) # technically level-1 not necessary, but level-0 doesnt prompt user rerender
	

	cincinnatus: ->
		if @moderator
			@modlog 'mod', "no longer a moderator (served for #{((Date.now() - @admin_begin) / 1000 / 60).toFixed(1)} minutes)"
			@verb 'is no longer a moderator of this room'
			# @room.admins = (id for id in @room.admins when id isnt @id)
			@moderator = false
			@admin_name = ''
			@admin_begin = 0
			@set_name @mortal_nomen if @mortal_nomen
			@room.sync(2) # technically level-1 not necessary, but level-0 doesnt prompt user rerender
			

	serialize: ->
		data = {}
		blacklist = ['sockets', 'room', 'times_buzzed', 'moderator']
		for attr of this when attr not in blacklist and typeof this[attr] not in ['function'] and attr[1] != '_'
			data[attr] = this[attr]
		return data

	deserialize: (obj) ->
		blacklist = ['tribunal', 'elect', 'times_buzzed', 'moderator']
		this[attr] = val for attr, val of obj when attr[1] != '_' and attr not in blacklist

		# upgrade scoring algorithm
		if @correct || @interrupts || @early || @guesses
			@verb 'was upgraded to the new scoring system'
			@corrects['normal'] = @correct
			@wrongs['normal'] = @guesses - @correct
			delete @correct
			@corrects['early'] = @early
			@wrongs['early'] = 0
			delete @early
			@corrects['interrupt'] = 0
			@wrongs['interrupt'] = @interrupts
			delete @interrupts
			delete @guesses
			@sync(true)

	update: -> 1


	sync: (broadcast = false) ->
		if broadcast and @id[0] isnt '_'
			@room.emit 'sync', @room.sync this
		else
			@emit 'sync', @room.sync this

exports.QuizPlayer = QuizPlayer if exports?
