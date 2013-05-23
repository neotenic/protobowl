#= include ./lib/html5slider.js
#= include ./lib/sha1.js
#= include ./lib/chatbot.js
#= include ./lib/unidecode.js
#= include ./lib/profanity.coffee
#= include ./lib/idbstore.js

#= include ../shared/names.coffee
#= include ../shared/removeDiacritics.js
#= include ../shared/levenshtein.js
#= include ../shared/porter.js
#= include ../shared/syllable.coffee
#= include ../shared/checker.coffee
#= include ../shared/sample.coffee

Questions = new IDBStore {
	dbVersion: 3,
	storeName: 'questions',
	keyPath: 'id',
	autoIncrement: false,
	indexes: [
		{ name: 'tags', keyPath: 'tags', unique: false, multiEntry: true },
		{ name: 'type', keyPath: 'type', unique: false },
		{ name: 'category', keyPath: 'category', unique: false },
		{ name: 'difficulty', keyPath: 'difficulty', unique: false },
		{ name: 'seen', keyPath: 'seen', unique: false },
		{ name: 'inc_random', keyPath: 'inc_random', unique: false },
		{ name: 'year', keyPath: 'year', unique: false },
		{ name: 'tournament', keyPath: 'tournament', unique: false },
		{ name: 'answer', keyPath: 'answer', unique: false },
		{ name: 'bookmarked', keyPath: 'bookmarked', unique: false }
	],
	onStoreReady: ->
		console.log 'store is ready for bidnezz'
}

handle_db_error = (e) ->
	console.error e

save_question = (question) ->
	Questions.get question.id, (e) ->
		return unless typeof e is 'undefined'
		console.log 'saving question'
		Questions.put question, (f) ->
			console.log 'saved question', f
		, handle_db_error
	, handle_db_error

# save_question({id: room.qid, question: room.question, category: room.info.category, tournament: room.info.tournament, year: room.info.year, difficulty: room.info.difficulty})

cache_frame = null
cache_listeners = []

cache_status = (status) ->
	if status isnt 'Error'
		$("#cachestatus").text status
	
	if status in ['Updated', 'Error']
		for cb in cache_listeners
			try
				cb(status == 'Error') 
		cache_listeners = []

	if status is 'Updated'
		render('update').insertAfter('.buttonbar').hide().slideDown()

		if protobowl_config?.development
			location.reload()


cache_update = (cb) ->
	cache_listeners.push cb if cb
	if cache_frame
		cache_frame.postMessage 'CacheUpdate', '*'
	else
		console.error 'no cache window'

initialize_cache = ->
	window.addEventListener "message", (evt) ->
		if typeof evt.data is 'string' and evt.data.slice(0, 12) == "CacheStatus:"
			cache_status evt.data.slice(12)
	
	frame = document.createElement('iframe')
	$(frame)
		.hide()
		.attr('src', (protobowl_config?.origin || '/') + 'cacher.html')
		.appendTo('body')

	cache_frame = frame.contentWindow

initialize_cache() if applicationCache?

updater_socket = null

connect_updater = ->
	updater_socket = new WebSocket("ws://localhost:#{protobowl_config.dev_port || 5577}")

	updater_socket.onopen = ->
		# $('.show-updater').fadeIn()
		$('.show-updater').disable(false)
		console.log "updater websocket connection is open"
	
	updater_socket.onmessage = (e) ->
		console.log 'got signal for new update', e.data

		cache_update (error) ->
			if error
				createAlert("Update Failure!", "Some part of the application update process has failed. This might happen if the static file server is not running. ")
					.addClass('alert-error')
					.insertAfter('.buttonbar')
			
	updater_socket.onclose = ->
		# console.log 'updater socket was closed'
		$('.show-updater').disable()
		setTimeout connect_updater, 1000



if (protobowl_config?.development and protobowl_config?.dev_port || location.hostname == "localhost") and window.WebSocket
	connect_updater()


recent_rooms = ->
	rooms = []
	for i in [0...localStorage.length]
		try
			key = localStorage.key(i)
			if key.slice(0, 5) == "room-"
				rooms.push JSON.parse(localStorage[key])
	rooms = rooms.sort (b, a) -> a.archive_time - b.archive_time
	blacklist = ['lobby', 'msquizbowl', 'hsquizbowl', 'temporary']
	rooms = (room.name for room in rooms when room.name not in blacklist and !/^private/.test(room.name))
	if rooms.length > 0
		$('.recent-rooms').append $("<li>").addClass('divider')
		for i in [0...rooms.length]
			name = rooms[i]
			if i < 3
				$('.recent-rooms').append $('<li>').append($('<a>').text(name.replace(/-/g, ' ')).attr('href', '/' + name))
			else
				delete localStorage['room-' + name]



setTimeout recent_rooms, 500

# this is kind of a hack for the new static architecture
# which doesn't exactly support generating page names
# for somewhat obvious reasons
if location.pathname is '/new'
	location.href = generatePage()


fallback_notice = ->
	line = $('<div>').addClass 'alert alert-success'
	line.append $('<p>').append("You are connected to the <span class='label label-success'>semi-decentralized fallback</span> protocol. ")
	line.append $('<p>').append("Users will be theoretically able to access a subset of questions and interact with other users in spite of being disconnected from the central server. However, as the primary server is likely offline, users who have never been to Protobowl probably can not join.")
	addImportant $('<div>').addClass('log disconnect-notice').append(line)


fallback_connection = ->
	return PUBNUB? and PUBNUB.is_connected and navigator.onLine

fallback_emit = (name, data, callback) ->
	throw 'conection broken' if !fallback_connection()
	PUBNUB.publish {
		channel: room.name,
		message: { action: 'event', event: name, data, uid: me.id, target: room.__target }
	}

initialize_fallback = ->
	return false
	initializePubNub() if navigator.onLine

fallback_broadcast = (name, data) ->
	json = JSON.stringify(data)
	chunksize = 500
	session = Math.random().toString(36).substr(3)
	chunks = Math.ceil(json.length / chunksize)
	for i in [0...chunks]
		PUBNUB.publish {
			channel: room.name,
			message: { 
				action: 'broadcast', 
				event: name,
				session, 
				chunk: i,
				num: chunks,
				data: json.substr(i * chunksize, chunksize)
			}
		}

assembly_buffer = {}

fallback_message = (message) ->
	if message.action is 'init'
		PUBNUB.publish {
			channel: room.name,
			message: { action: 'config', target: room.__target || me.id }
		}
	else if message.action is 'config'
		room.__target = message.target
	else if message.action is 'event' and message.target is me.id
		room.users[me.id][message.event](message.data)
	else if message.action is 'broadcast'
		assembly_buffer[message.session] ||= {}
		buf = assembly_buffer[message.session]
		buf[message.chunk] = message.data
		has_count = (1 for i of buf).length
		if has_count is message.num
			parts = (buf[i] for i in [0...message.num]).join('')
			room.__listeners[message.event](JSON.parse(parts))

initializePubNub = ->
	return if PUBNUB?
	$("<div>", {
		id: "pubnub",
		origin: "pubsub.pubnub.com",
		ssl: 'off',
		'sub-key': "sub-eea09594-4223-11e2-8b92-c913f60b8598",
		'pub-key': "pub-5c3fbace-08c5-4ea5-b038-18391d9d3e3c"
	}).hide().appendTo('body')

	$.ajax {
		url: 'http://cdn.pubnub.com/pubnub-3.3.min.js',
		cache: true,
		dataType: 'script',
		success: ->
			console.log 'loaded pubnub'
			PUBNUB.ready()
			PUBNUB.subscribe {
				channel: room.name,
				restore: false,
				connect: ->
					console.log 'connected to pubnub'
					PUBNUB.is_connected = true
					PUBNUB.publish {
						channel: room.name,
						message: { action: 'init' }
					}
					fallback_notice()
				disconnect: ->
					console.log 'disconnected from pubnub'
					PUBNUB.is_connected = false
				reconnect: ->
					console.log 'reconnected to pubnub'
					PUBNUB.is_connected = true
				
				presence: (details) ->
					console.log details
				callback: (message) ->
					fallback_message message
				error: (e) ->
					console.log e
			}
	}

offline_questions = []
count_cache = null


load_sample = (index, cb = ->) ->
	$.ajax {
		url: protobowl_config.samples[index],
		cache: true,
		dataType: 'script',
		success: ->
			for question in QUESTION_DB[index]
				question._inc = Math.random()
				question.type = 'qb'
				offline_questions.push question
			recursive_counts ['type', 'difficulty', 'category'], {}, (layers) ->
				count_cache = layers
				cb()

	}


load_questions = (cb) ->
	if offline_questions.length is 0
		load_sample 0, ->
			setTimeout cb, 100

	else
		setTimeout cb, 100


recursive_counts = (attributes, criterion, cb) ->
	criterion_filter = (criterion) ->
		matches = []
		for question in offline_questions
			failures = 0
			for attr, val of criterion
				failures++ if question[attr] isnt val
			if failures is 0
				matches.push question
		return matches

	criterion_count = (criterion, callback) ->
		callback null, criterion_filter(criterion).length

	criterion_distinct = (attribute, criterion, callback) ->
		attr_map = {}
		for question in criterion_filter(criterion)
			attr_map[question[attribute]] = 1
		callback null, (x for x of attr_map)

	attribute = attributes.shift()
	inner_attribute = attributes[0]
	criterion_distinct attribute, criterion, (err, list) ->
		# console.log attribute, list
		layer = {}
		next_slice = ->
			if list.length is 0
				cb layer
			else
				item = list.shift()
				# console.log 'counting', attribute, item
				criterion[attribute] = item
				criterion_count criterion, (err, count) ->
					layer[item] = {count}
					if attributes.length > 0
						recursive_counts attributes.slice(0), clone_shallow(criterion), (inner) ->
							layer[item][inner_attribute] = inner
						
							distribution = {}
							distribution[id] = val.count for id, val of inner
							layer[item].sampler = new AliasMethod(distribution)
							next_slice()
					else
						next_slice()
		next_slice()

count_questions = (type, difficulty, category, cb) ->
	all_cats = get_categories(type)
	all_diffs = get_difficulties(type)
	count_sum = 0
	search_cats = [category]
	if typeof category is "object"
		search_cats = (cat for cat, count of category when count > 0)
	# console.log 'cats', search_cats
	for cat in all_cats
		for diff in all_diffs
			continue if difficulty and diff != difficulty
			continue if category and cat not in search_cats
			
			safe_count = count_cache[type]?.difficulty[diff]?.category[cat]?.count
			# console.log 'count of ',diff, cat, safe_count
			count_sum += (safe_count || 0)

	cb(count_sum)

get_question = (type, difficulty, category, cb) ->
	if count_cache == null
		setTimeout ->
			get_question type, difficulty, category, cb
		, 100
		return
	unless typeof offline_questions[0] is 'object'
		setTimeout ->
			cb null, [], []
		, 10
		return 
	# TODO: be smarter about the sampling, permute difficulty and categories to find respective likelihoods
	if count_cache[type]
		if !difficulty
			difficulty = count_cache[type].sampler.next()
		if !category
			category = count_cache[type].difficulty[difficulty].sampler.next()
		if typeof category == 'object'
			sampler = new AliasMethod(category)
			category = sampler.next()
		
		question_bank = offline_questions.sort((a, b) -> a._inc - b._inc)
		question = null
		for candidate in question_bank
			if candidate.difficulty is difficulty and candidate.category is category and candidate.type is type
				question = candidate
				break
		if question
			question._inc += Math.random() + 1
			
		setTimeout ->
			cb question, get_difficulties(type), get_categories(type)
		, 10
	else
		setTimeout ->
			cb null, get_difficulties(type), get_categories(type)
		, 10

get_difficulties = (type) -> (d for d of count_cache[type]?.difficulty)

get_categories = (type, difficulty) ->
	cat_map = {}
	for d, {category} of count_cache[type]?.difficulty when !difficulty or difficulty is d
		# console.log d, a.category
		for c of category
			cat_map[c] = 1
	return (c for c of cat_map)

get_parameters = (type, difficulty, cb) ->
	if count_cache == null
		setTimeout ->
			get_parameters type, difficulty, cb
		, 100
		return
	cb get_difficulties(type), get_categories(type, difficulty)