do ->
	removeDiacritics = require('./removeDiacritics').removeDiacritics
	damlev = require('./levenshtein').levenshtein
	stemmer = require('./porter').stemmer
	# stopwords = 'lol,dont,accept,either,underlined,prompt,on,in,to,the,of,is,a,read,mentioned,before,that,have,word,equivalents,forms,jr,sr,dr,phd,etc,a'.toLowerCase().split(',')
	# some people like to append "lol" to every answer
	stopwords = "rofl lmao lawl lole lol the on of is a in on that have for at so it do or de y by accept any".split(' ')
	stopnames = "ivan james john robert michael william david richard charles joseph thomas christopher daniel paul mark donald george steven edward brian ronald anthony kevin jason benjamin mary patricia linda barbara elizabeth jennifer maria susan margaret dorothy lisa karen henry harold"
	commwords = ""

	parseAnswer = (answer) ->
		answer = answer.replace(/[\[\]\<\>\{\}][\w\-]+?[\[\]\<\>\{\}]/g, '')

		clean = (part.trim() for part in answer.split(/[^\w]and[^\w]|[^\w]or[^\w]|\[|\]|\{|\}|\;|\,|\<|\>|\(|\)/g))
		clean = (part for part in clean when part isnt '')
		pos = []
		neg = []
		for part in clean 
			part = removeDiacritics(part) #clean out some non-latin characters
			part = part.replace(/\"|\'|\“|\”|\.|’|\:/g, '')
			part = part.replace(/-/g, ' ')
			
			if /equivalent|word form|other wrong/.test part
				# console.log 'equiv-', part
			else if /do not|dont/.test part
				# console.log 'neg-', part
				neg.push part
			else if /accept/.test part 
				comp = part.split(/before|until/)
				if comp.length > 1
					neg.push comp[1]
				pos.push comp[0]
				# console.log 'pos-', comp
			else
				pos.push part
		[pos, neg]




	stem = (word) ->
		return stemmer word.replace(/ez$/g, 'es').replace(/[^\w]/g, '')

	splitWords = (text) ->
		arr = (word.trim() for word in text.toLowerCase().split(/\s+/))
		words = (stem(word) for word in arr when word not in stopwords and word isnt '')
		return words

	isPerson = (answer) ->
		# filter out words less than 3 letters long because they suck
		canon = (name for name in answer.split(/\s+/) when name.length > 3)
		# find words of the canon (seriously i dont know what to call it)
		caps = (name for name in canon when "A" <= name[0] <= "Z")
		# if all words that matter are caps, that means its a person woot
		return caps.length == canon.length

	# so levenshtein deals with letter differences
	# damerau deals with transpositions
	# and this letter reduction algorithm deals with conflated letters
	reduceLetter = (letter) ->
		return 's' if letter in ['z', 's', 'k', 'c']
		return 'e' if letter in ['e', 'a', 'o', 'u', 'y', 'i']
		return letter

	reduceAlphabet = (word) ->
		letters = (reduceLetter(letter) for letter in word.split(''))
		return letters.join('')

	levens = (a, b) ->
		return damlev reduceAlphabet(a), reduceAlphabet(b)

	checkWord = (word, list) ->
		scores = for valid in list
			score = levens valid, word
			[score, valid.length - score, valid.length, valid]
		if scores.length == ''
			return ''
		scores = scores.sort (a, b) -> a[0] - b[0]
		[score, real, len, valid] = scores[0] 
		frac = real / len
		console.log word, valid, list, len, score, frac
		if len > 4
			if frac >= 0.65
				return valid
		else
			if frac >= 0.60
				return valid
		return ''

	advancedCompare = (inputText, p, questionWords) ->
		is_person = isPerson(p.trim())

		list = (word for word in splitWords(p) when word not in questionWords)


		valid_count = 0
		invalid_count = 0

		for word in inputText
			value = 1
			result = checkWord word, list
			if is_person and result in stopnames
				value = 0.5

			if result
				valid_count += value
			else
				invalid_count += value

		console.log "ADVANCED", valid_count, invalid_count, inputText.length
		return valid_count - invalid_count >= 1

		

	rawCompare = (compare, p) ->
		# lowercase and remove spaces and stuff
		compare = compare.toLowerCase().replace(/[^\w]/g, '')
		p = p.toLowerCase().replace(/[^\w]/g, '')

		# calculate the length of the shortest one
		minlen = Math.min(compare.length, p.length)

		diff = levens compare.slice(0, minlen), p.slice(0, minlen)
		accuracy = 1 - (diff / minlen)
		console.log "RAW LEVENSHTEIN", diff, minlen, accuracy

		if minlen >= 4 and accuracy >= 0.65
			return true

		return false


	checkAnswer = (compare, answer, question = '') ->
		console.log '---------------------------'

		question = removeDiacritics(question).trim()
		answer = removeDiacritics(answer).trim()
		compare = removeDiacritics(compare).trim()

		questionWords = splitWords(question)
		inputText = (word for word in splitWords(compare) when word not in questionWords)

		[pos, neg] = parseAnswer(answer.trim())


		for p in pos
			if advancedCompare(inputText, p, questionWords)
				return true
			if rawCompare compare, p
				return true

		return false




	checkAnswer_old = (compare, answer) ->
		compare = removeDiacritics(compare).trim().split ' '
		[pos, neg] = parseAnswer(answer.trim())

		accepts = []

		for p in pos
			list = (word for word in p.split(/\s/) when word.toLowerCase().trim() not in stopwords and word.trim() isnt '')
			
			if list.length > 0
				# console.log list
				sum = 0	

				p2 = for word in compare
					scores = for index in [0...list.length]
						score = damlev list[index].toLowerCase(), word.toLowerCase()
						if list[index].toLowerCase()[0] != word.toLowerCase()[0]
							score += 2 #first letters count a lot
						if list[index].toLowerCase()[1] != word.toLowerCase()[1]
							score += 1 #second letters count quite a bit too
						[index, score]
					sorted = scores.sort ([w,a], [z,b]) -> a - b
					index = sorted[0][0]
					weight = 1
					weight = 1.5 if index is 0
					weight = 1.5 if index is list.length - 1
					weighted = list[index].length - Math.pow(sorted[0][1], 1.0) * weight
					# console.log "first", list[index], index, sorted[0][1], weighted
					sum += weighted

				# parts = for index in [0...list.length]
				# 	scores = for word in compare
				# 		score = damlev list[index].toLowerCase(), word.toLowerCase()
				# 		if list[index].toLowerCase()[0] != word.toLowerCase()[0]
				# 			score += 2 #first letters count a lot
				# 		[word, score]
				# 	sorted = scores.sort ([w,a], [z,b]) -> a - b
				# 	weight = 1
				# 	weight = 1.5 if index is 0
				# 	weight = 1.5 if index is list.length - 1

				# 	# weighted = sorted[0][1] * weight / list[index].length
				# 	weighted =  list[index].length - Math.pow(sorted[0][1], 1.0) * weight

				# 	console.log list[index], sorted[0][0], sorted[0][1], weighted
				# 	# sum += Math.pow(weighted, 1.1)
				# 	sum += weighted


				# sorp = parts.sort (a, b) -> b - a
				# console.log list, sum
				# accepts.push sorp[0]
				accepts.push [list, sum]

		max = accepts.sort ([w,a], [z,b]) -> b - a

		str = max[0][0]
		len = str.join('').length
		score = max[0][1]
		console.log str, score, compare.join(' ')

		if score > len * 0.6 or score > 5
			return true

		return false

	stopnames = splitWords stopnames
	exports.checkAnswer = checkAnswer
	exports.parseAnswer = parseAnswer