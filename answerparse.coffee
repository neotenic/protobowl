removeDiacritics = require('./removeDiacritics').removeDiacritics
damlev = require('./levenshtein').levenshtein
stopwords = 'dont,accept,either,underlined,prompt,on,in,to,the,of,is,a,read,mentioned,before,that,have,word,equivalents,forms,jr,sr,dr,phd,etc,a'.toLowerCase().split(',')


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


checkAnswer = (compare, answer) ->
	compare = compare.trim().split ' '
	[pos, neg] = parseAnswer(answer.trim())

	accepts = []

	for p in pos
		list = (word for word in p.split(/\s/) when word.toLowerCase().trim() not in stopwords and word.trim() isnt '')
		
		if list.length > 0
			# console.log list
			sum = 0	
			parts = for index in [0...list.length]
				scores = for word in compare
					score = damlev list[index].toLowerCase(), word.toLowerCase()
					if list[index].toLowerCase()[0] != word.toLowerCase()[0]
						score += 2 #first letters count a lot
					[word, score]
				sorted = scores.sort ([w,a], [z,b]) -> a - b
				weight = 1
				weight = 1.5 if index is 0
				weight = 1.5 if index is list.length - 1

				# weighted = sorted[0][1] * weight / list[index].length
				weighted = Math.max(0, list[index].length - Math.pow(sorted[0][1], 1.5)) * weight

				# console.log list[index], sorted[0][0], sorted[0][1], weighted
				# sum += Math.pow(weighted, 1.1)
				sum += weighted


			# sorp = parts.sort (a, b) -> b - a
			# console.log sorp
			# accepts.push sorp[0]
			accepts.push [list, sum]

	max = accepts.sort ([w,a], [z,b]) -> b - a

	str = max[0][0]
	len = str.join('').length
	score = max[0][1]
	# console.log str, score

	if score > len * 0.8 or score > 8
		return true

	return false

exports.checkAnswer = checkAnswer
exports.parseAnswer = parseAnswer