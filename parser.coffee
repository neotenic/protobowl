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

z 'shays rebellion', 'bacons rebellion'
z 'haymarket', 'haymarket square'
z 'feynman', 'richard feynman'
z 'circumsize', 'circumsision'
z 'science', 'scientology'
z 'scientology', 'science'
z 'al gore', 'albert al gore'
z 'cage', 'john cage'
z 'nicolas cage', 'john cage'
