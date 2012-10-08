#= require modernizr.js
#= require bootstrap.js
#= require fireworks.coffee
#= require annotations.coffee
#= require buttons.coffee
#= require offline.coffee
#= require time.coffee

sync = {}
public_id = 'uninitialized'
public_name = 'adjective animal'

time = -> if sync.time_freeze then sync.time_freeze else serverTime() - sync.time_offset
connected = -> inner_socket? and inner_socket.socket.connected
serverTime = -> new Date - sync_offset
avg = (list) -> sum(list) / list.length
sum = (list) -> s = 0; s += item for item in list; s
stdev = (list) -> mu = avg(list); Math.sqrt avg((item - mu) * (item - mu) for item in list)

sock = io.connect()

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
	sock.emit 'init_offline', 'yay' #obviously server wont pay attention to that
	# renderState()

# look at all these one liner events!
sock.on 'application_update', -> applicationCache.update() if applicationCache?
sock.on 'application_force_update', -> $('#update').slideDown()
sock.on 'redirect', (url) -> window.location = url
sock.on 'alert', (text) -> window.alert text
sock.on 'sync', (data) -> synchronize data
sock.on 'chat', (data) -> chatAnnotation data
sock.on 'log', (data) -> verbAnnotation data


sock.on 'joined', (data) ->
	public_name = data.name
	public_id = data.id
	$('#username').val public_name
	$('#username').disable false

synchronize = ->
	# ka-blamo