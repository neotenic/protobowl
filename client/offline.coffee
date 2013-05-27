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
#= include ../shared/checker2.coffee
#= include ../shared/sample.coffee

Questions = new IDBStore {
	dbVersion: 19,
	storeName: 'questions',
	keyPath: 'qid',
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
		{ name: 'bookmarked', keyPath: 'bookmarked', unique: false },
		{ name: 'add_time', keyPath: 'add_time', unique: false },
		{ name: 'type_difficulty_category_inc', keyPath: ['type', 'difficulty', 'category', 'inc_random']},
		{ name: 'type_difficulty_category', keyPath: ['type', 'difficulty', 'category']},
		{ name: 'type_difficulty', keyPath: ['type', 'difficulty'] }
	],
	onStoreReady: ->
		Questions.ready = true
		# console.log 'store is ready for bidnezz'
		dispose_retrieval_queue()
		
		import_legacy_bookmarks()

		update_storage_stats ->
			$("#whale").fadeIn()
			$("#whale input").keyup()

			setTimeout check_import_external, 1000
}



fisher_yates = (i) ->
	return [] if i is 0
	arr = [0...i]
	while --i
		j = Math.floor(Math.random() * (i+1))
		[arr[i], arr[j]] = [arr[j], arr[i]] 
	arr


check_import_external = ->
	Questions.count (unread) ->
		console.log 'counted unread questions', unread
		if unread < 500
			import_external()
			
	, { keyRange: Questions.makeKeyRange({upper: 0}), index: 'seen' }

import_external = ->
	unless localStorage.sample_urls
		expanded = []
		for sample in protobowl_config.samples
			shorthand_regex = /\{(\d+)\-(\d+)\}/
			shorthand = sample.match(shorthand_regex)
			if shorthand
				for i in [+shorthand[1]..+shorthand[2]]
					expanded.push sample.replace(shorthand_regex, i)
			else
				expanded.push sample

		localStorage.sample_urls = JSON.stringify(expanded[i] for i in fisher_yates(expanded.length))
	
	# each question packet has 1000
	samples = JSON.parse(localStorage.sample_urls)
	url = samples.shift()
	localStorage.sample_urls = JSON.stringify(samples)
	if url
		load_sample url


import_question = (question) ->
	Questions.get question.qid, (e) ->
		return unless typeof e is 'undefined'
		# console.log 'saving question', question.qid
		Questions.put question, (f) ->
			# console.log 'saved question', f
			return
		, handle_db_error
	, handle_db_error


load_sample = (url, cb = ->) ->
	$.ajax {
		url: url,
		cache: true,
		dataType: 'script',
		success: ->
			console.log 'importing samples from url', url
			import_batch()
	}

import_batch = ->
	for i in [0..10]
		for key, val of QUESTION_DB
			question = val.shift()
			continue unless question
			import_question {
				qid: question._id.$oid,
				answer: question.answer,
				category: question.category,
				difficulty: question.difficulty,
				inc_random: Math.random(),
				seen: 0,
				bookmarked: ((Date.now() - 1000000000000) / 1e17),
				num: question.num,
				question: question.question,
				round: question.round,
				tournament: question.tournament,
				type: question.type,
				year: question.year
			}
			break
	setTimeout import_batch, 1000



$(window).resize ->
	$("#bookmarks").css('min-height', $(window).height() - 70)

update_question_cache = (question)->
	if typeof question is 'undefined'
		question = {
			qid: room.qid,
			question: room.question, 
			answer: room.answer,
			category: room.info.category, 
			round: room.info.round,
			tournament: room.info.tournament, 
			year: room.info.year, 
			seen: 1,
			difficulty: room.info.difficulty,
			inc_random: 1 + Math.random(),
			add_time: Date.now(),
			bookmarked: ((Date.now() - 1000000000000) / 1e17)
		}
		Questions.put question, (f) ->
			# console.log 'saved question', f
			return
		, handle_db_error
	else
		question.seen++
		question.inc_random += (1 + Math.random())
		
		question.question = room.question
		question.category = room.info.category
		question.round = room.info.round
		question.difficulty = room.info.difficulty

		Questions.put question, (f) ->
			# console.log 'updated question', f
			return
		, handle_db_error


handle_db_error = (e) ->
	console.error e

save_question = (question) ->
	# Questions.get question.qid, (e) ->
	# 	return unless typeof e is 'undefined'
	# 	console.log 'saving question'
	Questions.put question, (f) ->
		# console.log 'saved question', f
		return
	, handle_db_error
	# , handle_db_error


# this piece of code will be deprecated the moment it's released
# and therefore could be removed shortly afterwards
import_legacy_bookmarks = ->
	bookmarks = []
	try
		bookmarks = JSON.parse(localStorage.bookmarks)
	for question in bookmarks || []
		question.bookmarked = 1 + ((Date.now() - 1000000000000) / 1e17)
		save_question question
	delete localStorage.bookmarks


# bookmarks_loaded = false
# load_bookmarked_questions = ->
# 	return if bookmarks_loaded
# 	bookmarks_loaded = true

	bookmarks = []
	try
		bookmarks = JSON.parse(localStorage.bookmarks)
	for question in bookmarks || []
		continue if question.qid is room.qid
		bundle = create_bundle(question)
		bundle.find('.readout').hide()
		$('#bookmarks').prepend bundle

# 	cutoff = 10

# 	$('#bookmarks .bundle').slice(cutoff).hide()

# 	update_visibility()
	

$("#whale input").keydown (e) ->
	if e.keyCode is 27
		$("#whale input").val('')

$("#whale input").keyup (e) ->
	return unless Questions.ready
	query = new RegExp($("#whale input").val().split(/\ ?\,\ ?/).map(RegExp.quote).join('.*'), 'i')
	MAX_RESULTS = 10
	match_count = 0
	query_string = $("#whale input").val()
	
	$("#bookmarks .booktop").remove()

	last_cursor = $("<span>").addClass('booktop').prependTo("#bookmarks")
	finish_query = ->
		last_cursor.nextAll('.bundle').slideUp()
		last_cursor.nextAll('.bundle').find('.readout').slideUp()

		# do some cleanup so that the number of crap things is never too much
		if $("#bookmarks .bundle:hidden").length > 2 * MAX_RESULTS
			$("#bookmarks .bundle:hidden").slice(-MAX_RESULTS).remove()

		setTimeout ->
			if $("#bookmarks .bundle:visible").length < 5
				$("#bookmarks .bundle:visible:not(:first) .readout").slideUp()
				$("#bookmarks .bundle:visible:first .readout").slideDown()
		, 1000


	Questions.iterate (item, cursor, tranny) ->
		return unless item
		if $("#whale input").val() isnt query_string
			tranny.abort()
			finish_query()
		else if match_count >= MAX_RESULTS
			tranny.abort()
			finish_query()
		else
			# console.log item
			is_match = JSON.stringify(item).match(query) and room.qid isnt item.qid and room.answer isnt item.answer
			if is_match
				match_count++
			if $("#bookmarks .qid-#{item.qid}").length
				if is_match
					last_cursor = $("#bookmarks .qid-#{item.qid}").insertAfter(last_cursor).slideDown()
				else
					$("#bookmarks .qid-#{item.qid} .readout").slideUp()
					$("#bookmarks .qid-#{item.qid}").slideUp()

			else
				if is_match
					bundle = create_bundle(item)
					bundle.find('.readout').hide()
					last_cursor = bundle.hide().insertAfter(last_cursor).slideDown()
					update_visibility()

	, {
		index: 'bookmarked',
		order: 'DESC',
		onEnd: ->
			finish_query()
		onError: (err) ->

	}


update_storage_stats = (cb) ->
	return unless Questions.ready

	Questions.count (total_count) ->
		Questions.count (bookmark_count) ->
			$('#whale .status').text "#{bookmark_count} bookmarks"
			$('#whale .status').attr 'title', "#{total_count} searchable questions"
			cb?()

		, { keyRange: Questions.makeKeyRange({lower: 1}), index: 'bookmarked' }
	

dispose_retrieval_queue = ->
	return unless Questions.ready
	tranny = retrieval_queue.shift()
	# console.log 'tranny', tranny
	return unless tranny
	[qid, cb] = tranny
	Questions.get qid, cb, handle_db_error
	if retrieval_queue.length
		dispose_retrieval_queue()

# setTimeout load_bookmarked_questions, 100

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
	blacklist = ['lobby', 'msquizbowl', 'hsquizbowl', 'temporary', 'offline.html']
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


# load_questions = (cb) ->
# 	if offline_questions.length is 0
# 		load_sample 0, ->
# 			setTimeout cb, 100

# 	else
# 		setTimeout cb, 100



count_questions = ->
	layers = {}
	Questions.query (items) ->
		for [type, difficulty, category] in items
			layers[type] = {} unless layers[type]
			layers[type][difficulty] = {} unless layers[type][difficulty]
			layers[type][difficulty][category] = {} unless layers[type][difficulty][category]
	, {
		index: 'type_difficulty_category',
		filterDuplicates: true
	}

loading_questions = false
load_questions = (cb) ->
	if count_cache
		setTimeout cb, 100
	else if loading_questions
		setTimeout ->
			load_questions cb
		, 100
	else
		loading_questions = true
		# fraud a wait until the db is ready
		find_question 'morptasm', ->
			console.log "SDFJSDFJSODFIOSDJFOIJF"
			recursive_counts ['type', 'difficulty', 'category'], {}, (layers) ->
				count_cache = layers
				cb()


recursive_counts = (attributes, criterion, cb) ->
	# criterion_filter = (criterion) ->
	# 	matches = []
	# 	for question in offline_questions
	# 		failures = 0
	# 		for attr, val of criterion
	# 			failures++ if question[attr] isnt val
	# 		if failures is 0
	# 			matches.push question
	# 	return matches

	criterion_count = (criterion, callback) ->
		level = Object.keys(criterion).length
		if level is 0
			Questions.count (count) ->
				callback null, count
		else if level is 1
			Questions.count (count) ->
				callback null, count
			, {
				index: 'type',
				keyRange: Questions.makeKeyRange { lower: criterion.type, upper: criterion.type }
			}
		else
			# console.log [criterion.type, criterion.difficulty, criterion.category]
			# callback null, criterion_filter(criterion).length
			Questions.count (count) ->
				callback null, count
			, {
				index:  ['type', 'difficulty', 'category'].slice(0, level).join('_'),
				keyRange: Questions.makeKeyRange {
					lower: [criterion.type, criterion.difficulty, criterion.category].slice(0, level)
					upper: [criterion.type, criterion.difficulty, criterion.category].slice(0, level)
				}
			}
		# Questions.count(function(e){console.log(e)}, {index: 'tdc', keyRange: Questions.makeKeyRange({lower: ['qb','HS','Science'], upper: ['qb','HS','Science']})})

	criterion_distinct = (attribute, criterion, callback) ->
		level = Object.keys(criterion).length

		console.log 'distinct', attribute, criterion, level
		if level is 0
			Questions.query (items) ->
				callback null, (item[attribute] for item in items)
			, {
				index: 'type'
				filterDuplicates: true
			}
		else
			Questions.query (items) ->
				# console.log 'got distinct', items, (item[attribute] for item in items)
				callback null, (item[attribute] for item in items)
			, {
				index: ['type', 'difficulty', 'category'].slice(0, level + 1).join('_'),
				filterDuplicates: true,
				keyRange: Questions.makeKeyRange {
					lower: [criterion.type, criterion.difficulty, criterion.category].slice(0, level)
				}
			}
		# attr_map = {}
		# for question in criterion_filter(criterion)
		# 	attr_map[question[attribute]] = 1
		# callback null, (x for x of attr_map)

	attribute = attributes.shift()
	inner_attribute = attributes[0]
	criterion_distinct attribute, criterion, (err, list) ->
		throw err if err
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
					throw err if err
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
	console.log 'trying to get question'
	if count_cache == null
		setTimeout ->
			get_question type, difficulty, category, cb
		, 100
		return

	console.log 'loaded count cache'

	# unless typeof offline_questions[0] is 'object'
	# 	setTimeout ->
	# 		cb null, [], []
	# 	, 10
	# 	return



	# TODO: be smarter about the sampling, permute difficulty and categories to find respective likelihoods
	if count_cache[type]
		if !difficulty
			difficulty = count_cache[type].sampler.next()
		if !category
			category = count_cache[type].difficulty[difficulty].sampler.next()
		if typeof category == 'object'
			sampler = new AliasMethod(category)
			category = sampler.next()
		
		console.log 'qyering for', difficulty, category, type
		Questions.iterate (item, cursor, tranny) ->
			console.log 'got item woo', item
			# return unless item
			item.seen++
			item.inc_random += Math.random() + 1
			Questions.put item

			tranny.abort()
			cb item, get_difficulties(type), get_categories(type)
		, {
			index: 'type_difficulty_category_inc',
			order: 'ASC',
			keyRange: Questions.makeKeyRange {
				lower: [type, difficulty, category, 0]
			}
			onEnd: ->
				cb null, get_difficulties(type), get_categories(type)
			onError: (err) ->
		}

		# question_bank = offline_questions.sort((a, b) -> a._inc - b._inc)
		# question = null
		# for candidate in question_bank
		# 	if candidate.difficulty is difficulty and candidate.category is category and candidate.type is type
		# 		question = candidate
		# 		break
		# if question
		# 	question._inc += Math.random() + 1
		# setTimeout ->
		# 	cb question, get_difficulties(type), get_categories(type)
		# , 10
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
	console.log 'got parameters and stuff', get_difficulties(type), get_categories(type, difficulty)