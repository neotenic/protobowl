fs = require('fs')

readline = require('readline')
# rl = readline.createInterface(process.stdin, process.stdout)
checkAnswer = require('./answerparse').checkAnswer
parseAnswer = require('./answerparse').parseAnswer


    
# answers = []
# fs.readFile 'sample.txt', 'utf8', (err, data) ->
# 	throw err if err
# 	answers = (JSON.parse(line).answer for line in data.split("\n"))
# 	answers = (answer for answer in answers when answer.length < 250)
# 	answers = answers.sort -> Math.random() - 0.5
# 	answers = answers.slice(0, 100)
# 	# 
# 	against = []
# 	for a in answers
# 		[pos, neg] = parseAnswer(a)
# 		for i in pos
# 			against.push i
# 	for a in answers
# 		for d in against
# 			for c in d.split(' ')
# 				if checkAnswer(c, a) is true
# 					if c isnt a
# 						console.log c, a
	# nextQuestion()	

nextQuestion = ->
	answer = answers.shift()
	rl.question answer, (resp) ->
		for opt in resp.split(',')
			answ = checkAnswer opt, answer
			console.log "judgement", answ
			console.log "--------------------"
		nextQuestion()
		# console.log resp
z = (a, b) ->
	console.log checkAnswer a, b

z 'shay\'s rebellion', 'bacons rebellion'
z 'haymarket', 'haymarket square'
z 'feynman', 'Richard Feynman'
z 'fineman', 'Richard Feynman'

z 'circumsize', 'circumsision'
z 'circumsise', 'circumsision'
z 'science', 'scientology'
z 'scientology', 'science'
z 'al gore', 'albert al gore'
z 'cage', 'John Cage'
z 'nicolas cage', 'John Cage'
z 'locke', 'john locke'
z 'blake', 'William Blake'
z 'hangover', 'The Hangover'
z 'curcible', 'The Crucible'
z "cortez","Hernan Cortes de Monroy y Pizarro, First Marques del Valle de Oaxaca"
z "hernando","Hernan Cortes de Monroy y Pizarro, First Marques del Valle de Oaxaca"
z "13 ways of looking at a blackbird", "Thirteen Ways of Looking at a Blackbird"
z "Frost", "Robert Lee Frost"
z "Robert", "Robert Lee Frost"
z "rawls", "John Rawls"
z "Hume", 'David Hume'
z "The Woolf", "Virginia Woolf"
z "jaialai", "jai alai (HI-ah-LIE)"
z "paramagnetic", "paramagnetism"
z "sheild", "shields"
z "Pierre Renoir", "Pierre-Auguste Renoir"
z "Taft", "Robert Taft"
z "Atwell", "Margaret Atwood"
z "os x", "Mac OSX [or Macintosh Operating System Ten; accept letter-by-letter pronunciations of"
z "osx", "Mac OSX [or Macintosh Operating System Ten; accept letter-by-letter pronunciations of"
z "house of lords","The House of Lords [or The House of Lords Spiritual and Temporal or The House of Peers]"
z 'borobn', "boron [or B]"
z 'acid', 'base'
z "luke", 'The Gospel According to Luke [or Gospel of Luke]'
z "kublai khan", 'An Lushan (accept An Luoshan or Ga Luoshan)'
z '1856', 'United States Presidential election of 1852'
z '1852', 'United States Presidential election of 1852'
z 'tree', 'RAM [or random-access memory; prompt on memory; accept DRAM or dynamic'
z 'poisson', 'Paul Cézanne'
z 'chrysanthemum and the sword', 'The Chrysanthemum and the Sword: Patterns of Japanese Culture'
z "Debs","Eugene Victor Debs"
z "Battle","Battle of Bunker Hill [or Battle of Breed's Hill before it is read]"