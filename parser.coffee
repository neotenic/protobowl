fs = require('fs')
removeDiacritics = require('./removeDiacritics').removeDiacritics
damlev = require('./levenshtein').levenshtein
console.log removeDiacritics
stopwords = 'dont,accept,either,underlined,prompt,on,in,to,the,of,is,a,mentioned,before,that,have,word,equivalents,forms,jr,sr,etc,a'.toLowerCase().split(',')

fs.readFile 'sample.txt', 'utf8', (err, data) ->
	throw err if err
	answers = (JSON.parse(line).answer for line in data.split("\n"))
	answers = (answer for answer in answers when answer.length < 250)
	for answer in answers
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

		for p in pos
			list = (word for word in p.split(/\s/) when word.toLowerCase().trim() not in stopwords and word.trim() isnt '')
			compare = 'neucleus'.split ' '
			if list.length > 0
				console.log list
				sum = 0
				for index in [0...list.length]
					scores = for word in compare
						damlev list[index].toLowerCase(), word.toLowerCase()
					sorted = scores.sort (a, b) -> a - b
					weight = 1
					weight = 3 if index is list.length - 1

					weighted = sorted[0] * weight / list[index].length
					sum += weighted
				console.log sum
		
		console.log '------------------'
			# console.log part
		# console.log clean