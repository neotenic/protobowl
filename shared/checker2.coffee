tokenize_line = (answer) ->
	tokens = answer
		.replace(/([\{\}\[\]\;\-\:\,\&\(\)\/])/g, " $1 ") # wrap all the special delimiting symbols		
		.replace(/'|"/g, '') # the apostrophes and quotes are useless
		.replace(/\./g, ' ') # remove periods because they're kind of useless
		.replace(/\ +/g, ' ') # condense multiple spaces
		.trim() # removing leading and trailing spaces
		.split(' ') # split things up
	bold = false
	processed = []
	for token in tokens # loop to annotate each token with boldness state
		# console.log token
		if token is '{'
			bold = true
		else if token is '}'
			bold = false
		else if token not in ['-', ':', '=', '&', '%', '/']
			processed.push [bold, token]
	
	# console.log processed

	buffer = []
	completed = []
	for [bold, token] in processed # loop to split different statements
		if token.toLowerCase().trim() in ['[', 'or', ';', ']', '(', ')', ',', 'and', 'but']
			completed.push buffer if buffer.length
			buffer = []
		else
			buffer.push [bold, token]
	completed.push buffer if buffer.length # add the remainder
	
	# console.log completed

	# parse statements in reverse order for situations like accept either
	for group in completed.reverse()
		prefix_words = ["do","not","accept","or","prompt", "on", "just", "don't", "either"]
		# ,"on", "either", "underlined", "portion", "equivalents", "equivalent", "word", "forms", "like", "any", "other", "in", "order"
		suffix_words = ["is", "read", "stated", "mentioned", "at", "any", "time"]
		splitters = ["before", "after", "during", "while", "until", "but"]
		prefix = []
		for [bold, token] in group # find all the words which belong as a prefix
			if token in prefix_words # maybe in the future, ignore bolded words
				prefix.push token
			else
				break
		# find the suffix
		suffix = []
		for i in [group.length...0]
			[bold, token] = group[i - 1]
			if prefix.length > 0 and token in suffix_words
				suffix.push token
			else
				break
		suffix.reverse()

		front = [] 
		back = []
		preposition = null
		for [bold, token] in group # split the acceptable responses by a preposition
			if preposition
				back.push [bold, token]
			else if token in splitters and bold is false
				preposition = token
			else if token in prefix or token in suffix
				0 #noop
			else
				front.push [bold, token]

		# console.log [prefix, front, preposition, back, suffix]
		[prefix, front, preposition, back, suffix]

equivalence_map = do ->
	list = [
		['zero', 'zeroeth', 'zeroth', '0'],
		['one', 'first', 'i', '1', '1st'],
		['two', 'second', 'ii', '2', '2nd'],
		['three', 'third', 'iii', 'turd', '3', '3rd'],
		['four', 'forth', 'fourth', 'iv', '4', '4th'],
		['fifth', 'five', '5', '5th', 'v', 'versus', 'vs', 'against'],
		['sixth', 'six', 'vi', 'emacs', '6', '6th'],
		['seventh', 'seven', 'vii', '7', '7th'],
		['eight', 'eighth', '8', 'viii', 'iix', '8th'],
		['nine', 'nein', 'ninth', 'ix', '9', '9th'],
		['ten', 'tenth', '10', '10th', 'x', 'by', 'times', 'product', 'multiplied', 'multiply'],
		['eleventh', 'eleven', 'xi', '11th'],
		['twelfth', 'twelveth', 'twelve', '12', 'xii', '12th'],
		['thirteenth', 'thirteen', '13', 'xiii', '13th'],
		['fourteenth', 'fourteen', 'ixv', '14th'],
		['fifteenth', 'fifteen', '15', 'xv', '15th'],
		['sixteenth', 'sixteen', '16', 'xvi', '16th'],
		['seventeenth', 'seventeen', '17', 'xvii', '17th'],
		['twenty', 'xx', '20', '20th'],
		['thirty', 'xxx', '30', '30th'],
		['hundred', 'c', '100', '100th'],
		['dr', 'doctor', 'drive'],
		['mr', 'mister']
		['ms', 'miss', 'mrs']
		['st', 'saint', 'street']
		['rd', 'road']
		['albert', 'al']
		['robert', 'bob', 'rob'],
		['william', 'will', 'bill'],
		['richard', 'rich', 'dick'],
		['gregory', 'greg'],
		['christopher', 'chris'],
		['benjamin', 'ben'],
		['nicholas', 'nick'],
		['anthony', 'tony'],
		['lawrence', 'larry'],
		['edward', 'edvard', 'edouard', 'ed']
		['kim', 'kimball']
		['vladimir', 'vlad']
		['log', 'logarithm']
		['constant', 'number']
	]
	map = {}
	for group in list
		for item in group
			console.warn("ITEM ALREADY EXISTS", item) if item of map
			map[item] = group
	return map
	

stemmer_cleanup = (text) ->
	if PorterStemmer?
		stemmer = PorterStemmer
	else
		stemmer = require('./porter').stemmer

	return stemmer(text).replace(/ph/ig, 'f')



fuzzy_search = (needle, haystack) ->
	if removeDiacritics?
		remove_diacritics = removeDiacritics 
	else
		remove_diacritics = require('./removeDiacritics').removeDiacritics

	if levenshtein?
		damlev = levenshtein
	else
		damlev = require('./levenshtein').levenshtein 

	haystack = remove_diacritics(haystack)
		.replace(/([A-Z])\.\s?([A-Z])/g, '$1$2') # this helps the acronym detector
		.replace(/([A-Za-z])\.?\s/g, '$1 ') # this helps the acronym detector
	needle = remove_diacritics(needle.toLowerCase())
	
	# console.log needle, haystack

	# console.log haystack
	if 2 <= haystack.length <= 4 # this is for acronyms
		haystack = haystack.toUpperCase()

	plainstack = haystack.toLowerCase().replace(/[^a-z]/g, '')
	plainneedle = needle.replace(/[^a-z]/g, '')
	
	return true if plainneedle.length >= 3 and plainstack.indexOf(plainneedle) != -1

	stem = stemmer_cleanup(needle)
	
	ERROR_RATIO = 0.25 # magic number i pulled out of my ass
	
	composite_acronym = ''
	for word in haystack.split(/\s|\-/)
		# combine all the capitalesque letters
		if /^[A-Z]+$/.test(word) and 1 <= word.length <= 4
			composite_acronym += word

	if 2 <= composite_acronym.length <= 4
		if composite_acronym.toLowerCase().indexOf(needle[0]) isnt -1
			return true

	for word in haystack.split(/\s|\-/)
		word = word.toLowerCase()

		return true if needle is word

		plain = damlev(word, needle)
		plaid = plain / Math.min(word.length, needle.length)
		
		# console.log plaid, word, needle

		return true if plaid <= ERROR_RATIO
		
		xylem = stemmer_cleanup(word)

		diff = damlev(xylem, stem)
		frac = diff / Math.min(xylem.length, stem.length)
		# console.log frac, word, needle
		
		return true if frac <= ERROR_RATIO

		if needle.length > 6 and word.indexOf(needle.slice(0, 4)) is 0
			# this is for incomplete statements and the ilk
			return true

		if needle.length is 1 and word.indexOf(needle) is 0
			# this is for combining words
			return true
	
	if needle of equivalence_map
		for word in equivalence_map[needle]
			if " #{haystack.toLowerCase()} ".indexOf(" #{word} ") isnt -1
				return true


	return false


check_answer = (tokens, text, question = '') ->
	# these are words which are deemed to be trivial and thus not counted as unbold (though may still be counted as bold)

	stopwords = "a and any as at battle by can de do for from have her him his in is it l la le my o of on or she so that the this to was y".split(' ')

	judgements = []
	index = 0
	mode_either = false
	cat_tokens = []

	all_tokens = []
	for [prefix, front, preposition, back, suffix] in tokens
		for [bold, token] in front
			all_tokens.push token

	question_match = []
	question = question.toLowerCase()
	lower_cat_tokens = (word.toLowerCase() for word in cat_tokens)

	for word in text.split(/\s/)
		word = word.toLowerCase()
		continue if !word or word.length <= 2 or word in stopwords or word in lower_cat_tokens
		if question.indexOf(word) != -1
			question_match.push word

	for [prefix, front, preposition, back, suffix] in tokens
		index++
		bold_match = []
		unbold_match = []
		bold_miss = []
		unbold_miss = []
		bolded = []
		unbold = []

		# evaluate errything
		for [bold, token] in front
			match = fuzzy_search(token, text)
			trivial = token.toLowerCase() in stopwords
			bold_match.push token if match and bold
			unbold_match.push token if match and !bold and !trivial
			unbold_miss.push token if !match and !bold and !trivial
			bold_miss.push token if !match and bold
			bolded.push token if bold
			unbold.push token if !bold and !trivial
			cat_tokens.push token if match
		
		matchiness = bold_match.length + unbold_match.length #+ (0.002 / (index + 20))

		level = 0 # 0 = reject, 1 = prompt, 2 = accept		
		
		if bold_match.length > 0
			if mode_either
				level = 2
			else if bold_miss.length > 0
				level = 1
			else
				level = 2
		else
			if bolded.length is 0 and unbold_match.length > 0
				level = 2
			else if unbold_match.length > unbold.length / 2 # more than half of the unbolds
				level = 1
			else
				level = 0
				
		# console.log prefix, front, preposition, back, suffix
		# console.log bolded, unbold
		# console.log bold_match, unbold_match, bold_miss, text, level, matchiness
		
		mode_either = false

		if 'either' in prefix
			# console.log 'either'
			mode_either = true
		else if 'not' in prefix
			0 # noop can not handle these things
		else if 'prompt' in prefix
			if level is 2
				judgements.push [matchiness, 1]
			else if level is 1
				judgements.push [matchiness, 1] # or maybe reject
			else
				judgements.push [matchiness, 0]
		else
			if level is 2
				judgements.push [matchiness, 2]
			else if level is 1
				judgements.push [matchiness, 1]
			else
				judgements.push [matchiness, 0]
	
	# console.log judgements

	sorted = judgements.sort ([_a, a], [_b, b]) -> b - a

	[matchiness_prime, judgement_prime] = sorted[0]

	sorted = (a for a in sorted when a[0] is matchiness_prime)

	jury = sorted.sort ([_a, a], [_b, b]) -> b - a
	
	# console.log jury

	[matchiness, judgement] = jury[0]
	
	lower_all_tokens = (word.toLowerCase() for word in all_tokens)
	question_match = (word for word in question_match when word not in lower_all_tokens)

	# do not accept answers which are shorter than their clues
	match_frac = (cat_tokens.join(' ').length + question_match.join(' ').length) / text.length
	
	# console.log cat_tokens, question_match

	if match_frac < 0.6
		return 'reject'
	if judgement is 0
		return 'reject'
	if judgement is 1
		return 'prompt'
	if judgement is 2
		return 'accept'
	


safeCheckAnswer = (compare, answer, question) ->
	try
		tokens = tokenize_line(answer)
		result = check_answer(tokens, compare, question)
		if result is 'accept'
			return true
		else if result is 'prompt'
			return 'prompt'
		else
			return false
	catch err
		return false

if exports?
	exports.checkAnswer = safeCheckAnswer
else if window?
	window.checkAnswer = safeCheckAnswer