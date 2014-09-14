#= library ./lib/socket.io.js
#= library ./jade/runtime.js
#= library ./jade/_compiled.js

#= include ./lib/modernizr.js
#= include ./lib/bootstrap.js
#= include ./lib/time.coffee
#= include ./lib/jquery.mobile.custom.js
#= include ./lib/bootbox.js
#= include ./lib/titlecase.js
#= include ./plugins.coffee

#= include ./auth.coffee
#= include ../shared/player.coffee
#= include ../shared/room.coffee

#= include ./lib/adaptrtc.js
#= include ./webrtc.coffee

#= include ./annotations.coffee
#= include ./render.coffee
#= include ./bindings.coffee


do ->
	if 'anachron' of location.query
		window.WebSocket = -> 0 

do ->
	try
		t = new Date protobowl_app_build
		# todo: add padding to minute so it looks less weird
		$('#version').text "#{t.getMonth()+1}/#{t.getDate()}/#{t.getFullYear() % 100} #{t.getHours()}:#{(t.getMinutes()/100).toFixed(2).slice(2)}"

	try
		js_time = new Date protobowl_app_build
		html_time = new Date protobowl_html_build
		time_delta = Math.abs(js_time - html_time)
		# console.log time_delta, protobowl_app_build, protobowl_html_build
		
		# this hardly ever makes a difference

		# if time_delta >= 60 * 60 # it shouldnt ever take more than a minute to compile
		# 	line = $('<div>').addClass 'alert alert-info'
		# 	line.append $("<div>").append("<b>Version mismatch!</b> It appears that you are running HTML generated for a different version of protobowl. This could happen if you loaded this page before a server update has fully propagated. This will most likely not impact your protobowl experience. ")
		# 	line.insertAfter("#history")




# asynchronously load the other code which doesn't need to be there on startup necessarily

initialize_offline = (cb = ->) ->
	return cb() if initialize_offline.initialized
	initialize_offline.initialized = true
	url = (protobowl_config?.static || '/') + 'offline.js'
	
	if protobowl_config?.cache_breaker
		url += "?#{(new Date(protobowl_html_build)) - 0}"

	$.ajax {
		url: url,
		cache: true,
		dataType: 'script',
		success: cb
	}


offline_startup = ->
	initialize_offline ->
		me_id = 'offline'

		if localStorage.hasOwnProperty("room-" + room.name)
			try
				tmp = JSON.parse(localStorage["room-" + room.name])
				if tmp.me_id isnt 'temporary'
					me_id = tmp.me_id
					room.deserialize tmp
				else
					tmp = null

		me.__listeners.joined {
			id: me_id,
			name: 'offline user'
		}

		if tmp?.users
			try
				for user in tmp.users when user.id is me_id
					me.deserialize user

		room.sync(5)
		me.verb 'joined the room'

		initialize_fallback() if initialize_fallback?

setTimeout ->
	if room.active_count() <= 1 and Math.random() < 0.001
		chatAnnotation({text: 'Feeling lonely? Just say "I\'m Lonely" and talk to me!' , user: '__protobot', done: true})
, 30 * 1000

setTimeout ->
	notifyLike() if navigator.onLine
, 1000 * 60 * 10

setTimeout ->
	notifyMobile() if navigator.onLine
, 1000 * 60 * 5

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
socket_pair_index = 0
connected_url = null

online_startup = ->
	# console.log 'online startup'
	# so some firewalls block unsecure websockets but allow secure stuff
	# so try to connect to both!
	connection_timeout = 5000
	
	socket_pair = protobowl_config?.sockets[socket_pair_index]
	
	secure_socket = null
	insecure_socket = null

	[insecure_url, secure_url] = socket_pair

	if 'sock' of location.query
		insecure_url = location.query.sock

	reconnect = ->
		# console.log 'reconnect'
		lsp = null
		try
			lsp = localStorage.protocookie

		cookie = location.query.id || jQuery.cookie('protocookie') || lsp
		authcookie = null
		
		if protobowl_config?.auth
			authcookie = jQuery.cookie('protoauth')
		
		if 'ninja' of location.query
			# xhr = new XMLHttpRequest()
			# xhr.open 'get', protobowl_config.sockets[0][0] + 'stalkermode/ninjacode', false
			# xhr.send()
			authcookie = location.query.ninja


		if !cookie
			dict = ''
			# generate a cookie for when it doesn't already exist
			cookie = 'PB4CL' + (Math.random().toString(36).slice(2, 6) for i in [0..8]).join('')
			# save it, because yeah, why not
			jQuery.cookie('protocookie', cookie)
			try
				localStorage.protocookie = cookie
				# store it on localstorage in case cookie is emptied

		# you might ask why auth and cookie are both sent and more deeply
		# why there are two separate state cookies, well the answer is that 
		# the auth cookie is server generated (i.e. hmac verified) whereas the
		# normal state cookie is a client-generated random string which is taken
		# unverified

		# if for some reason the auth cookie fails verification, the server needs
		# to fall back on the unverified state cookie to save some kind of convoluted
		# close-socket-retry mechanism
		try
			refs = JSON.parse(localStorage.referrers || '[]') || []
			if document.referrer and document.referrer not in refs
				refs.push document.referrer
			localStorage.referrers = JSON.stringify(refs)

		sock.emit 'join', {
			cookie,
			auth: authcookie,
			question_type: room.type,
			room_name: room.name,
			# old_socket: localStorage.old_socket,
			muwave: 'muwave' of location.query,
			custom_id: location.query.id,
			agent: "M4/Web",
			agent_version: "#{protobowl_app_build}"
			referrers: refs,
			version: 8
		}

		$('.disconnect-notice, .doom-notice').slideUp()
		# allow the user to reload/disconnect/reconnect
		$('#reload, #disconnect, #reconnect').hide()
		$('#disconnect').show()


	select_socket = (socket) ->
		# console.log 'SOCK SELECTOR'
		if sock and sock isnt socket
			# console.log 'disconnecting from select'
			sock.disconnect()

		if sock
			sock.removeAllListeners()
		

		sock = socket
		if sock is secure_socket
			verbAnnotation {verb: "established a connection to the secure server"}
			connected_url = secure_url
		else
			connected_url = insecure_url
			if sock.socket.options.secure
				verbAnnotation {verb: "established a connection to the server (secure)"}
			else
				verbAnnotation {verb: "established a connection to the server"}
	
		sock.on 'disconnect', ->
			# console.log 'DISCOWAT', sock?.hide_disconnect
			unless sock?.hide_disconnect
				disconnect_notice()

		for name, fn of me.__listeners
			sock.on name, fn

		reconnect()
		# localStorage.old_socket = sock.socket.sessionid
	
	check_connection = (socket) ->
		$("#load_error").remove()
		# console.log 'checking connection', socket
		if sock
			if sock is socket
				reconnect()
			else
				setTimeout ->
					if sock.socket.connected is true
						# console.log 'disconnecting'
						socket.disconnect()
						socket.removeAllListeners()
					else
						# console.log 'selecting socket'
						select_socket socket
				, 2718
		else
			select_socket socket

	check_exhaust = (socket) ->
		if !socket.socket.transport
			console.log 'ran out of options sir'
		console.log 'connect fail', socket

	valid_attempts = 0
	num_failures = 0
	connection_error = (e) ->
		num_failures++
		if num_failures is valid_attempts
			# everything has failed, life is a failure
			
			if protobowl_config?.sockets?.length > socket_pair_index + 1
				# protobowl_config?.sockets.shift()
				socket_pair_index++
				online_startup()
			else
				console.log 'errythings failed capn'
				offline_startup()

				
			# console.log 'connection error', num_failures, valid_attempts, e


	try
		valid_attempts++

		insecure_socket = io.connect insecure_url || location.hostname, {
			"connect timeout": connection_timeout,
			"force new connection": true
		}
		insecure_socket.on 'connect', -> check_connection(insecure_socket)
		insecure_socket.on 'connect_failed', -> check_exhaust(insecure_socket)
		insecure_socket.on 'error', connection_error
		
	catch err
		connection_error()

	if location.protocol is 'http:' and secure_url
		try
			valid_attempts++
			secure_socket = io.connect secure_url, {
				"port": 443,
				"connect timeout": connection_timeout,
				"force new connection": true,
				"secure": true
			}
			secure_socket.on 'connect', -> check_connection(secure_socket)
			secure_socket.on 'connect_failed', -> check_exhaust(secure_socket)
			secure_socket.on 'error', connection_error
		catch err
			connection_error()




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

	authorized: (level) ->
		return true unless connected()
		return super(level)

	envelop_action: (name) ->
		# master_action = this[name]
		return (data, callback) ->
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

	pref: (name, value) ->
		@prefs[name] = value
		if @id is me.id
			me.prefs[name] = value

		@remote_pref(name, value)

	constructor: (room, id) ->
		super(room, id)
		@__listeners = {}

		# the difference between local-exec and remote-exec code is a little weird
		# i don't exactly like the concept of needing to maintain an exception list
		# and it would have been probably a good idea if it was instead something like
		# functions starting with get_ are treated as local-exec, but I dont feel like
		# propagating a breaking change 

		blacklist = ['envelop_action', 'level', 'score', 'metrics', 'online', 'active', 'authorized', 'emit', 'pref']
		
		for name, method of this when typeof method is 'function'
			if name not in blacklist
				this[name] = @envelop_action name
			else
				this['remote_' + name] = @envelop_action name




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

	deserialize: (data) ->
		blacklist = ['users', 'attempt', 'generating_question', 'acl']
		for attr, val of data when attr not in blacklist
			@[attr] = val
		# for user in data.users
		# 	u = new SocketQuizPlayer(@, user.id)
		# 	@users[user.id] = u
		# 	u.deserialize(user)

room = new QuizRoomSlave(location.pathname.replace(/^\/*/g, '').toLowerCase() || 'temporary')
room.type = (if room.name.split('/').length is 2 then room.name.split('/')[0] else 'qb')
me = new QuizPlayerSlave(room, 'temporary')
do ->
	document.title = "#{room.name} - Protobowl"
	type_mapping = {
		qb: 'Quizbowl'
		jeopardy: 'Jeopardy!'
		scibowl: 'Science Bowl'
	}
	
	if room.name.split('/').length > 1
		$('<span>')
			.addClass('label label-info')
			.text(type_mapping[room.type] || room.type.toTitleCase())
			.insertAfter('.logo')
			.after(' ')

# look at all these one liner events!
listen = (name, fn) -> me.__listeners[name] = fn

# probably should figure out some more elegant way to do things, but then again
# these things hardly actually need to be frequently added - it's mostly hacks
listen 'echo', (data, fn) -> fn 'alive'
listen 'application_update', -> cache_update?()
listen 'force_application_update', -> cache_update?() # there is no longer a functional difference between force and non force
listen 'impending_doom', -> impending_doom()
listen 'redirect', (url) -> 
	room._redirected = true
	window.location = url
listen 'alert', (text) -> window.alert text
listen 'chat', (data) -> chatAnnotation data
listen 'log', (data) -> verbAnnotation data
listen 'bold', (data) -> boldAnnotation data
listen 'reprimand', (data) -> reprimandAnnotation data
listen 'debug', (data) -> logAnnotation data
listen 'sync', (data) -> synchronize data
listen 'rtc', ({message, source}) -> onRTCSignal(source, message)

listen 'throttle', (data) ->
	createAlert('Throttled', "The server is ignoring you for a while because you've been doing too many things too quickly. ")
		.addClass('alert-error')
		.insertAfter(".bundle.active .annotations")

listen 'verify', (data) -> logged_in? data

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
	if assertion? and assertion
		me.link assertion

	has_connected = true

	$('#slow').slideUp()
	$('.disconnect-notice').slideUp()
	me.id = data.id
	me.ip = data.ip # hey, this isn't actually terribly useful

	found_ip?(data.ip)

	room.users[me.id] = new QuizPlayerClient(room, me.id)

	me.name = data.name

	if me.id[0] != '_' and me.id isnt 'temporary'
		uid_name = 'username' + (auth?.email || '')
		try
			if localStorage[uid_name]
				if !data.existing
					setTimeout ->
						me.name = localStorage[uid_name]
						me.set_name me.name
						$('#username').val me.name
					, 137 # for some reason there's this odd bug where
					# if i dont have a timeout, this doesn't update the
					# stuff at all, so I really don't understand why
					# and moreover, I think the fine structure constant
					# is an appropriate metaphor for that non-understanding
			else
				localStorage[uid_name] = data.name

	if data.muwave and data.muwave <= 34
		unless window.WebSocket
			$(".no-websocket").show()
		$("#polling").slideDown()


	$('.actionbar button').disable false

	$('#username').val me.name
	$('#username').disable false


	# setTimeout load_bookmarked_questions, 100
	setTimeout initialize_offline, 100




sync_offsets = []
latency_log = []
last_freeze = -1

synchronize = (data) ->
	blacklist = ['real_time', 'users']
	
	sync_offsets.push +new Date - data.real_time
	compute_sync_offset()
	
	if 'realm' of data and data.realm
		unless connected_url in data.realm
			if data.realm?.join(';') isnt room.realm?.join(';')
				addImportant($("<div>").html('<strong>Warning</strong> You are currently connected to a server which is not registered as this room\'s proper realm.').addClass('alert'))
		

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

		# console.log data.realm, connected_url

	$('body').toggleClass('offline', !connected())

	renderParameters() if 'difficulties' of data
	renderUpdate()
	renderPartial()
	render_admin_panel()
	
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


$(window).unload ->
	if room._redirected
		delete localStorage['room-' + room.name]
	else
		tmp = room.serialize()
		tmp.me_id = me.id
		tmp.archive_time = Date.now()
		localStorage['room-' + room.name] = JSON.stringify(tmp)

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

retrieval_queue = []
find_question = (qid, callback) ->
	# this is a database method which 
	retrieval_queue.push [qid, callback]
	# console.log retrieval_queue
	dispose_retrieval_queue?()
		

set_bookmark = (qid, state) ->
	console.log 'setting book', qid, state
	find_question qid, (question) ->
		# console.log 'setting bookmark', qid, question, state
		if question
			question.bookmarked = state
			question.modified = Date.now()
			Questions.put question, (e) ->
				# console.log 'updated bookmarked state'
				check_bookmark qid
				update_storage_stats?()
			, handle_db_error
		else
			console.log 'question not found (set bookmark)', qid


check_bookmark = (qid) ->
	find_question qid, (question) ->
		# console.log 'checking bookmark', qid, question
		if question
			bookmarked = question.bookmarked
			bundle = $(".qid-#{qid}")
				.toggleClass('bookmarked', !!bookmarked)
				.toggleClass('bookmark-2', bookmarked is 2)
				.toggleClass('bookmark-3', bookmarked is 3)
				.toggleClass('bookmark-4', bookmarked >= 4)
			bundle.find('.bookmark')
				.toggleClass('icon-star-empty', !bookmarked)
				.toggleClass('icon-star', !!bookmarked)
		# who really cares otherwise, because if the question
		# isnt in the database, then it certainly wont be 
		# bookmarked
		# else
		# 	console.log 'question not found', qid
	

render = (name, params = {}) ->
	el = document.getElementById('_' + name)
	unless el
		el = $("<div>").attr('id', '_' + name)

	$(el).empty().append(jade[name](params))


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



if (('onLine' of navigator) and navigator.onLine is false) or !io? or protobowl_config?.offline or location.pathname in ['/bookmarks'] 
	offline_startup()
else
	online_startup()
	setTimeout ->
		$('#slow').slideDown() if !has_connected
	, 1000 * 3

	setTimeout initialize_offline, 2000
	

$("#load_error").remove() # no problems, mam, everything's a-ok


$("#disconnect").click (e) ->
	sock.disconnect()
	e.preventDefault()

$("#reconnect").click (e) ->
	sock.socket.reconnect()
	e.preventDefault()
	
