#= require ./lib/html5slider.js
#= require ./lib/sha1.js
#= require ./lib/chatbot.js

#= require ../shared/names.coffee
#= require ../shared/removeDiacritics.js
#= require ../shared/levenshtein.js
#= require ../shared/porter.js
#= require ../shared/syllable.js
#= require ../shared/checker.coffee
#= require ../shared/sample.coffee


offline_questions = []
count_cache = null

load_questions = (cb) ->
	if offline_questions.length is 0
		$.ajax('/sample.txt').done (text) ->
			offline_questions = (jQuery.parseJSON(line) for line in text.split('\n'))
			for question in offline_questions
				question._inc = Math.random()
				question.type = 'qb'
			
			recursive_counts ['type', 'difficulty', 'category'], {}, (layers) ->
				count_cache = layers
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
	# TODO: be smarter about the sampling, permute difficulty and categories to find respective likelihoods
	if count_cache[type]
		if !difficulty
			difficulty = count_cache[type].sampler.next()
		if !category
			category = count_cache[type].difficulty[difficulty].sampler.next()
		if typeof category == 'object'
			sampler = new AliasMethod(category)
			category = sampler.next()
		
		question = offline_questions.sort((a, b) -> a._inc - b._inc)[0]
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