#= include ../shared/removeDiacritics.js
#= include ../shared/levenshtein.js
#= include ../shared/porter.js
#= include ../shared/syllable.coffee
#= include ../shared/checker2.coffee

testing = [
	["The {Persistence} of {Memory}", "? persistance"],
	["The {Scream} [or {Skrik}; accept The {Cry}]", "$ Cry"],
	["The {Daily} Show with Jon Stewart", "$ Daily Show"],
	["{Cleveland Browns} [accept either]", "$ Brown"],
	["{Oakland Athletics} [accept either underlined portion; accept A's]", "$ Oakland"],
	["The Lord of the Rings: The {Return of the King}", "? LOTR", "$ ROTK", "$ LOTR: ROTK"],
	["Yellow (accept Yellow Sarong before Sarong is mentioned)", "$ Yelow"],
	["Bioshock 2 [accept Bioshock 2 Multiplayer during the first sentence]", "$ Bioshock 2"],
	["Brooklyn {Dodgers} [or Los Angeles {Dodgers}; prompt on {Los Angeles}]", "? Los Angeles"],
	["{Batman} [accept {Bruce Wayne} before mention; prompt on The {Dark Knight} or The {Caped Crusader}]", "? The Dark Knight", "$ Batman"],
	['{disease} [accept equivalents and accept {itching} until {"Devi Mata"}] (1)', "$ iching"],
	["{Georgia Tech} [do not accept or prompt on just {Georgia}]", "? Georgia"],
	["{airplane bombings} [accept {aircraft} for {airplane}; accept other answers {involving} the {detonation} of {explosive substances} on {civilian planes}; accept {trials} for {airplane bombings} until “{assault} a {motorcade}” is read; prompt “{bombings};” do not prompt “{terrorist attacks}”]", "airplame bombing"],
	["Redskins [accept Washington before mention; accept Redskins at any time]", "$ Redskins"],
	["Jerome David {Salinger}", "$ Salinger", "$ JD Salinger", "$ J.D. Salinger", "! Jerome", "! David", "? Jerome David"],
	["Works Progress Administration", "$ WPA"]
	["{Blu-ray discs}", "$ blu ray disk"]
	["{Dinosaur Comics} [prompt on {qwantz.com}]", "! hi", "? dinosaur", "? quantz"],
	["U.S. Presidential election of {1896}", "$ 1896", "! 1876"],
	["Battle of {Actium}", "! battle of"],
	["Pope {Gregory XVI}", "$ gregory 16", "! gregory 10 11 12 13 14 15 16 17 18 19 20"],
	["{ectothermic} [or {poikilothermic}; accept {cold-blooded}, but {inform players} that they {properly should use}", "$ cold blooded"],
	["{hair} [or {fur}]", "$ hari"]
	["{rabindrath tagore}", "$ tagore rabinathat"]
	["One {Hundred} Years of {Solitude} (or {Cien Anos} de {Soledad})", "$ cien anos de soledad"],
	["{artificial intelligence}", "$ ai", "$ AI"]
	["John Davison {Rockefeller}", "$ JD Rockefeller", "$ Rockefeller"]
	["{Environmental Protection Agency}", "$ EPA", "$ Environmental PA", "$ E P A", "$ E.P.A.", "! P.G.A.", "$ E. P. A."]
	["{Kurt Vonnegut Jr.}", "$ kurt vonnegut jr"],
	["{Kimball O'Hara}", "$ Kimball OHara", "$ Kimball O'Hara", "$ Kimball O Hara"],
	['"{Chicago}"', '$ chicago']
	['{robert jones}', '$ bob jones']
	['{william clinton}', '$ bill clinton']
	["the {independence} of {bangladesh} [or the {independence} of {east} pakistan or other equivalents]", "! I WANT TO"],
	["Claude {Monet}", "! Manet"]
	["the first {G.I. Bill} of Rights", "$ GI Bill"]
	["{Roots}: The Saga of an American Family", "$ roots"]
	["{St. Thomas Aquinas}", "$ Saint Thomas Aquinas"]
	["{Octavian} [or Caesar {Augustus}; or {Octavius}]", "? caesar"]
	["Georgia {O'Keeffe}", "$ okeefe"],
	["{geometric} series", "! are you serious"]
	["{Robert Browning}", "! Bob Yellowing", "! Browning Bananas the Robert", "$ Bob Browning"],
	["{Johann Sebastian Bach} [prompt on {Bach}; prompt on {Johann Bach}]", "$ J.S. Bach", "$ JS Bach"],
	["{Spider}-{Man} [accept {Peter Parker}, either first or last name, before mention]", "$ spiderman"],
	["{time}", "$ time"]
	["Günter Wilhelm {Grass}", "$ grass"],
	["Olympia", "$ olympia"]
	["Republic of {Honduras}", "$ Honduras"]
	["{Emily} Jane {Brontë} [prompt on {Brontë}]", "$ Emily Bronte", "? Bronte"]
	["{Light-Emitting Diode} (prompt on {diode})", "$ LED"],
	["{Les Miserables} [accept The {Miserable Ones}, accept {Jean Valjean}]", "$ Valjean"]
	["Beethoven's Symphony No. {9} in D minor [or {Choral} symphony; or {Beethoven's opus} 125]", "$ Beethoven's Ninth"]
	["Styx", "$ river styx"]
	["derivative", "$ derivative"]
	["{Human Immunodeficiency} Virus [do not accept or prompt on “{AIDS};” prompt on “{retrovirus}” until “{TAR}”]", "$ HIV"]
	["{O. Henry} [or {William Sidney Porter}; prompt on {Porter}] ", "$ o henry", "$ o. henry", "$ ohenry"]
	["{Inferno} [prompt on The {Divine Comedy}]", "$ Inferno", "? The Divine Comedy", "$ The Divine Comedy Inferno"]
	["The {Hay Wain}", "$ Haywain"]
	["Washington {Irving} [or {Jonathan Oldstyle}; or {Geoffrey Crayon}]", "$ irving"]
	["1984", "$ nineteen eighty-four"]
	['{bipolar junction} transistor [or {BJT}; prompt on {"transistor"}]', "? transistor", "$ BJT"]
	["Romance of the {3 Kingdoms} or {sânguó y?nyì}", "$ the three kingdoms"]
	['{snakes} [or {serpents}; prompt on {nagas}; do not prompt on “{dragons}”]', '$ snake']
	["{Golgi} apparatus/body/dictyosome/complex", "$ golgi body"]
	["Publius {Vergilius} Maro", "$ vergil"]
	["{Hall} effect", "$ hall lolololol"]
	["Pierre {Abélard} or Peter {Abelard} or Petrus {Abaelardus}, I guess", "! dog"]
	["{Falklands} war (accept {Malvinas} war, do not accept {Battle} of {Falklands}, which was in WWI)", "! war of"]
	["{World War I}", "$ WWI"]
	["Sigmund {Freud}", "$ freud", "$                  freud", "$  \t  \t freud", "$          freud"]
	["{moving/immigrating} to {Israel}", "moving to israel"]
]

for [line, guesses...] in testing
	# console.time('checking answer')
	tokens = tokenize_line(line)
	for guess in guesses
		command = guess.trim()[0]
		if command in ['$', '!', '?']
			guess = guess.trim().slice(1)

		result = check_answer tokens, guess
		mapping = {'accept': '✔', 'reject': '✗', 'prompt': '?'}
		if command is '$' and result isnt 'accept' # correct
			console.error mapping[result], line, guess
		else if command is '?' and result isnt 'prompt' # prompt
			console.error mapping[result], line, guess
		else if command is '!' and result isnt 'reject' # reject
			console.error mapping[result], line, guess
		else if command in ['$', '!', '?']
			console.debug mapping[result], line, guess
		else
			console.log mapping[result], line, guess


updater_socket = new WebSocket("ws://localhost:#{protobowl_config?.dev_port || 5577}")

updater_socket.onopen = ->
	console.log "updater websocket connection is open"

updater_socket.onmessage = (e) ->
	console.log 'got signal for new update', e.data
	setTimeout ->
		location.reload(true)
	, 100
		
updater_socket.onclose = ->
	console.log 'updater socket was closed'
	setTimeout connect_updater, 1000

dave = new XMLHttpRequest()
dave.open 'get',  '/daveshead.txt', true
dave.send null

answer_by_answer = {}

canonicalize = (answer) ->
	removeDiacritics(answer).toLowerCase().replace(/\{|\}/g, '').trim()

dave.onload = ->
	for line in dave.responseText.split('\n')
		[answer, guess] = line.split("\t")
		continue unless answer and guess
		canon = canonicalize(answer)
		answer_by_answer[canon] = [] unless canon of answer_by_answer
		answer_by_answer[canon].push guess

	# load_question()

# question_db = {}
# meeky_fixy = ->
# 	console.log 'im getting stuff okee?'
# 	# $.get "/jun3.questions.json", (data, status) ->
# 	xhr = new XMLHttpRequest()
# 	xhr.open 'get', '/jun3.questions.json', true
# 	xhr.send null
# 	xhr.onload = ->
# 		data = xhr.responseText
# 		console.log 'loaded text'
# 		for line in data.split('\n') when line
# 			json = JSON.parse(line)
# 			question_db[json._id.$oid] = json
# 		console.log 'loaded db'

# meeky_fixy()

# load_peek = ->
# 	$.get 'http://localhost:5566/stalkermode/to_meekly_go', (data, status) ->
# 		json = JSON.parse(data)
# 		if !json
# 			console.error "NOTHING LEFT"
# 			return
# 		# console.log json, question_db[json._id]
# 		$.post 'http://localhost:5566/stalkermode/reports/simple_change/'+json._id, {answer: question_db[json._id].answer, fixed: -1}, (data, status) ->
# 			console.log data, status
# 			load_peek()


what_remains = ->
	$.get 'http://localhost:5566/stalkermode/remaining', (data, status) ->
		$('#remaining').text(data);
	

load_question = ->
	$.get 'http://localhost:5566/stalkermode/to_boldly_go', (data, status) ->
		json = JSON.parse(data)
		if json is null
			return load_question()
		original_answer = json.answer
		json.answer = json.answer.replace(/\[[A-Z][A-Z]\]/, '').replace(/\<[A-Z][A-Z]\>/, '').replace(/\[[A-Z][a-z][A-Z]\]/, '').replace(/\<[A-Z][a-z][A-Z]\>/, '').replace(/\([0-9]+\)\s*$/, '').replace(/\(\{[0-9]+\}\)\s*$/, '').trim()
		answer = json.answer
		console.log answer
		canon = canonicalize(answer)

		tokens = tokenize_line(answer)
		# console.log tokens
		render_bold(json)
		
		stuff = answer_by_answer[canon]
		failures = 0
		[prefix, front, preposition, back, suffix] = tokens[tokens.length - 1]
		first_group = (text for [bold, text] in front).join(' ')
		console.log first_group

		if stuff and tokens[0]
			console.log 'responses', stuff
			for response in stuff
				result = safeCheckAnswer(response, reconstruct_answerline(), json.question)
				continue if result is true
				continue if response.trim() is ''

				navver.find('li a').each ->
					needle = $(this).text().trim()
					if !fuzzy_search(needle, response) and fuzzy_search(needle, first_group)
						$(this).removeClass('bold')

			for response in stuff
				result = safeCheckAnswer(response, reconstruct_answerline(), json.question)
				continue if result is true
				console.warn("Post Change Failure", result, response, reconstruct_answerline())
				failures++
		else
			console.warn("no such answer thingy exists")
			failures++
		
		if reconstruct_answerline().indexOf(" ") is -1
			failures = 0
		# revert everything that is 42 & 21
		level = 57
		if failures isnt 0
			level = 22
		console.log json.answer, '-->', reconstruct_answerline()
		if reconstruct_answerline().toLowerCase().replace(/[^a-z]/ig, '') == json.answer.toLowerCase().replace(/[^a-z]/ig, '')
			new_line = reconstruct_answerline()
			if new_line.indexOf(" ") is -1 and new_line.indexOf("{") is -1
				new_line = "{" + new_line + "}" # wrap it in a bold

			$.post 'http://localhost:5566/stalkermode/reports/set_bold', {answer: new_line, old: original_answer, fixed: level}, (data, status) ->
				console.log(data, status)
				# load_next();
				load_question()
		else
			console.error 'FATAL ERROR', reconstruct_answerline(), "FROM", json.answer
	
# setInterval ->
# 	what_remains()
# , 2 * 1000


# answer = $('<div>').addClass('control-group').appendTo("#magic")
# answer.append $("<label>").addClass('control-label').text('Answer')
navver = $("<ul>").addClass("nav nav-pills emboldinator").appendTo("#magic")

# answer.append $("<div>").addClass('controls').append navver
reconstruct_answerline = ->
	return navver.find('li a').map( -> 
				if $(this).hasClass('bold')
					raw = $(this).text()
					before = raw.match(/^\s*/)[0]
					after = raw.match(/\s*$/)[0]
					return "#{before}{#{raw.trim()}}#{after}"
				else
					return $(this).text()
			)
			.toArray()
			.join('~')
			.replace(/~/g, '')
			.replace(/\s+/g, ' ')
			.replace(/\}\s*\{/g, ' ')
			.replace(/\s([\]\)])/g, '$1')
			.replace(/([\[\(])\s/g, '$1')
			# .replace(/~([\{\}\[\]\(\)])~/g, '$1')
			# .replace(/\} \{/g, ' ')
			# .replace(/\[ /g, '[')
			# .replace(/\ \]/g, ']')

render_bold = (info) ->
	navver.empty()
	segments = info.answer
		.replace(/([\{\}\[\]\(\)\-])/g, '`$1`')
		.replace(/\ +/g, ' ` ')
		.replace(/\ +/g, ' ')
		.split('`')
	cur_mode = false
	parsed = []
	for seg in segments
		if seg is '{'
			cur_mode = true 
		else if seg is '}'
			cur_mode = false 
		else if seg
			parsed.push [cur_mode, seg]
	invalid_answerline = ->
		line = reconstruct_answerline() 
		console.log line
		return true if line is info.answer
		return true if line.indexOf('{') is -1

		return false


	for [mode, text] in parsed
		# console.log mode, text
		
		link = $("<a>")
			.toggleClass('bold', mode)
			.appendTo($("<li>").appendTo(navver))
			.text(text)
			.attr('href', '#')

		if text.trim() in ['[', ']', ';', ',', '(', ')', '"', '', '”', '“', '-']
			if text in [' ']
				link.hide()
			link
				.removeClass('bold')
				.addClass('unboldable')
				.click ->
					return false
		else
			link
				.click ->
					$(this).toggleClass('bold')
					line = reconstruct_answerline()
					return false