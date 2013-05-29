

tokenize_line = (answer) ->
	tokens = answer
		.replace(/([\{\}\[\]\;\-\:\,\&])/g, " $1 ") # wrap all the special delimiting symbols
		.replace(/\ +/g, ' ') # condense multiple spaces
		.trim() # removing leading and trailing spaces
		.split(' ') # split things up
	bold = false
	processed = []
	for token in tokens # loop to annotate each token with boldness state
		if token is '{'
			bold = true
		else if token is '}'
			bold = false
		else if token not in ['-', ':', '=', '&', '%', ';']
			processed.push [bold, token]
	
	buffer = []
	completed = []
	for [bold, token] in processed # loop to split different statements
		if token.toLowerCase() in ['[', 'or', ';', ']', '(', ')', ',', 'and', 'but']
			completed.push buffer if buffer.length
			buffer = []
		else
			buffer.push [bold, token]
	completed.push buffer if buffer.length # add the remainder
	
	# console.log completed

	# parse statements in reverse order for situations like accept either
	for group in completed.reverse()
		prefix_words = ["do","not","accept","or","prompt", "on", "just", "don't"]
		# ,"on", "either", "underlined", "portion", "equivalents", "equivalent", "word", "forms", "like", "any", "other", "in", "order"
		suffix_words = ["is", "read", "stated", "mentioned", "at", "any", "time"]
		splitters = ["before", "after", "during", "while", "until"]
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

		[prefix, front, preposition, back, suffix]

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

	haystack = remove_diacritics(haystack.toLowerCase())
	needle = remove_diacritics(needle.toLowerCase())

	return true if haystack.replace(/\s/g, '').indexOf(needle) != -1
	stem = stemmer(needle)
	
	ERROR_RATIO = 0.2 # magic number i pulled out of my ass

	for word in haystack.split(/\s|\-/)
		plain = damlev(word, needle)
		plaid = plain / Math.min(word.length, needle.length)
		
		# console.log plaid, word, needle

		return true if plaid <= ERROR_RATIO
		
		xylem = stemmer(word)
		diff = damlev(xylem, stem)
		frac = diff / Math.min(xylem.length, stem.length)
		
		return true if frac <= ERROR_RATIO
		

	return false


check_answer = (tokens, text) ->
	judgements = []
	index = 0
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
			bold_match.push token if match and bold
			unbold_match.push token if match and !bold
			unbold_miss.push token if !match and !bold
			bold_miss.push token if !match and bold
			bolded.push token if bold
			unbold.push token if !bold
		
		matchiness = bold_match.length + unbold_match.length #+ (0.002 / (index + 20))

		level = 0 # 0 = reject, 1 = prompt, 2 = accept		
		
		if bold_match.length > 0
			if bold_miss.length > 0
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

		if 'not' in prefix
			0 # noop can not handle these things
		else if 'prompt' in prefix
			if level is 2
				judgements.push [matchiness, 1]
			else
				judgements.push [matchiness, 1] # or maybe reject
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

	if judgement is 0
		return 'reject'
	else if judgement is 1
		return 'prompt'
	else if judgement is 2
		return 'accept'
	



# setTimeout ->
# 	testing = [
# 		["The {Persistence} of {Memory}", "persistance"],
# 		["The {Scream} [or {Skrik}; accept The {Cry}]", "Cry"],
# 		["The {Daily} Show with Jon Stewart", "Daily Show"],
# 		["{Cleveland Browns} [accept either]", "Brown"],
# 		["{Oakland Athletics} [accept either underlined portion; accept A's]", "Oakland"],
# 		["The Lord of the Rings: The Return of the King", "LOTR"],
# 		["Yellow (accept Yellow Sarong before Sarong is mentioned)", "Yelow"],
# 		["Bioshock 2 [accept Bioshock 2 Multiplayer during the first sentence]", "Bioshock 2"],
# 		["Brooklyn {Dodgers} [or Los Angeles {Dodgers}; prompt on {Los Angeles}]", "Los Angeles"],
# 		["{Batman} [accept {Bruce Wayne} before mention; prompt on The {Dark Knight} or The {Caped Crusader}]", "The Dark Knight"],
# 		['{disease} [accept equivalents and accept {itching} until {"Devi Mata"}] (1)', "iching"],
# 		["Georgia Tech [do not accept or prompt on just Georgia]", "Georgia"],
# 		["{airplane bombings} [accept {aircraft} for {airplane}; accept other answers {involving} the {detonation} of {explosive substances} on {civilian planes}; accept {trials} for {airplane bombings} until “{assault} a {motorcade}” is read; prompt “{bombings};” do not prompt “{terrorist attacks}”]", "airplame bombing"],
# 		["Redskins [accept Washington before mention; accept Redskins at any time]", "Redskins"],
# 		["Jerome David {Salinger}", "Salinger", "JD Salinger", "J.D. Salinger", "Jerome", "David"],
# 		["Works Progress Administration", "WPA"]
# 		["{Blu-ray discs}", "blu ray disk"]
# 	]
# 	for [line, guesses...] in testing

# 		console.time('checking answer')
# 		tokens = tokenize_line(line)
# 		for guess in guesses
# 			console.log line, guess, check_answer tokens, guess
# 		console.timeEnd('checking answer')
# , 1000

safeCheckAnswer = (compare, answer, question) ->
	tokens = tokenize_line(answer)
	result = check_answer(tokens, compare)
	if result is 'accept'
		return true
	else if result is 'prompt'
		return 'prompt'
	else
		return false

if exports?
	exports.checkAnswer = safeCheckAnswer
else if window?
	window.checkAnswer = safeCheckAnswer