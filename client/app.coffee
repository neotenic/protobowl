#= require modernizr.js
#= require bootstrap.js
#= require fireworks.coffee
#= require annotations.coffee
#= require buttons.coffee
#= require offline.coffee
#= require render.coffee
#= require time.coffee

sync = {}

time = -> if sync.time_freeze then sync.time_freeze else serverTime() - sync.time_offset
serverTime = -> new Date - sync_offset
connected = -> true
avg = (list) -> sum(list) / list.length
sum = (list) -> s = 0; s += item for item in list; s
stdev = (list) -> mu = avg(list); Math.sqrt avg((item - mu) * (item - mu) for item in list)

sock = io.connect()


class RemoteQuizPlayer
	emit_action: (name) ->
		this[name] = (data, callback) ->
			sock.emit name, data, callback
	constructor: ->
		blacklist = []
		@emit_action attr for attr of QuizPlayer.prototype when attr not in blacklist


me = new RemoteQuizPlayer()


sock.on 'echo', (data, fn) -> fn 'alive'
sock.on 'disconnect', ->
	sync.attempt = null if sync.attempt?.user isnt public_id # get rid of any buzzes
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
sock.on 'application_update', -> applicationCache.update() if applicationCache?
sock.on 'application_force_update', -> $('#update').slideDown()
sock.on 'redirect', (url) -> window.location = url
sock.on 'alert', (text) -> window.alert text
sock.on 'chat', (data) -> chatAnnotation data
sock.on 'log', (data) -> verbAnnotation data
sock.on 'sync', (data) -> synchronize data

sock.on 'joined', (data) ->
	public_name = data.name
	public_id = data.id
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

	thresh = avg sync_offsets
	below = (item for item in sync_offsets when item <= thresh)
	sync_offset = avg(below)
	# console.log 'frst iter', below
	thresh = avg below
	below = (item for item in sync_offsets when item <= thresh)
	sync_offset = avg(below)

	# console.log 'sec iter', below
	$('#sync_offset').text(sync_offset.toFixed(1) + '/' + stdev(below).toFixed(1) + '/' + stdev(sync_offsets).toFixed(1))

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
				$('#latency').text(avg(latency_log).toFixed(1) + "/" + stdev(latency_log).toFixed(1) + " (#{latency_log.length})")


setTimeout ->
	testLatency()
	setInterval -> 
		testLatency()
	, 30 * 1000
, 2000