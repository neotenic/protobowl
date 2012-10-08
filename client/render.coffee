renderParameters = ->
	# re-generate the lists, yaaay
	$('.difficulties option').remove()
	$('.difficulties')[0].options.add new Option("Any", '')
	for dif in sync.difficulties
		$('.difficulties')[0].options.add new Option(dif, dif)

	$('.categories option').remove()
	$('.categories')[0].options.add new Option('Everything', '')
	$('.categories')[0].options.add new Option('Custom', 'custom')

	for cat in sync.categories
		$('.categories')[0].options.add new Option(cat, cat)
		
	createCategoryList()


renderUpdate = ->
	if sync.category is 'custom'
		$('.custom-category').slideDown()
	
	$('.categories').val sync.category
	$('.difficulties').val sync.difficulty
	$('.multibuzz').attr 'checked', !sync.max_buzz

	if $('.settings').is(':hidden')
		$('.settings').slideDown()
	
	# if sync.attempt
	# 	updateTextAnnotations()

	if public_id of users and 'show_typing' of users[public_id]
		$('.livechat').attr 'checked', users[public_id].show_typing
		$('.sounds').attr 'checked', users[public_id].sounds
		$('.teams').val users[public_id].team

	if sync.attempt
		guessAnnotation sync.attempt

	wpm = Math.round(1000 * 60 / 5 / sync.rate)
	if !$('.speed').data('last_update') or new Date - $(".speed").data("last_update") > 1337
		if Math.abs($('.speed').val() - wpm) > 1
			$('.speed').val(wpm)

	
	if !sync.attempt or sync.attempt.user isnt public_id
		setActionMode '' if actionMode in ['guess', 'prompt']
	else
		if sync.attempt.prompt
			if actionMode isnt 'prompt'
				setActionMode 'prompt' 
				$('.prompt_input').val('').focus()
		else
			setActionMode 'guess' if actionMode isnt 'guess'

	# if sync.time_offset isnt null
	# 	$('#time_offset').text(sync.time_offset.toFixed(1))

