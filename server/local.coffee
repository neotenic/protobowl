questions = []
count = 0
current_category = ''
current_difficulty = ''
current_queue = []

console.log 'loading local questions'
	
listProps = (prop) ->
	propmap = {}
	for q in questions
		propmap[q[prop]] = 1
	return (p for p of propmap)

filterQuestions = (diff, cat) ->
	questions.filter (q) ->
		return false if diff and q.difficulty != diff
		return false if cat and q.category != cat
		return true

fisher_yates = (i) ->
	return [] if i is 0
	arr = [0...i]
	while --i
		j = Math.floor(Math.random() * (i+1))
		[arr[i], arr[j]] = [arr[j], arr[i]] 
	arr

initialize_remote = (cb) -> 
	fs = require 'fs'
	fs.readFile 'static/sample.txt', 'utf8', (err, data) ->
		throw err if err
		questions = (JSON.parse(line) for line in data.split("\n") when line)
		console.log "parsed #{questions.length} questions"
		cb() if cb


handle_report = (data) -> console.log data

get_types = -> ['qb']

count_questions = (type, diff, cat, cb) -> cb filterQuestions(diff, cat).length

get_categories = (type) -> listProps('category')

get_difficulties = (type) -> listProps('difficulty')

get_parameters = (type, difficulty, cb) -> cb get_difficulties(), get_categories()

get_by_id = (id, cb) -> cb null

get_question = (type, diff, cat, cb) ->
	if diff == current_difficulty and cat == current_category and current_queue.length > 0
		cb current_queue.shift()
	else
		current_difficulty = diff
		current_category = cat
		temp_filtered = filterQuestions(diff, cat)
		current_queue = (temp_filtered[index] for index in fisher_yates(temp_filtered.length))
		cb current_queue.shift()

exports.get_by_id = get_by_id
exports.get_question = get_question
exports.count_questions = count_questions
exports.get_categories = get_categories
exports.get_difficulties = get_difficulties
exports.get_parameters = get_parameters
exports.get_types = get_types
exports.initialize_remote = initialize_remote
exports.handle_report = handle_report
# exports.Report = Report
# exports.Question = question

exports.ready = (fn) -> fn()