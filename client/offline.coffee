#= require ./lib/html5slider.js
#= require ./lib/sha1.js
#= require ./lib/chatbot.js
#= require ./lib/unidecode.coffee
#= require ./lib/profanity.coffee
#= require ./lib/idbstore.js

#= require ../shared/names.coffee
#= require ../shared/removeDiacritics.js
#= require ../shared/levenshtein.js
#= require ../shared/porter.js
#= require ../shared/syllable.js
#= require ../shared/checker.coffee
#= require ../shared/sample.coffee


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

load_questions = (cb) ->
	if offline_questions.length is 0
		$.ajax('/sample.txt').done (text) ->
			try
				offline_questions = (jQuery.parseJSON(line) for line in text.split('\n') when line)
				for question in offline_questions
					question._inc = Math.random()
					question.type = 'qb'
					
				recursive_counts ['type', 'difficulty', 'category'], {}, (layers) ->
					count_cache = layers
					setTimeout cb, 100		
			catch err
				console.log 'error loading questions', err
				count_cache = {}
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