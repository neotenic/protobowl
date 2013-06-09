tokenize_line = (answer) ->
	tokens = answer
		.replace(/([\{\}\[\]\;\-\:\,\&\(\)])/g, " $1 ") # wrap all the special delimiting symbols
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
		else if token not in ['-', ':', '=', '&', '%']
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
			if token in suffix_words
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
		['one', 'first', 'i', '1'],
		['two', 'second', 'ii', '2'],
		['three', 'third', 'iii', 'turd', '3'],
		['four', 'forth', 'fourth', 'iv', '4'],
		['fifth', 'five', 'v', '5'],
		['sixth', 'six', 'vi', 'emacs', '6'],
		['seventh', 'seven', 'vii', '7'],
		['eight', 'eighth', '8', 'viii', 'iix'],
		['nine', 'nein', 'ninth', 'ix', '9'],
		['ten', 'tenth', '10', 'x'],
		['eleventh', 'eleven', 'xi'],
		['twelfth', 'twelveth', 'twelve', '12', 'xii'],
		['thirteenth', 'thirteen', '13', 'xiii'],
		['fourteenth', 'fourteen', 'ixv'],
		['fifteenth', 'fifteen', '15', 'xv'],
		['sixteenth', 'sixteen', '16', 'xvi'],
		['seventeenth', 'seventeen', '17', 'xvii'],
		['twenty', 'xx', '20'],
		['thirty', 'xxx', '30'],
		['hundred', 'c', '100'],
		['dr', 'doctor'],
		['mr', 'mister']
		['st', 'saint', 'street']
		['robert', 'bob', 'rob'],
		['william', 'will', 'bill'],
		['richard', 'rich', 'dick'],
		['gregory', 'greg'],
		['christopher', 'chris'],
		['benjamin', 'ben'],
		['nicholas', 'nick'],
		['anthony', 'tony'],
		['lawrence', 'larry'],
		['v', 'versus', 'vs'],
		['log', 'logarithm']
	]
	map = {}
	for group in list
		for item in group
			map[item] = group
	return map
	

fuzzy_search = (needle, haystack) ->
	# console.log needle, haystack

	if removeDiacritics?
		remove_diacritics = removeDiacritics 
	else
		remove_diacritics = require('./removeDiacritics').removeDiacritics
	
	if PorterStemmer?
		stemmer = PorterStemmer
	else
		stemmer = require('./porter').stemmer

	if levenshtein?
		damlev = levenshtein
	else
		damlev = require('./levenshtein').levenshtein 

	haystack = remove_diacritics(haystack)
		.replace(/([A-Z])\.([A-Z])\./g, '$1$2') # this helps the acronym detector
	needle = remove_diacritics(needle.toLowerCase())

	plainstack = haystack.toLowerCase().replace(/[^a-z]/g, '')
	plainneedle = needle.replace(/[^a-z]/g, '')

	return true if plainneedle.length >= 4 and plainstack.indexOf(plainneedle) != -1

	stem = stemmer(needle)
	
	ERROR_RATIO = 0.25 # magic number i pulled out of my ass
	
	composite_acronym = ''
	for word in haystack.split(/\s|\-/)
		# combine all the capitalesque letters
		if /^[A-Z]+$/.test(word) and 2 <= word.length <= 4
			composite_acronym += word

	if 2 <= composite_acronym.length <= 4
		if composite_acronym.toLowerCase().indexOf(needle[0]) isnt -1
			return true

	for word in haystack.split(/\s|\-/)
		word = word.toLowerCase()

		plain = damlev(word, needle)
		plaid = plain / Math.min(word.length, needle.length)
		
		# console.log plaid, word, needle

		return true if plaid <= ERROR_RATIO
		
		xylem = stemmer(word)

		diff = damlev(xylem, stem)
		frac = diff / Math.min(xylem.length, stem.length)
		# console.log frac, word, needle
		
		return true if frac <= ERROR_RATIO

		if needle.length > 6 and word.indexOf(needle.slice(0, 4)) is 0
			# this is for incomplete statements and the ilk
			return true
	
	if needle of equivalence_map
		for word in equivalence_map[needle]
			if " #{haystack.toLowerCase()} ".indexOf(" #{word} ") isnt -1
				return true


	return false


check_answer = (tokens, text) ->
	# these are words which are deemed to be trivial and thus not counted as unbold (though may still be counted as bold)

	stopwords = "as to the that on of o is a in on that have for at so it do or de la le y by any and his her my by him she battle".split(' ')

	judgements = []
	index = 0
	mode_either = false
	cat_tokens = []

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

	
	sorted = judgements.sort ([a], [b]) -> b - a

	[matchiness_prime, judgement_prime] = sorted[0]

	sorted = (a for a in sorted when a[0] is matchiness_prime)

	jury = sorted.sort ([_a, a], [_b, b]) -> b - a
	
	# console.log jury

	[matchiness, judgement] = jury[0]
	
	# do not accept answers which are shorter than their clues
	match_frac = cat_tokens.join(' ').length / text.length
	if match_frac < 0.6
		# console.warn 'insubstatnial match fraction', match_frac
		return 'reject'

	if judgement is 0
		return 'reject'
	else if judgement is 1
		return 'prompt'
	else if judgement is 2
		
		return 'accept'
	


safeCheckAnswer = (compare, answer, question) ->
	try
		tokens = tokenize_line(answer)
		result = check_answer(tokens, compare)
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