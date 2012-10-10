createCategoryList = ->
	$('.custom-category').empty()
	return unless room.distribution
	for cat in room.categories
		item = $('<div>').addClass('category-item').appendTo('.custom-category').data('value', cat)
		$('<span>').addClass('name').text(cat).appendTo item
		picker = $('<div>').addClass('btn-group pull-right dist-picker').appendTo item
		$('<button>').addClass('btn btn-small decrease disabled')
			.append($('<i>').addClass('icon-minus'))
			.appendTo(picker)
		$('<button>').addClass('btn btn-small increase disabled')
			.append($('<i>').addClass('icon-plus'))
			.appendTo(picker)
		$('<span>').addClass('percentage pull-right').css('color', 'gray').appendTo item
		renderCategoryItem(item)

renderCategoryItem = (item) ->
	return unless room.distribution
	s = 0; s += val for cat, val of room.distribution
	value = $(item).data('value')
	percentage = room.distribution[value] / s
	$(item).find('.percentage').html("#{Math.round(100 * percentage)}% &nbsp;")
	$(item).find('.increase').removeClass('disabled')
	if percentage > 0 and s > 1
		$(item).find('.decrease').removeClass('disabled')
	else
		$(item).find('.decrease').addClass('disabled')
		$(item).find('.name').css('font-weight', 'normal')
	if percentage > 0
		$(item).find('.name').css('font-weight', 'bold')

renderParameters = ->
	# re-generate the lists, yaaay
	$('.difficulties option').remove()
	$('.difficulties')[0].options.add new Option("Any", '')
	for dif in room.difficulties
		$('.difficulties')[0].options.add new Option(dif, dif)

	$('.categories option').remove()
	$('.categories')[0].options.add new Option('Everything', '')
	$('.categories')[0].options.add new Option('Custom', 'custom')

	for cat in room.categories
		$('.categories')[0].options.add new Option(cat, cat)
		
	createCategoryList()

renderUpdate = ->
	if room.category is 'custom'
		$('.custom-category').slideDown()
	
	$('.categories').val room.category
	$('.difficulties').val room.difficulty
	$('.multibuzz').attr 'checked', !room.max_buzz

	if $('.settings').is(':hidden')
		$('.settings').slideDown()
		$(window).resize()
	
	# if room.attempt
	# 	updateTextAnnotations()

	if me.id of users and 'show_typing' of users[me.id]
		$('.livechat').attr 'checked', users[me.id].show_typing
		$('.sounds').attr 'checked', users[me.id].sounds
		$('.teams').val users[me.id].team

	if room.attempt
		guessAnnotation room.attempt

	wpm = Math.round(1000 * 60 / 5 / room.rate)
	if !$('.speed').data('last_update') or new Date - $(".speed").data("last_update") > 1337
		if Math.abs($('.speed').val() - wpm) > 1
			$('.speed').val(wpm)


	
	if !room.attempt or room.attempt.user isnt me.id
		setActionMode '' if actionMode in ['guess', 'prompt']
	else
		if room.attempt.prompt
			if actionMode isnt 'prompt'
				setActionMode 'prompt' 
				$('.prompt_input').val('').focus()
		else
			setActionMode 'guess' if actionMode isnt 'guess'

	# if room.time_offset isnt null
	# 	$('#time_offset').text(room.time_offset.toFixed(1))


renderPartial = ->
	console.log 'partial rendering'


renderUsers = ->
	console.log 'rendering users'