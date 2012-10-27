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
		createCategoryList()
		$('.custom-category').slideDown()
	else
		$('.custom-category').slideUp()

	$('.categories').val room.category
	$('.difficulties').val room.difficulty
	$('.multibuzz').attr 'checked', !room.max_buzz
	$('.allowskip').attr 'checked', !room.no_skip

	if $('.settings').is(':hidden')
		$('.settings').slideDown()
		$(window).resize()

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


last_rendering = 0
# last_question = ''

renderPartial = ->
	if (!room.time_freeze or room.attempt) and room.time() < room.end_time
		requestAnimationFrame(renderPartial)
		# setTimeout renderPartial, 1000 / 30
		return if new Date - last_rendering < 1000 / 20

	last_rendering = +new Date
	
	if !room.question 
		if $('.start-page').length is 0
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

		if $('#history .bundle[name="question-' + sha1(room.generated_time + room.question) + '"]').length is 0
			changeQuestion()
	
	updateTextPosition()

	# #render the time
	renderTimer()


renderTimer = ->
	# $('#pause').show !!room.time_freeze
	# $('.buzzbtn').attr 'disabled', !!room.attempt
	if room.end_time and room.begin_time
		$('.timer').removeClass 'disabled'
	else
		$('.timer').addClass 'disabled'
		
	time = Math.max(room.begin_time, room.time())

	if connected()
		$('.offline').fadeOut()
	else
		$('.offline').fadeIn()

	if room.time_freeze
		$('.buzzbtn').disable true

		if room.attempt
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
	
	# if time >= room.end_time
	# 	$('.label.finished').fadeIn()
	# else
	# 	$('.label.finished').hide()

	if time > room.end_time - room.answer_duration
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
		ms = room.end_time - time
		elapsed = (time - room.begin_time)
		progress = elapsed/(room.end_time - room.begin_time)
		$('.skipbtn, .nextbtn').disable false
		$('.pausebtn').disable (ms < 0)
		unless room.time_freeze
			$('.buzzbtn').disable (ms < 0 or elapsed < 100)
		if ms < 0
			$('.bundle.active').addClass('revealed')
			# .find('.answer')
			# .css('display', 'inline')
			# .css('visibility', 'visible')
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

	if room.no_skip
		$('.skipbtn').disable true

	ms = Math.max(0, ms) # force time into positive range, comment this out to show negones
	sign = ""
	sign = "+" if ms < 0
	sec = Math.abs(ms) / 1000

	if isNaN(sec)
		$('.timer .face').text('00:00')
		$('.timer .fraction').text('.0')
	else
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
	# render the user list and that stuff
	return unless room.users

	teams = {}
	team_hash = ''
	for id, user of room.users
		# votes = []
		# for action of room.voting
		# 	if user.id in room.voting[action]
		# 		votes.push action
		# user.votes = votes.join(', ')
		# user.room = room.name
		# users[user.id] = user
		if user.team
			teams['t-' + user.team] = [] unless 't-' + user.team of teams
			teams['t-' + user.team].push user.id
			team_hash += user.team + user.id
		
		userSpan(user.id, true) # do a global update!
		
		if user.tribunal
			boxxyAnnotation user
		else
			$('.troll-'+user.id).slideUp 'normal', ->
				$(this).remove()

		# user.name + " (" + user.id + ") " + votes.join(", ")
	
	if $('.teams').data('teamhash') isnt team_hash
		$('.teams').data('teamhash', team_hash)
		$('.teams').empty()
		$('.teams')[0].options.add new Option('Individual', '')
		for team, members of teams
			team = team.slice(2)
			$('.teams')[0].options.add new Option("#{team} (#{members.length})", team)
		$('.teams')[0].options.add new Option('Create Team', 'create')
		if me.id of room.users
			$('.teams').val(room.users[me.id].team)
	
	#console.time('draw board')
	list = $('.leaderboard tbody')
	# list.find('tr').remove() #abort all people
	ranking = 1
	
	entities = (user for id, user of room.users)
	user_count = entities.length

	team_count = 0
	if $('.teams').val() or me.id.slice(0,2) == "__"
		entities = for team, members of teams
			team = team.slice(2)

			attrs = new QuizPlayer(room, 't-' + team.toLowerCase().replace(/[^a-z0-9]/g, ''))
			team_count++
			for member in members
				for attr, val of room.users[member]
					if typeof val is 'number'
						attrs[attr] = 0 unless attr of attrs
						attrs[attr] += val

			attrs.members = members
			
			attrs.name = team
			attrs
			
		for id, user of room.users when !user.team 
			entities.push user # add all the unaffiliated users

	list.empty()
	for user, user_index in entities.sort((a, b) -> b.score() - a.score())
		# if the score is worse, increment ranks
		ranking++ if entities[user_index - 1] and user.score() < entities[user_index - 1].score()
		row = $('<tr>').data('entity', user).appendTo list
		row.click -> 1
		badge = $('<span>').addClass('badge pull-right').text user.score()
		if me.id in (user.members || [user.id])
			badge.addClass('badge-info').attr('title', 'You')
		else
			idle_count = 0
			active_count = 0
			for member in (user.members || [user.id])
				if room.users[member].online()
					if room.serverTime() - room.users[member].last_action > 1000 * 60 * 10
						idle_count++
					else
						active_count++
			if active_count > 0
				badge.addClass('badge-success').attr('title', 'Online')
			else if idle_count > 0
				badge.addClass('badge-warning').attr('title', 'Idle')
		
		$('<td>').addClass('rank').append(badge).append(ranking).appendTo row
		name = $('<td>').appendTo row
		
		$('<td>').text(user.interrupts).appendTo row
		if !user.members #user.members.length is 1 and !users[user.members[0]].team # that's not a team! that's a person!
			name.append($('<span>').text(user.name)) #.css('font-weight', 'bold'))
		else
			name.append($('<span>').text(user.name).css('font-weight', 'bold')).append(" (#{user.members.length})")
		
			for member in user.members.sort((a, b) -> room.users[b].score() - room.users[a].score())
				user = room.users[member]
				row = $('<tr>').addClass('subordinate').data('entity', user).appendTo list
				row.click -> 1
				badge = $('<span>').addClass('badge pull-right').text(user.score())
				if user.id is me.id
					badge.addClass('badge-info').attr('title', 'You')
				else
					if user.online()
						if room.serverTime() - user.last_action > 1000 * 60 * 10
							badge.addClass('badge-warning').attr('title', 'Idle')
						else
							badge.addClass('badge-success').attr('title', 'Online')

				$('<td>').css("border", 0).append(badge).appendTo row
				name = $('<td>').text(user.name)
				name.appendTo row
				$('<td>').text(user.interrupts).appendTo row

	#console.timeEnd('draw board')
	# this if clause is ~5msecs
	# console.log entities, room.users, me.id
	if user_count > 1 and connected()
		if $('.leaderboard').is(':hidden')
			$('.leaderboard').slideDown()
			$('.singleuser').slideUp()
	else if room.users[me.id]
		$('.singleuser .stats table').replaceWith(createStatSheet(room.users[me.id], !!$('.singleuser').data('full')))
		if $('.singleuser').is(':hidden')
			$('.leaderboard').slideUp()
			$('.singleuser').slideDown()
	# turns out doing this resize is like the slowest part!
	# console.time('resize')
	# $(window).resize() #fix all the expandos
	# console.timeEnd('resize')
	checkAlone() # ~ 1 msec
	

checkAlone = ->
	return unless connected()
	active_count = 0
	for id, user of room.users
		if user.online() and room.serverTime() - user.last_action < 1000 * 60 * 10
			active_count++
	
	if active_count is 1
		me.check_public '', (data) ->
			suggested_candidates = []
			for can, count of data
				if count > 0 and can isnt room.name
					suggested_candidates.push can
			if suggested_candidates.length > 0
				links = (can.link("/" + can) + " (#{data[can]}) " for can in suggested_candidates)
				$('.foreveralone .roomlist').html links.join(' or ')
				$('.foreveralone').slideDown()
			else
				$('.foreveralone').slideUp()
	else
		$('.foreveralone').slideUp()

createStatSheet = (user, full) ->
	table = $('<table>').addClass('table headless')
	body = $('<tbody>').appendTo(table)
	row = (name, val) ->
		$('<tr>')
			.appendTo(body)
			.append($("<th>").text(name))
			.append($("<td>").addClass("value").append(val))
	
	row	"Score", $('<span>').addClass('badge').text(user.score())
	row	"Correct", user.correct
	row "Interrupts", user.interrupts
	row "Early", user.early  if full
	row "Incorrect", user.guesses - user.correct  if full
	row "Guesses", user.guesses 
	row "Seen", user.seen
	row "Team", user.team if user.team
	row "ID", user.id.slice(0, 10) if full
	row "Last Seen", formatRelativeTime(user.last_action) if full
	return table


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
	bundle = $('<div>')
		.addClass('bundle')
		.attr('name', 'question-' + sha1(room.generated_time + room.question))
		.addClass('room-'+room.name?.replace(/[^a-z0-9]/g, ''))
	# important = $('<div>').addClass 'important'
	# bundle.append(important)
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
			info = bundle.data 'report_info'

			bundle.toggleClass 'bookmarked'
			star.toggleClass 'icon-star-empty', !bundle.hasClass 'bookmarked'
			star.toggleClass 'icon-star', bundle.hasClass 'bookmarked'
			me.bookmark { id: info.qid, value: bundle.hasClass 'bookmarked' }
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
	if room.info.tournament and room.info.year
		addInfo 'Tournament', room.info.year + ' ' + room.info.tournament
	else if room.info.year
		addInfo 'Year', room.info.year
	else if room.info.tournament
		addInfo 'Tournament', room.info.tournament
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
		for option in ["Wrong category", "Wrong details", "Broken question"]
			controls.append $("<label>")
				.addClass("radio")
				.append($("<input type=radio name=description>").val(option.split(" ")[1].toLowerCase()))
				.append(option)

		submit_btn = $('<button type=submit>').addClass('btn btn-primary').text('Submit')

		form.find(":radio").change ->
			if form.find(":radio:checked").val() is 'category'
				ctype.slideDown()
			else
				ctype.slideUp()
				submit_btn.disable(false)
		
		ctype = $('<div>').addClass('control-group').appendTo(form)
		ctype.append $("<label>").addClass('control-label').text('Category')
		cat_list = $('<select>')
		ctype.append $("<div>").addClass('controls').append cat_list
		
		controls.find('input:radio')[0].checked = true

		cat_list.append new Option(cat) for cat in room.categories
		$(cat_list).change ->
			submit_btn.disable(cat_list.val() is info.category)

		cat_list.val(info.category)
		$(cat_list).change()
		
		stype = $('<div>').addClass('control-group').appendTo(form)
		cancel_btn = $('<button>').addClass('btn').text('Cancel').click (e) ->
			div.slideUp 'normal', ->
				$(this).remove()
			e.stopPropagation()
			e.preventDefault()

		$("<div>").addClass('controls').appendTo(stype)
			.append(submit_btn)
			.append(' ')
			.append(cancel_btn)

		$(form).submit ->
			describe = form.find(":radio:checked").val()
			if describe is 'category'
				info.fixed_category = cat_list.val()
			info.describe = describe
			me.report_question info
			
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
	bundle
		.append($('<ul>').addClass('breadcrumb').append(breadcrumb))
		.append(readout)
		.append($('<div>').addClass('sticky'))
		.append($('<div>').addClass('annotations'))


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
	# console.log 'update inline symbols'

	words = room.question.split ' '
	early_index = room.question.replace(/[^ \*]/g, '').indexOf('*')
	bundle = $('#history .bundle.active') 

	spots = bundle.data('starts') || []
	stops = bundle.data('stops') || []

	readout = bundle.find('.readout .well')
	
	return if readout.length is 0

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
		else if i in stops
			element.append " <span class='inline-icon'><i class='label icon-white icon-pause label-warning'></i></span> "

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
