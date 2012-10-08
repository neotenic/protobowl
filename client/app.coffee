#= require modernizr.js
#= require bootstrap.js
#= require plugins.coffee
#= require annotations.coffee
#= require buttons.coffee
#= require offline.coffee
#= require render.coffee
#= require time.coffee

sync = {}

time = -> if sync.time_freeze then sync.time_freeze else serverTime() - sync.time_offset
serverTime = -> new Date - sync_offset
connected = -> true

sock = io.connect()


class QuizPlayerSlave extends QuizPlayer
	# encapsulate is such a boring word, well actually, it's pretty cool
	# but you should be allowed to envelop actions like captain kirk 
	# does to a mountain.
	envelop_action: (name) ->
		master_action = this[name]
		this[name] = (data, callback) ->
			if connected()
				sock.emit(name, data, callback)
			else
				master_action.call(this, data, callback)

	constructor: (room, id) ->
		super(room, id)
		blacklist = ['envelop_action']
		@envelop_action name for name, method of this when typeof method is 'function' and name not in blacklist


class QuizRoomSlave extends QuizRoom
	# dont know what to change
	emit: (name, data) ->
		# console.log 'yaaaaaaaaaaaaaaaaaayyy?', name, data
		@__listeners[name](data)

	constructor: (name) ->
		super(name)
		@__listeners = {}


room = new QuizRoomSlave()
me = new QuizPlayerSlave(room, 'whatevs')

sock.on 'connect', ->
	$('.actionbar button').disable false
	$('.timer').removeClass 'disabled'
	$('.disconnect-notice').slideUp()
	sock.emit 'disco', {old_socket: localStorage.old_socket}

sock.on 'disconnect', ->
	sync.attempt = null if sync.attempt?.user isnt me.id # get rid of any buzzes
	line = $('<div>').addClass 'well'
	line.append $('<p>').append("You were ", $('<span class="label label-important">').text("disconnected"), 
			" from the server for some reason. ", $('<em>').text(new Date))
	line.append $('<p>').append("This may be due to a drop in the network 
			connectivity or a malfunction in the server. The client will automatically 
			attempt to reconnect to the server and in the mean time, the app has automatically transitioned
			into <b>offline mode</b>. You can continue playing alone with a limited offline set
			of questions without interruption. However, you might want to try <a href=''>reloading</a>.")
	addImportant $('<div>').addClass('log disconnect-notice').append(line)
	room.emit 'init_offline', 'yay' #obviously server wont pay attention to that
	# renderState()

# look at all these one liner events!
listen = (name, fn) ->
	sock.on name, fn
	room.__listeners[name] = fn

listen 'echo', (data, fn) -> fn 'alive'
listen 'application_update', -> applicationCache.update() if applicationCache?
listen 'application_force_update', -> $('#update').slideDown()
listen 'redirect', (url) -> window.location = url
listen 'alert', (text) -> window.alert text
listen 'chat', (data) -> chatAnnotation data
listen 'log', (data) -> verbAnnotation data
listen 'sync', (data) -> synchronize data

listen 'joined', (data) ->
	# public_name = data.name
	# public_id = data.id
	$('#username').val public_name
	$('#username').disable false

sync = {}
sync_offsets = []
latency_log = []
users = {}

synchronize = (data) ->
	if data
		sync_offsets.push +new Date - data.real_time
		compute_sync_offset()
		sync[attr] = val for attr, val of data
		
	if !data or 'users' of data
		for user in sync.users
			user.room = sync.name
			users[user.id] = user


	if (data and 'difficulties' of data) or ($('.difficulties')[0].options.length == 0 and sync.difficulties)
		renderParameters()

	renderUpdate()

	if !data or 'users' of data
		renderState()
	else
		renderPartial()


Avg = (list) -> Sum(list) / list.length
Sum = (list) -> s = 0; s += item for item in list; s
StDev = (list) -> mu = Avg(list); Math.sqrt Avg((item - mu) * (item - mu) for item in list)


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
	sync_offset = Avg(below)

	# console.log 'sec iter', below
	$('#sync_offset').text(sync_offset.toFixed(1) + '/' + StDev(below).toFixed(1) + '/' + StDev(sync_offsets).toFixed(1))

testLatency = ->
	return unless connected()
	initialTime = +new Date
	sock.emit 'echo', {}, (firstServerTime) ->
		recieveTime = +new Date
		sock.emit 'echo', {}, (secondServerTime) ->
			secondTime = +new Date
			CSC1 = recieveTime - initialTime
			CSC2 = secondTime - recieveTime
			SCS1 = secondServerTime - firstServerTime

			sync_offsets.push recieveTime - firstServerTime
			sync_offsets.push secondTime - secondServerTime

			latency_log.push CSC1
			latency_log.push SCS1
			latency_log.push CSC2
			# console.log CSC1, SCS1, CSC2

			compute_sync_offset()

			if latency_log.length > 0
				$('#latency').text(Avg(latency_log).toFixed(1) + "/" + StDev(latency_log).toFixed(1) + " (#{latency_log.length})")


setTimeout ->
	testLatency()
	setInterval -> 
		testLatency()
	, 30 * 1000
, 2000