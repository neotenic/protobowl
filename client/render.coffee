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
	# 	updateInlineSymbols()

	if me.id of room.users and 'show_typing' of room.users[me.id]
		$('.livechat').attr 'checked', room.users[me.id].show_typing
		$('.sounds').attr 'checked', room.users[me.id].sounds
		$('.teams').val room.users[me.id].team

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

last_rendering = 0
last_question = ''

renderPartial = ->
	if (!room.time_freeze or room.attempt) and room.time() < room.end_time
		requestAnimationFrame(renderPartial)
		# setTimeout renderPartial, 1000 / 30
		return if new Date - last_rendering < 1000 / 20

	last_rendering = +new Date
	
	if !room.question 
		if $('.start-page').length is 0
			console.log 'adding a start thing'
			start = $('<div>').addClass('start-page').hide().prependTo '#history'
			well = $('<div>').addClass('well').appendTo start
			$('<button>')
				.addClass('btn btn-success btn-large')
				.text('Start the Question')
				.appendTo(well)
				.click -> me.next()
			start.slideDown()
	else
		if $('.start-page').length isnt 0
			$('.start-page').slideUp 'normal', -> $(this).remove()
		if room.question + room.generated_time isnt last_question
			changeQuestion()
			last_question = room.question + room.generated_time # these two should comprise a unique signal
	
	updateTextPosition()

	# #render the time
	renderTimer()


renderTimer = ->
	# $('#pause').show !!room.time_freeze
	# $('.buzzbtn').attr 'disabled', !!room.attempt
	if connected()
		$('.offline').fadeOut()
	else
		$('.offline').fadeIn()

	if room.time_freeze
		$('.buzzbtn').disable true

		if room.attempt
			do ->
				del = room.attempt.start - room.begin_time
				i = 0
				i++ while del > room.cumulative[i]
				starts = ($('.bundle.active').data('starts') || [])
				starts.push(i - 1) if (i - 1) not in starts
				$('.bundle.active').data('starts', starts)

			$('.label.pause').hide()
			$('.label.buzz').fadeIn()

		else
			$('.label.pause').fadeIn()
			$('.label.buzz').hide()
			

		# show the resume button
		if $('.pausebtn').hasClass('btn-warning')

			$('.pausebtn .resume').show()
			$('.pausebtn .pause').hide()

			$('.pausebtn')
			.addClass('btn-success')
			.removeClass('btn-warning')

	else
		# show the pause button
		$('.label.pause').fadeOut()
		$('.label.buzz').fadeOut()
		if $('.pausebtn').hasClass('btn-success')
			$('.pausebtn .resume').hide()
			$('.pausebtn .pause').show()
			$('.pausebtn')
			.addClass('btn-warning')
			.removeClass('btn-success')
	
	# if room.time() >= room.end_time
	# 	$('.label.finished').fadeIn()
	# else
	# 	$('.label.finished').hide()

	if room.time() > room.end_time - room.answer_duration
		# $('.progress').addClass 'progress-info'
		if $(".nextbtn").is(":hidden")
			$('.nextbtn').show() 
			$('.skipbtn').hide() 
	else
		# $('.progress').removeClass 'progress-info'
		if $(".skipbtn").is(":hidden")
			$('.nextbtn').hide()
			$('.skipbtn').show()

	$('.timer').toggleClass 'buzz', !!room.attempt


	$('.primary-bar').toggleClass 'bar-warning', !!(room.time_freeze and !room.attempt)
	$('.primary-bar').toggleClass 'bar-danger', !!room.attempt
	$('.progress').toggleClass 'active', !!room.attempt

	
	if room.attempt
		elapsed = room.serverTime() - room.attempt.realTime
		ms = room.attempt.duration - elapsed
		progress = elapsed / room.attempt.duration
		$('.pausebtn, .buzzbtn, .skipbtn, .nextbtn').disable true
	else
		ms = room.end_time - room.time()
		elapsed = (room.time() - room.begin_time)
		progress = elapsed/(room.end_time - room.begin_time)
		$('.skipbtn, .nextbtn').disable false
		$('.pausebtn').disable (ms < 0)
		unless room.time_freeze
			$('.buzzbtn').disable (ms < 0 or elapsed < 100)
		if ms < 0
			$('.bundle.active').find('.answer')
				.css('display', 'inline')
				.css('visibility', 'visible')
			ruling = $('.bundle.active').find('.ruling')
			unless ruling.data('shown_tooltip')
				ruling.data('shown_tooltip', true)
				$('.bundle.active').find('.ruling').first()
					.tooltip({
						trigger: "manual"
					})
					.tooltip('show')
	
	# if $('.progress .primary-bar').hasClass 'pull-right'
	# 	$('.progress .primary-bar').width (1 - progress) * 100 + '%'
	# else
	# 	
	if room.attempt or room.time_freeze
		$('.progress .primary-bar').width progress * 100 + '%'
		$('.progress .aux-bar').width '0%'
	else
		fraction = (1 - (room.answer_duration / (room.end_time - room.begin_time))) * 100
		$('.progress .primary-bar').width Math.min(progress * 100, fraction) + '%'
		$('.progress .aux-bar').width Math.min(100 - fraction, Math.max(0, progress * 100 - fraction)) + '%'

	ms = Math.max(0, ms) # force time into positive range, comment this out to show negones
	sign = ""
	sign = "+" if ms < 0
	sec = Math.abs(ms) / 1000


	cs = (sec % 1).toFixed(1).slice(1)
	$('.timer .fraction').text cs
	min = sec / 60
	pad = (num) ->
		str = Math.floor(num).toString()
		while str.length < 2
			str = '0' + str
		str
	$('.timer .face').text sign + pad(min) + ':' + pad(sec % 60)

renderUsers = ->
	console.log 'rendering users'


changeQuestion = ->
	return unless room.question and room.generated_time
	cutoff = 15
	#smaller cutoff for phones which dont place things in parallel
	cutoff = 1 if mobileLayout()
	$('.bundle .ruling').tooltip('destroy')

	#remove the old crap when it's really old (and turdy)
	$('.bundle:not(.bookmarked)').slice(cutoff).slideUp 'normal', -> 
			$(this).remove()
	old = $('#history .bundle').first()
	# old.find('.answer').css('visibility', 'visible')
	old.removeClass 'active'
	old.find('.breadcrumb').click -> 1 # register a empty event handler so touch devices recognize
	#merge the text nodes, perhaps for performance reasons
	bundle = createBundle().width($('#history').width()) #.css('display', 'none')
	bundle.addClass 'active'


	$('#history').prepend bundle.hide()
	# updateTextPosition()
	updateInlineSymbols()

	bundle.slideDown("normal").queue ->
		bundle.width('auto')
		$(this).dequeue()
	if old.find('.readout').length > 0
		nested = old.find('.readout .well>span')
		old.find('.readout .well').append nested.contents()
		nested.remove()

		old.find('.readout')[0].normalize()

		old.queue ->
			old.find('.readout').slideUp("normal")
			$(this).dequeue()

createBundle = ->
	bundle = $('<div>').addClass('bundle').attr('name', room.qid).addClass('room-'+room.name?.replace(/[^a-z0-9]/g, ''))
	important = $('<div>').addClass 'important'
	bundle.append(important)
	breadcrumb = $('<ul>')

	star = $('<a>', {
		href: "#",
		rel: "tooltip",
		title: "Bookmark this question"
	})
		.addClass('icon-star-empty bookmark')
		.click (e) ->
			# whoever is reading this:
			# if you decide to add a server-side notion of saved questions
			# here is wher eyou shove it
			bundle.toggleClass 'bookmarked'
			star.toggleClass 'icon-star-empty', !bundle.hasClass 'bookmarked'
			star.toggleClass 'icon-star', bundle.hasClass 'bookmarked'
			e.stopPropagation()
			e.preventDefault()

	breadcrumb.append $('<li>').addClass('pull-right').append(star)

	addInfo = (name, value) ->
		breadcrumb.find('li:not(.pull-right)').last().append $('<span>').addClass('divider').text('/')
		if value
			name += ": " + value
		el = $('<li>').text(name).appendTo(breadcrumb)
		if value
			el.addClass('hidden-phone')
		else
			el.addClass('visible-phone')

	if (me.id + '').slice(0, 2) is "__"
		addInfo 'Room', room.name
	
	addInfo 'Category', room.info.category
	addInfo 'Difficulty', room.info.difficulty
	addInfo 'Tournament', room.info.year + ' ' + room.info.tournament

	addInfo room.info.year + ' ' + room.info.difficulty + ' ' + room.info.category
	# addInfo 'Year', room.info.year
	# addInfo 'Number', room.info.num
	# addInfo 'Round', room.info.round
	# addInfo 'Report', ''

	breadcrumb.find('li').last().append $('<span>').addClass('divider hidden-phone').text('/')
	bundle.data 'report_info', {
		year: room.info.year, 
		difficulty: room.info.difficulty, 
		category: room.info.category, 
		tournament: room.info.tournament,
		round: room.info.round,
		num: room.info.num,
		qid: room.qid,
		question: room.question,
		answer: room.answer
	}
	breadcrumb.append $('<li>').addClass('clickable hidden-phone').text('Report').click (e) ->
		# console.log 'report question'
		# $('#report-question').modal('show')
		info = bundle.data 'report_info'

		div = $("<div>").addClass("alert alert-block alert-info")
			.insertBefore(bundle.find(".annotations")).hide()
		div.append $("<button>")
			.attr("data-dismiss", "alert")
			.attr("type", "button")
			.html("&times;")
			.addClass("close")
		div.append $("<h4>").text "Report Question"
		form = $("<form>")
		form.addClass('form-horizontal').appendTo div
		rtype = $('<div>').addClass('control-group').appendTo(form)
		rtype.append $("<label>").addClass('control-label').text('Description')
		controls = $("<div>").addClass('controls').appendTo rtype
		for option in ["Wrong category", "Wrong details", "Bad question", "Broken formatting"]
			controls.append $("<label>")
				.addClass("radio")
				.append($("<input type=radio name=description>").val(option.split(" ")[1].toLowerCase()))
				.append(option)

		form.find(":radio").change ->
			if form.find(":radio:checked").val() is 'category'
				ctype.slideDown()
			else
				ctype.slideUp()
		
		ctype = $('<div>').addClass('control-group').appendTo(form)
		ctype.append $("<label>").addClass('control-label').text('Category')
		cat_list = $('<select>')
		ctype.append $("<div>").addClass('controls').append cat_list
		
		controls.find('input:radio')[0].checked = true

		cat_list.append new Option(cat) for cat in room.categories
		cat_list.val(info.category)
		stype = $('<div>').addClass('control-group').appendTo(form)

		$("<div>").addClass('controls').appendTo(stype)
			.append($('<button type=submit>').addClass('btn btn-primary').text('Submit'))

		$(form).submit ->
			describe = form.find(":radio:checked").val()
			if describe is 'category'
				info.fixed_category = cat_list.val()
			info.describe = describe
			sock.emit 'report_question', info
			
			createAlert bundle, 'Reported Question', 'You have successfully reported a question. It will be reviewed and the database may be updated to fix the problem. Thanks.'
			div.slideUp()
			return false
		div.slideDown()

		# createAlert bundle, 'Reported Question', 'You have successfully reported a question. It will be reviewed and the database may be updated to fix the problem. Thanks.'
		# sock.emit 'report_question', bundle.data 'report_info'

		e.stopPropagation()
		e.preventDefault()


	breadcrumb.append $('<li>').addClass('pull-right answer').text(room.answer)

	readout = $('<div>').addClass('readout')
	well = $('<div>').addClass('well').appendTo(readout)
	# well.append $('<span>').addClass('visible')
	# well.append document.createTextNode(' ') #space: the frontier in between visible and unread
	well.append $('<span>').addClass('unread').text(room.question)
	annotations = $('<div>').addClass 'annotations'
	bundle
		.append($('<ul>').addClass('breadcrumb').append(breadcrumb))
		.append(readout)
		.append(annotations)


reader_children = null
reader_last_state = -1

updateTextPosition = ->
	return unless room.question and room.timing

	timeDelta = room.time() - room.begin_time
	start_index = Math.max(0, reader_last_state)
	index = start_index
	index++ while timeDelta > room.cumulative[index]

	for word_index in [start_index...index]
		reader_children[word_index].className = ''
		# console.log reader_children[word_index]

	reader_last_state = index - 1
	# console.log index
	# bundle = $('#history .bundle.active') 
	# readout = bundle.find('.readout .well')
	# children = readout.children()

	# words = room.question.split ' '
	# if children.length != words.length
	# 	console.error('incorrect size')	

	# children.slice(0, index).removeClass('unread')
	# children.slice(index).addClass('unread')



updateInlineSymbols = ->
	return unless room.question and room.timing
	console.log 'update inline symbols'

	words = room.question.split ' '
	early_index = room.question.replace(/[^ \*]/g, '').indexOf('*')
	bundle = $('#history .bundle.active') 

	spots = bundle.data('starts') || []

	readout = bundle.find('.readout .well')
	readout.data('spots', spots.join(','))

	children = readout.children()
	# children.slice(words.length).remove()

	elements = []
	
	for i in [0...words.length]
		element = $('<span>').addClass('unread')

		if words[i].indexOf('*') isnt -1
			element.append " <span class='inline-icon'><span class='asterisk'>"+words[i]+"</span><i class='label icon-white icon-asterisk'></i></span> "
		else
			element.append(words[i] + " ")

		if i in spots
			# element.append('<span class="label label-important">'+words[i]+'</span> ')
			label_type = 'label-important'
			# console.log spots, i, words.length
			if i is words.length - 1
				label_type = "label-info"
			if early_index != -1 and i < early_index
				label_type = "label"

			element.append " <span class='inline-icon'><i class='label icon-white icon-bell  #{label_type}'></i></span> "

		elements.push element

	for i in [0...words.length]
		unless children.eq(i).html() is elements[i].html()
			if children.eq(i).length > 0
				children.eq(i).replaceWith(elements[i])
			else
				readout.append elements[i]

	reader_children = readout[0].childNodes
	reader_last_state = -1

	updateTextPosition()
