fs = require('fs')

readline = require('readline')
rl = readline.createInterface(process.stdin, process.stdout)
checkAnswer = require('./answerparse').checkAnswer


    
answers = []
fs.readFile 'sample.txt', 'utf8', (err, data) ->
	throw err if err
	answers = (JSON.parse(line).answer for line in data.split("\n"))
	answers = (answer for answer in answers when answer.length < 250)
	answers = answers.sort -> Math.random() - 0.5
	nextQuestion()	

nextQuestion = ->
	answer = answers.shift()
	rl.question answer, (resp) ->
		for opt in resp.split(',')
			answ = checkAnswer opt, answer
			console.log answ, answ < 1
			console.log "--------------------"
		nextQuestion()
		# console.log resp

		