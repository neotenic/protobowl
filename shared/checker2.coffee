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
	"The {Persistence} of {Memory}",
	"The {Scream} [or {Skrik}; accept The {Cry}]",
	"The {Daily} Show with Jon Stewart",
	"{Cleveland Browns} [accept either]",
	"{Oakland Athletics} [accept either underlined portion; accept A's]",
	"The Lord of the Rings: The Return of the King",
	"Yellow (accept Yellow Sarong before Sarong is mentioned)",
	"Bioshock 2 [accept Bioshock 2 Multiplayer during the first sentence]",
	"Brooklyn {Dodgers} [or Los Angeles {Dodgers}; prompt on {Los Angeles}]",
	"{Batman} [accept {Bruce Wayne} before mention; prompt on The {Dark Knight} or The {Caped Crusader}]",
	'{disease} [accept equivalents and accept {itching} until {"Devi Mata"}] (1)',
	"Georgia Tech [do not accept or prompt on just Georgia]"
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
		prefix_words = ["do","not","accept","or","prompt", "on", "just"]
		# ,"on", "either", "underlined", "portion", "equivalents", "equivalent", "word", "forms", "like", "any", "other", "in", "order"
		# suffix_words = ["before", "after", "mentioned", "mention", "it", "is", "read", "during", "the", "first", "last", "sentence", "until", "while"]
		splitters = ["before", "after", "during", "while", "until"]
		prefix = []
		for [bold, token] in group # find all the words which belong as a prefix
			if token in prefix_words # maybe in the future, ignore bolded words
				prefix.push token
			else
				break
		front = [] 
		back = []
		preposition = null
		for [bold, token] in group # split the acceptable responses by a preposition
			if preposition
				back.push [bold, token]
			else if token in splitters and bold is false
				preposition = token
			else if token in prefix
				0 #noop
			else
				front.push [bold, token]

		console.log prefix, front, preposition, back
		# group.reverse()
		# for [bold, token] in group # find all the words which belong as a suffix
		# 	if token in suffix_words
		# 		suffix.push token
		# 	else
		# 		break
		# suffix.reverse() # since its found in reverse, reverse it again
		# group.reverse() #undo the first reversal
		# infix  = []
		# for [bold, token] in group
		# 	if token not in suffix and token not in prefix
		# 		infix.push [bold, token]

		# console.log prefix.join(' '), suffix.join(' '), infix
			




	

setTimeout ->
	for line in testing
		tokenize_line line
, 1000