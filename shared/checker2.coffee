# parse2 = (answer) ->
# 	remove_diacritics = removeDiacritics

# 	answer = answer.replace(/[\[\]\<\>\{\}][\w\-]+?[\[\]\<\>\{\}]/g, '')
# 	console.log answer

# 	clean = (part.trim() for part in answer.split(/[^\w]or[^\w]|\[|\]|\{|\}|\;|\,|\<|\>|\(|\)/g))
# 	clean = (part for part in clean when part isnt '')
# 	pos = []
# 	neg = []
# 	prompt = []
# 	for part in clean 
# 		part = remove_diacritics(part) #clean out some non-latin characters
# 		part = part.replace(/\"|\'|\“|\”|\.|’|\:/g, '')
# 		part = part.replace(/-/g, ' ')
		
# 		if /equivalent|word form|other wrong/.test part
# 			# log 'equiv-', part
# 		else if /do not|dont/.test part
# 			# log 'neg-', part
# 			neg.push part
# 		else if /accept/.test part 
# 			comp = part.split(/before|until/)
# 			if comp.length > 1
# 				neg.push comp[1]
# 			pos.push comp[0]
# 			# log 'pos-', comp
# 		else if /prompt/.test part
# 			prompt.push part
# 		else
# 			pos.push part
# 	[pos, prompt, neg]



# ["Jerome David Salinger", "Salinger", "JD Salinger", "J.D. Salinger", "Jerome", "David"]
# ["Works Progress Administration", "WPA"]

testing = [
	["The {Persistence} of {Memory}", "persistance"],
	["The {Scream} [or {Skrik}; accept The {Cry}]", "Cry"],
	["The {Daily} Show with Jon Stewart", "Daily Show"],
	["{Cleveland Browns} [accept either]", "Brown"],
	["{Oakland Athletics} [accept either underlined portion; accept A's]", "Oakland"],
	["The Lord of the Rings: The Return of the King", "LOTR"],
	["Yellow (accept Yellow Sarong before Sarong is mentioned)", "Yelow"],
	["Bioshock 2 [accept Bioshock 2 Multiplayer during the first sentence]", "Bioshock 2"],
	["Brooklyn {Dodgers} [or Los Angeles {Dodgers}; prompt on {Los Angeles}]", "Los Angeles"],
	["{Batman} [accept {Bruce Wayne} before mention; prompt on The {Dark Knight} or The {Caped Crusader}]", "The Dark Knight"],
	['{disease} [accept equivalents and accept {itching} until {"Devi Mata"}] (1)', "itching"],
	["Georgia Tech [do not accept or prompt on just Georgia]", "Georgia"],
	["{airplane bombings} [accept {aircraft} for {airplane}; accept other answers {involving} the {detonation} of {explosive substances} on {civilian planes}; accept {trials} for {airplane bombings} until “{assault} a {motorcade}” is read; prompt “{bombings};” do not prompt “{terrorist attacks}”]", "airplame bombing"]
]

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
		else
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
		suffix_words = ["is", "read", "stated", "mentioned"]
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
	return haystack.toLowerCase().indexOf(needle.toLowerCase())	!= -1


check_answer = (tokens, text) ->
	for [prefix, front, preposition, back, suffix] in tokens
		bold_match = []
		unbold_match = []
		bold_miss = []
		unbold_miss = []
		# evaluate errything
		for [bold, token] in front
			match = fuzzy_search(token, text)
			bold_match.push token if match and bold
			unbold_match.push token if match and !bold
			unbold_miss.push token if !match and !bold
			bold_miss.push token if !match and bold
		if bold_match > 0
			if bold_miss > 0
				# prompt
			else
				# match

		console.log bold_match, unbold_match, bold_miss
	


		# console.log prefix, front, preposition, back, suffix

setTimeout ->
	for [line, guesses...] in testing
		tokens = tokenize_line(line)
		for guess in guesses
			check_answer tokens, guess
, 1000