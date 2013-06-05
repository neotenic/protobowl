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
	["The Lord of the Rings: The Return of the King", "$ LOTR"],
	["Yellow (accept Yellow Sarong before Sarong is mentioned)", "$ Yelow"],
	["Bioshock 2 [accept Bioshock 2 Multiplayer during the first sentence]", "$ Bioshock 2"],
	["Brooklyn {Dodgers} [or Los Angeles {Dodgers}; prompt on {Los Angeles}]", "? Los Angeles"],
	["{Batman} [accept {Bruce Wayne} before mention; prompt on The {Dark Knight} or The {Caped Crusader}]", "? The Dark Knight", "Batman"],
	['{disease} [accept equivalents and accept {itching} until {"Devi Mata"}] (1)', "$ iching"],
	["Georgia Tech [do not accept or prompt on just Georgia]", "? Georgia"],
	["{airplane bombings} [accept {aircraft} for {airplane}; accept other answers {involving} the {detonation} of {explosive substances} on {civilian planes}; accept {trials} for {airplane bombings} until “{assault} a {motorcade}” is read; prompt “{bombings};” do not prompt “{terrorist attacks}”]", "airplame bombing"],
	["Redskins [accept Washington before mention; accept Redskins at any time]", "$ Redskins"],
	["Jerome David {Salinger}", "$ Salinger", "$ JD Salinger", "$ J.D. Salinger", "! Jerome", "! David", "? Jerome David"],
	["Works Progress Administration", "$ WPA"]
	["{Blu-ray discs}", "$ blu ray disk"]
	["{Dinosaur Comics} [prompt on {qwantz.com}]", "! hi"],
	["U.S. Presidential election of {1896}", "$ 1896", "! 1876"],
	["Battle of {Actium}", "! battle of"],
	["Pope {Gregory XVI}", "$ gregory 16", "! gregory 10 11 12 13 14 15 16 17 18 19 20"],
	["{ectothermic} [or {poikilothermic}; accept {cold-blooded}, but {inform players} that they {properly should use}", "$ cold blooded"],
	["{hair} [or {fur}]", "$ hari"]
	["{rabindrath tagore}", "$ tagore rabinathat"]
	["One {Hundred} Years of {Solitude} (or {Cien Anos} de {Soledad})", "$ cien anos de soledad"],
	["{artificial intelligence}", "$ ai", "$ AI"]
	["John Davison {Rockefeller}", "$ JD Rockefeller", "$ Rockefeller"]
	["{Environmental Protection Agency}", "$ EPA"]
	["{Kurt Vonnegut Jr}", "$ kurt vonnegut jr"],
	["{Kimball O'Hara}", "$ Kimball OHara", "$ Kimball O'Hara", "$ Kimball O Hara"],
	['"{Chicago}"', '$ chicago']
	['{robert jones}', '$ bob jones']
	['{william clinton}', '$ bill clinton']
	["the {independence} of {bangladesh} [or the {independence} of {east} pakistan or other equivalents]", "! I WANT TO"],
	["Claude {Monet}", "! Manet"]
	["the first {G.I. Bill} of Rights", "$ GI Bill"]
	["{Roots}: The Saga of an American Family", "$ roots"]
	["{St. Thomas Aquinas}", "Saint Thomas Aquinas"]
]

for [line, guesses...] in testing
	# console.time('checking answer')
	tokens = tokenize_line(line)
	for guess in guesses
		command = guess.trim()[0]
		if command in ['$', '!', '?']
			guess = guess.trim().slice(1).trim()

		result = check_answer tokens, guess
		
		if command is '$' and result isnt 'accept' # correct
			console.error line, guess, result
		else if command is '?' and result isnt 'prompt' # prompt
			console.error line, guess, result
		else if command is '!' and result isnt 'reject' # reject
			console.error line, guess, result
		else if command in ['$', '!', '?']
			console.debug line, guess, result
		else
			console.log line, guess, result
	# console.timeEnd('checking answer')


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
