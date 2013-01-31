#= require ./lib/modernizr.js
#= require ./lib/bootstrap.js
#= require ./lib/bootbox.js
#= require ./lib/time.coffee
#= require ./lib/jquery.mobile.custom.js
#= require ./lib/jquery.tablesort.js

#= require plugins.coffee
#= require annotations.coffee
#= require render.coffee
#= require ../shared/player.coffee
#= require ../shared/room.coffee
#= require ../shared/c2r.coffee
#= require buttons.coffee

do ->
	if 'anachron' of location.query
		window.WebSocket = -> 0 

do ->
	try
		t = new Date protobowl_app_build
		# todo: add padding to minute so it looks less weird
		$('#version').text "#{t.getMonth()+1}/#{t.getDate()}/#{t.getFullYear() % 100} #{t.getHours()}:#{(t.getMinutes()/100).toFixed(2).slice(2)}"


# asynchronously load the other code which doesn't need to be there on startup necessarily
initialize_offline = (cb) ->	
	$.ajax {
		url: '/offline.js',
		cache: true,
		dataType: 'script',
		success: cb
	}


offline_startup = ->
	initialize_offline ->
		me.__listeners.joined {
			id: 'offline',
			name: 'offline user'
		}
		
		room.sync(4)
		me.verb 'joined the room'


		initialize_fallback() if initialize_fallback?

setTimeout ->
	if room.active_count() <= 1 and Math.random() < 0.01
		chatAnnotation({text: 'Feeling lonely? Just say "I\'m Lonely" and talk to me!' , user: '__protobot', done: true})
, 30 * 1000

setTimeout ->
	notifyLike() if navigator.onLine
, 1000 * 60 * 10


impending_doom = ->
	line = $('<div>').addClass 'alert alert-info'
	line.append $('<div>').append("A  ", $('<span class="label label-info">').text("server restart"), " will happen momentarily. This may result in a message indicating that you have been disconnected from the server. However, don't panic as a new connection will automatically be established shortly afterwards. ")
	addImportant $('<div>').addClass('log doom-notice').append(line)

disconnect_notice = ->
	initialize_fallback() if initialize_fallback?

	$('#reload, #disconnect, #reconnect').hide()
	$('#reconnect').show()
	room.attempt = null if room.attempt?.user isnt me.id # get rid of any buzzes
	line = $('<div>').addClass 'alert alert-error'
	line.append $('<p>').append("You were ", $('<span class="label label-important">').text("disconnected"), 
			" from the server for some reason. ", $('<em>').text(new Date))
	line.append $('<div>').append("This may be due to a drop in the network 
			connectivity or a malfunction in the server. The client will automatically 
			attempt to reconnect to the server and in the mean time, the app has automatically transitioned
			into <b>offline mode</b>. You can continue playing alone with a limited offline set
			of questions without interruption. However, you might want to try <a href=''>reloading</a>.")
	addImportant $('<div>').addClass('log disconnect-notice').append(line)

	$.getJSON 'https://api.github.com/gists/4272390?callback=?', ({data, meta}) ->
		if data?.files?['protobowl-status.html']?.content not in ['Nothing', null]
			message = $('<div>').addClass 'emergency-message'
			message.append $('<div>').addClass('alert alert-info').html(data.files['protobowl-status.html'].content)
			$('.emergency-message').remove()
			$('#history').before message

	renderUsers() # show transition to offline mode
	renderTimer() # update the offline badge



# this is the slightly overcomplicated system 
has_connected = false
sock = null

online_startup = ->

	reconnect = ->
		cookie = location.query.id || jQuery.cookie('protocookie')

		sock.emit 'join', {
			cookie,
			question_type: room.type,
			room_name: room.name,
			# old_socket: localStorage.old_socket,
			muwave: 'muwave' of location.query,
			custom_id: location.query.id,
			version: 6
		}

		$('.disconnect-notice, .doom-notice').slideUp()
		# allow the user to reload/disconnect/reconnect
		$('#reload, #disconnect, #reconnect').hide()
		$('#disconnect').show()


	select_socket = (socket) ->
		if sock and sock isnt socket
			console.log 'disconnecting from select'
			sock.disconnect()

		if sock
			sock.removeAllListeners()
		
		sock = socket
		if sock is secure_socket
			verbAnnotation {verb: "established a connection to the secure server"}
		else
			if sock.socket.options.secure
				verbAnnotation {verb: "established a connection to the server (secure)"}
			else
				verbAnnotation {verb: "established a connection to the server"}
	
		sock.on 'disconnect', disconnect_notice

		for name, fn of me.__listeners
			sock.on name, fn

		reconnect()
		# localStorage.old_socket = sock.socket.sessionid
	
	check_connection = (socket) ->
		$("#load_error").remove()
		if sock
			if sock is socket
				reconnect()
			else
				setTimeout ->
					if sock.socket.connected is true
						socket.disconnect()
						socket.removeAllListeners()
					else
						select_socket socket
				, 2718
		else
			select_socket socket

	check_exhaust = (socket) ->
		if !socket.socket.transport
			console.log 'ran out of options sir'
		console.log 'connect fail', socket

	# so some firewalls block unsecure websockets but allow secure stuff
	# so try to connect to both!
	connection_timeout = 5000

	insecure_socket = io.connect location.hostname, {
		"connect timeout": connection_timeout,
		"force new connection": true
	}
	insecure_socket.on 'connect', -> check_connection(insecure_socket)
	insecure_socket.on 'connect_failed', -> check_exhaust(insecure_socket)

	if location.protocol is 'http:'
		if location.hostname is 'localhost'
			secure_socket = io.connect 'localhost', {
				"port": 1337,
				"connect timeout": connection_timeout,
				"force new connection": true
			}
		else
			secure_socket = io.connect 'https://protobowl.nodejitsu.com/', {
				"port": 443,
				"connect timeout": connection_timeout,
				"force new connection": true,
				"secure": true
			}
		secure_socket.on 'connect', -> check_connection(secure_socket)
		secure_socket.on 'connect_failed', -> check_exhaust(secure_socket)




bookmarks_loaded = false
load_bookmarked_questions = ->
	return if bookmarks_loaded
	bookmarks_loaded = true

	bookmarks = []
	try
		bookmarks = JSON.parse(localStorage.bookmarks)
	for question in bookmarks || []
		continue if question.qid is room.qid
		bundle = create_bundle(question)
		bundle.find('.readout').hide()
		$('#bookmarks').prepend bundle

	update_visibility()

# stress test da servs
# setTimeout ->
# 	location.href = "/#{Math.random().toString().slice(3)}"
# , 1000

connected = -> sock? and sock.socket.connected

class QuizPlayerClient extends QuizPlayer
	online: -> @online_state

	emit: (args...) -> me.emit args... if @id is me.id


class QuizPlayerSlave extends QuizPlayerClient
	# encapsulate is such a boring word, well actually, it's pretty cool
	# but you should be allowed to envelop actions like captain kirk 
	# does to a mountain.
	
	emit: (name, data) ->
		if fallback_connection? and fallback_connection()
			fallback_broadcast(name, data)
		else
			@__listeners[name](data)

	authorized: (level = 1) ->
		return true unless connected()
		return super(level)

	envelop_action: (name) ->
		# master_action = this[name]
		this[name] = (data, callback) ->
			if connected()
				sock.emit(name, data, callback)
			else if fallback_connection? and fallback_connection()
				fallback_emit name, data, callback
			else
				# It matters not how strait the gate,
				# How charged with punishments the scroll.
				# I am the master of my fate:
				# I am the captain of my soul. 

				# TODO: possibly delay this call until certain offline component is loaded
				# master_action.call(this, data, callback)
				room.users[me.id]?[name]?(data, callback)

	constructor: (room, id) ->
		super(room, id)
		@__listeners = {}

		# the difference between local-exec and remote-exec code is a little weird
		# i don't exactly like the concept of needing to maintain an exception list
		# and it would have been probably a good idea if it was instead something like
		# functions starting with get_ are treated as local-exec, but I dont feel like
		# propagating a breaking change 

		blacklist = ['envelop_action', 'level', 'score', 'online', 'active', 'authorized', 'emit']
		@envelop_action name for name, method of this when typeof method is 'function' and name not in blacklist




class QuizRoomSlave extends QuizRoom
	# dont know what to change
	emit: (args...) -> me.emit args...

	constructor: (name) ->
		super(name)

	load_questions: (cb) ->
		if load_questions?
			load_questions cb
		else
			setTimeout =>
				@load_questions cb
			, 100

	check_answer: (attempt, answer, question) -> checkAnswer(attempt, answer, question) 

	get_parameters: (type, difficulty, cb) ->
		@load_questions ->
			get_parameters(type, difficulty, cb)

	count_questions: (type, difficulty, category, cb) ->
		@load_questions ->
			count_questions(type, difficulty, category, cb)

	get_question: (cb) ->
		@load_questions =>
			category = (if @category is 'custom' then @distribution else @category)
			get_question @type, @difficulty, category, (question) =>
				cb(question || error_question)


room = new QuizRoomSlave(location.pathname.replace(/^\/*/g, '').toLowerCase() || 'temporary')
room.type = (if room.name.split('/').length is 2 then room.name.split('/')[0] else 'qb')
me = new QuizPlayerSlave(room, 'temporary')

# look at all these one liner events!
listen = (name, fn) ->
	# sock.on name, fn if sock?
	me.__listeners[name] = fn

# probably should figure out some more elegant way to do things, but then again
# these things hardly actually need to be frequently added - it's mostly hacks
listen 'echo', (data, fn) -> fn 'alive'
listen 'application_update', -> applicationCache.update() if applicationCache?
listen 'force_application_update', -> $('#update').data('force', true); applicationCache.update()
listen 'impending_doom', -> impending_doom()
listen 'redirect', (url) -> window.location = url
listen 'alert', (text) -> window.alert text
listen 'chat', (data) -> chatAnnotation data
listen 'log', (data) -> verbAnnotation data
listen 'debug', (data) -> logAnnotation data
listen 'sync', (data) -> synchronize data
listen 'throttle', (data) ->
	createAlert $('.bundle.active'), 'Throttled', "The server is ignoring you for a while because you've been doing too many things too quickly. "

listen 'rename_user', ({old_id, new_id}) ->
	if me.id is old_id
		me.id = new_id
		room.users[me.id] = room.users[old_id]

	$(".user-#{old_id}").removeClass("user-#{old_id}").addClass("user-#{new_id}")
	delete room.users[old_id]

listen 'delete_user', (id) ->
	delete room.users[id]
	renderUsers()

listen 'joined', (data) ->
	has_connected = true
	$('#slow').slideUp()
	$('.disconnect-notice').slideUp()

	me.id = data.id
	
	room.users[me.id] = new QuizPlayerClient(room, me.id)

	me.name = data.name

	if me.id[0] != '_' and me.id isnt 'temporary'
		try
			if localStorage.username
				if !data.existing
					setTimeout ->
						me.name = localStorage.username
						me.set_name me.name
						$('#username').val me.name
					, 137 # for some reason there's this odd bug where
					# if i dont have a timeout, this doesn't update the
					# stuff at all, so I really don't understand why
					# and moreover, I think the fine structure constant
					# is an appropriate metaphor for that non-understanding
			else
				localStorage.username = data.name

	if data.muwave and data.muwave <= 34
		unless window.WebSocket
			$(".no-websocket").show()
		$("#polling").slideDown()


	$('.actionbar button').disable false

	$('#username').val me.name
	$('#username').disable false


	setTimeout load_bookmarked_questions, 100


sync_offsets = []
latency_log = []
last_freeze = -1

synchronize = (data) ->
	blacklist = ['real_time', 'users']
	
	sync_offsets.push +new Date - data.real_time
	compute_sync_offset()
	
	room[attr] = val for attr, val of data when attr not in blacklist

	if connected()
		if 'timing' of data or room.__last_rate isnt room.rate
			cumsum = (list, rate) ->
				sum = 0 #start nonzero, allow pause before rendering
				for num in [5].concat(list).slice(0, -1)
					sum += Math.round(num * rate) #always round!
			room.cumulative = cumsum room.timing, room.rate
			room.__last_rate = room.rate

	if 'users' of data
		# keep the number of people in the leaderboard at a manageable number
		# if (1 for u of room.users).length > data.users.length + 5
		# 	room.users = {}

		user_blacklist = ['id']
		for user in data.users
			unless user.id of room.users
				room.users[user.id] = new QuizPlayerClient(room, user.id)

			for attr, val of user when attr not in user_blacklist
				room.users[user.id][attr] = val
			
			# me != users[me.id] 
			# that's a fairly big change that is being implemented
			
			if user.id is me.id
				for attr, val of user when attr not in user_blacklist
					me[attr] = val

	$('body').toggleClass('offline', !connected())

	renderParameters() if 'difficulties' of data
	renderUpdate()
	renderPartial()
	
	if last_freeze isnt room.time_freeze
		last_freeze = room.time_freeze
		variable = (if room.attempt then 'starts' else 'stops')
		del = room.time_freeze - room.begin_time
		i = 0
		i++ while del > room.cumulative[i]
		starts = ($('.bundle.active').data(variable) || [])
		starts.push(i - 1) if (i - 1) not in starts
		$('.bundle.active').data(variable, starts)

		updateInlineSymbols()


	renderUsers() if 'users' of data

listen 'finish_question', (time) ->
	del = time - room.begin_time
	i = 0
	i++ while del > room.cumulative[i]
	$('.bundle.active').data('finish_point', i - 1)
	updateInlineSymbols()

# basic statistical methods for statistical purposes
Avg = (list) -> Sum(list) / list.length
Sum = (list) -> s = 0; s += item for item in list; s
StDev = (list) -> mu = Avg(list); Math.sqrt Avg((item - mu) * (item - mu) for item in list)

# so i hears that robust statistics are bettrawr, so uh, heres it is
Med = (list) -> m = list.sort((a, b) -> a - b); m[Math.floor(m.length/2)] || 0
IQR = (list) -> m = list.sort((a, b) -> a - b); (m[~~(m.length*0.75)]-m[~~(m.length*0.25)]) || 0
MAD = (list) -> m = list.sort((a, b) -> a - b); Med(Math.abs(item - mu) for item in m)



compute_sync_offset = ->
	#here is the rather complicated code to calculate
	#then offsets of the time synchronization stuff
	#it's totally not necessary to do this, but whatever
	#it might make the stuff work better when on an
	#apple iOS device where screen drags pause the
	#recieving of sockets/xhrs meaning that the sync
	#might be artificially inflated, so this could
	#counteract that. since it's all numerical math
	#hopefully it'll be fast even if sync_offsets becomes
	#really really huge

	
	sync_offsets = sync_offsets.slice(-20)
	thresh = Avg sync_offsets
	below = (item for item in sync_offsets when item <= thresh)
	sync_offset = Avg(below)
	# console.log 'frst iter', below
	thresh = Avg below
	below = (item for item in sync_offsets when item <= thresh)
	room.sync_offset = Avg(below)

	# console.log 'sec iter', below
	$('#sync_offset').text(room.sync_offset.toFixed(1) + '±' + StDev(below).toFixed(1) + ' (' + sync_offsets.length + ')')


page_birthday = Date.now()

test_latency = ->
	return unless connected()
	
	# this isn't particularly relevant to latency testing
	# check if the user has been inactive for over an hour

	idle_disconnect = 1000 * 60 * 60 # one hour

	# incase for some reason the idle time doesn't update
	if room.serverTime() - me.last_action > idle_disconnect and Date.now() - page_birthday > idle_disconnect
		sock.disconnect()
		bootbox.dialog "<h4>Disconnected for Inactivity</h4> <p>You have been disconnected from the server for an extended period of inactivity.</p> <p>Simply press <span class='label label-info'>Reconnect</span> if you wish to reestablish a connection to the server to resume from the previous state, or press <span class='label'>Cancel</span> if you would like to continue using protobowl offline.</p> ", [
			{
				label: "Cancel"
			},
			{
				label: "Reconnect",
				class: "btn-primary",
				callback: ->
					sock.socket.reconnect()
					page_birthday = Date.now()
			}
		]

	initialTime = +new Date
	sock.emit 'echo', {}, (firstServerTime) ->
		recieveTime = +new Date
		
		CSC1 = recieveTime - initialTime
		latency_log.push CSC1
		sync_offsets.push recieveTime - firstServerTime

		sock.emit 'echo', { avg: Avg(latency_log.slice(-10)), std: StDev(latency_log.slice(-10)), n: latency_log.length }, (secondServerTime) ->
			secondTime = +new Date
			CSC2 = secondTime - recieveTime
			SCS1 = secondServerTime - firstServerTime

			sync_offsets.push secondTime - secondServerTime

			latency_log.push SCS1
			latency_log.push CSC2

			compute_sync_offset()

			if latency_log.length > 0
				$('#latency').text(Avg(latency_log).toFixed(1) + "±" + StDev(latency_log).toFixed(1) + " (#{latency_log.length})")


setTimeout ->
	recurring_test = ->
		test_latency()
		delay = 30 * 1000
		delay = 3 * 60 * 1000 if me.muwave # longer delay when you dont like server reqs
		setTimeout recurring_test, delay
	recurring_test()
, 8000


cache_event = ->
	status = applicationCache.status
	switch applicationCache.status
		when applicationCache.UPDATEREADY
			$('#cachestatus').text 'Updated'
			#applicationCache.swapCache()
			$('#update').slideDown()		
			if localStorage.auto_reload is "yay" or $('#update').data('force') is true
				setTimeout ->
					location.reload()
				, 200 + Math.random() * 1000
			else
				setTimeout ->
					bootbox.alert "Your current version of Protobowl is obsolete, this page will be automatically reloaded in 10 seconds."
					setTimeout ->
						location.reload()
					, 1000 * 10
				, 1000 * 60 * 5
			applicationCache.swapCache()
		when applicationCache.UNCACHED
			$('#cachestatus').text 'Uncached'
		when applicationCache.OBSOLETE
			$('#cachestatus').text 'Obsolete'
		when applicationCache.IDLE
			$('#cachestatus').text 'Cached'
		when applicationCache.DOWNLOADING
			$('#cachestatus').text 'Downloading'
		when applicationCache.CHECKING
			$('#cachestatus').text 'Checking'

do -> # isolate variables from globals

	# listen for hiddens
	if document.hidden? then hidden = 'hidden'; event = 'visibilitychange'
	else if document.mozHidden? then hidden = 'mozHidden'; event = 'mozvisibilitychange'
	else if document.msHidden? then hidden = 'msHidden'; event = 'msvisibilitychange'
	else if document.webkitHidden? then hidden = 'webkitHidden'; event = 'webkitvisibilitychange'
	
	if hidden
		document.addEventListener event, ->
			me.set_idle document[hidden] unless me.muwave
		, false

	if window.applicationCache
		for name in ['cached', 'checking', 'downloading', 'error', 'noupdate', 'obsolete', 'progress', 'updateready']
			applicationCache.addEventListener name, cache_event, false


if io?
	online_startup()
	setTimeout ->
		$('#slow').slideDown() if !has_connected
	, 1000 * 3

	setTimeout initialize_offline, 3000
else
	offline_startup()

$("#load_error").remove() # no problems, mam, everything's a-ok


$("#disconnect").click (e) ->
	sock.disconnect()
	e.preventDefault()

$("#reconnect").click (e) ->
	sock.socket.reconnect()
	e.preventDefault()
	