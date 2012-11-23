render_categories = ->
	$('.custom-category').empty()
	return unless room.distribution
	
	s = 0; s += val for cat, val of room.distribution

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


$('.dist-picker .increase').live 'click', (e) ->
	return unless room.distribution
	item = $(this).parents('.category-item')
	obj = clone_shallow(room.distribution)
	obj[$(item).data('value')]++
	me.set_distribution obj

$('.dist-picker .decrease').live 'click', (e) ->
	return unless room.distribution
	item = $(this).parents('.category-item')
	s = 0
	s += val for cat, val of room.distribution
	obj = clone_shallow(room.distribution)
	if obj[$(item).data('value')] > 0 and s > 1
		obj[$(item).data('value')]--
		me.set_distribution obj


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
		
	render_categories()

renderUpdate = ->
	if room.category is 'custom'
		render_categories()
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
		$('.lock').attr 'checked', room.users[me.id].lock
		$('.teams').val room.users[me.id].team

		if me.guesses > 0
			$('.reset-score').slideDown()
		else
			$('.reset-score').slideUp()

		if room.admins and me.id in room.admins
			$('.relinquish-command').slideDown()
		else
			$('.relinquish-command').slideUp()

		count = (1 for u of room.users).length
		if count > 1
			$('.set-team').slideDown()
		else
			$('.set-team').slideUp()

	if me.id and me.id[0] is '_'
		$('a.brand').attr('href', '/stalkermode')
		$('div.navbar-inner').css('background', 'rgb(224, 235, 225)')
		$('.motto').text('omg did you know im a ninja?')

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

	if time >= room.end_time
		# $('.progress').addClass 'progress-info'
		if $(".nextbtn").is(":hidden")
			$('.nextbtn').show() 
			$('.skipbtn').hide() 
	else
		# $('.progress').removeClass 'progress-info'
		if !$(".nextbtn").is(":hidden")
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


get_score = (user) -> 
	if user.members
		return Sum(get_score(member) for member in user.members)
	else	
		if me.movingwindow
			user.score() - [0].concat(user.history).slice(-me.movingwindow)[0]
			# basis = user.history.concat [user.score()]
			# basis[basis.length - 1]
		else
			# nice and simple; use the actual scores
			user.score()

renderUsers = ->
	# render the user list and that stuff
	return unless room.users

	teams = {}
	team_hash = ''

	name_map = {}

	for id, user of room.users
		name_map[user.name] = [] unless name_map[user.name]
		name_map[user.name].push(id)

	for name, ids of name_map
		if ids.length > 1
			sorted = ids.sort (a, b) -> room.users[a].last_session - room.users[b].last_session
			for num in [0...sorted.length]
				room.users[sorted[num]]._suffix = "##{num + 1}"
		else
			delete room.users[ids[0]]._suffix

	for id, user of room.users

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

	lock_votes = 0
	lock_electorate = 0
	for id, user of room.users when user.active()
		if user.active()
			lock_electorate++
			if user.lock
				lock_votes++
	if lock_electorate <= 2
		$('.lockvote').slideUp()

		$('.globalsettings .checkbox, .globalsettings .expando')
				.css('opacity', '1')
				.find('select, input')
				.disable(false)
	else
		$('.lockvote').slideDown()
		needed = Math.floor(lock_electorate / 2 + 1)
		if lock_votes < needed
			$('.lockvote .electorate').text "#{needed-lock_votes} needed"
		else
			$('.lockvote .electorate').text "#{lock_votes}/#{lock_electorate} votes"
		$('.lockvote .status_icon').removeClass('icon-lock icon-unlock')
		if lock_votes >= needed
			$('.lockvote .status_icon').addClass('icon-lock')
			$('.globalsettings .checkbox, .globalsettings .expando')
				.css('opacity', '0.5')
				.find('select, input')
				.disable(true)
		else
			$('.lockvote .status_icon').addClass('icon-unlock')

			$('.globalsettings .checkbox, .globalsettings .expando')
				.css('opacity', '1')
				.find('select, input')
				.disable(false)

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

			# attrs = new QuizPlayer(room, 't-' + team.toLowerCase().replace(/[^a-z0-9]/g, ''))
			attrs = {room: room} #new Team(room)
			team_count++
			# for member in members
			# 	for attr, val of room.users[member]
			# 		if typeof val is 'number'
			# 			attrs[attr] = 0 unless attr of attrs
			# 			attrs[attr] += val

			attrs.members = (room.users[member] for member in members)
			
			attrs.name = team
			attrs
			
		for id, user of room.users when !user.team 
			entities.push user # add all the unaffiliated users

	list.empty()

	get_weight = (user) ->
		# make the user's age a tiny factor, so that the ordering is
		# at least consistent for all users, regardless of whether or
		# not they actually have the same score
		return get_score(user) + (room.serverTime() - user.created) / 1e15 

	for user, user_index in entities.sort((a, b) -> get_weight(b) - get_weight(a))
		# if the score is worse, increment ranks
		ranking++ if entities[user_index - 1] and get_score(user) < get_score(entities[user_index - 1])
		row = $('<tr>').data('entity', user).appendTo list
		row.click -> 1
		badge = $('<span>').addClass('badge pull-right').text get_score(user)
		if me.id in (user.members || [user.id])
			badge.addClass('badge-info').attr('title', 'You')
		else
			idle_count = 0
			active_count = 0
			for member in (user.members || [user.id])
				if member.online()
					if member.active()
						active_count++
					else
						idle_count++
						
			if active_count > 0
				badge.addClass('badge-success').attr('title', 'Online')
			else if idle_count > 0
				badge.addClass('badge-warning').attr('title', 'Idle')
		
		$('<td>').addClass('rank').append(badge).append(ranking).appendTo row
		name = $('<td>').appendTo row
		
		$('<td>').text(user.interrupts).appendTo row
		if !user.members #user.members.length is 1 and !users[user.members[0]].team # that's not a team! that's a person!
			name.append($('<span>').append(userSpan(user.id))) #.css('font-weight', 'bold'))
		else
			name.append($('<span>').text(user.name).css('font-weight', 'bold')).append(" (#{user.members.length})")
		
			for user in user.members.sort((a, b) -> get_weight(b) - get_weight(a))
				# user = room.users[member]
				row = $('<tr>').addClass('subordinate').data('entity', user).appendTo list
				row.click -> 1
				badge = $('<span>').addClass('badge pull-right').text get_score(user)
				if user.id is me.id
					badge.addClass('badge-info').attr('title', 'You')
				else
					if user.online()
						if room.serverTime() - user.last_action > 1000 * 60 * 10
							badge.addClass('badge-warning').attr('title', 'Idle')
						else
							badge.addClass('badge-success').attr('title', 'Online')

				$('<td>').css("border", 0).append(badge).appendTo row
				name = $('<td>').append(userSpan(user.id))
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
	check_alone() # ~ 1 msec
	

check_alone = ->
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

createStatSheet = (entity, full) ->
	if entity.members
		return createTeamStatSheet(entity, full)
	else
		return createUserStatSheet(entity, full)

createUserStatSheet = (user, full) ->
	table = $('<table>').addClass('table headless')
	body = $('<tbody>').appendTo(table)
	row = (name, val) ->
		$('<tr>')
			.appendTo(body)
			.append($("<th>").text(name))
			.append($("<td>").addClass("value").append(val))
	
	row	"Score", $('<span>').addClass('badge').text(get_score(user))
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

createTeamStatSheet = (team, full) ->
	table = $('<table>').addClass('table headless')
	body = $('<tbody>').appendTo(table)
	row = (name, val) ->
		$('<tr>')
			.appendTo(body)
			.append($("<th>").text(name))
			.append($("<td>").addClass("value").append(val))
	
	row	"Score", $('<span>').addClass('badge').text(get_score(team))
	row	"Correct", Sum(user.correct for user in team.members)
	row "Interrupts", Sum(user.interrupts for user in team.members)
	row "Early", Sum(user.early for user in team.members) if full
	# row "Incorrect", team.guesses - team.correct  if full
	row "Guesses", Sum(user.guesses for user in team.members)
	# row "Seen", team.seen
	
	row "Members", team.members.length

	# row "ID", team.id.slice(0, 10) if full
	# row "Last Seen", formatRelativeTime(team.last_action) if full
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
	
	$('.bundle').removeClass 'active'

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



toggle_bookmark = (info, state) ->
	me.bookmark { id: info.qid, value: state}
	bookmarks = []
	try
		bookmarks = JSON.parse(localStorage.bookmarks)

	# remove bookmark; even if being set on to reload data
	bookmarks = (b for b in bookmarks when b.qid isnt info.qid)

	
	if state is true
		# create bookmark
		bookmarks.push info

	localStorage.bookmarks = JSON.stringify(bookmarks)


create_report_form = (info) ->
	div = $("<div>").addClass("alert alert-block alert-info report-form")
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
		
		createAlert div.parent(), 'Reported Question', 'You have successfully reported a question. It will be reviewed and the database may be updated to fix the problem. Thanks.'
		div.slideUp 'normal', ->
			$(this).remove()

		return false
	return div


create_bundle = (info) ->
	bundle = $('<div>').addClass('bundle')
		.addClass("qid-#{info.qid}")
		.attr('name', 'question-' + sha1(room.generated_time + info.question))
		.addClass('room-'+room.name?.replace(/[^a-z0-9]/g, ''))

	breadcrumb = $('<ul>')
	star = $('<a>', {
		href: "#",
		rel: "tooltip",
		title: "Bookmark this question"
	})
		.addClass('bookmark')
		.click (e) ->
			e.stopPropagation()
			e.preventDefault()
			info.bookmarked = !info.bookmarked
			bundle.toggleClass 'bookmarked', info.bookmarked
			
			$(".qid-#{info.qid} .bookmark")
				.toggleClass('icon-star-empty', !info.bookmarked)
				.toggleClass('icon-star', info.bookmarked)
			
			toggle_bookmark info, info.bookmarked

	star.toggleClass 'icon-star-empty', !info.bookmarked
	star.toggleClass 'icon-star', info.bookmarked

	breadcrumb.append $('<li>').addClass('pull-right').append(star)

	field = (name, value) ->
		breadcrumb.find('li:not(.pull-right)').last().append $('<span>').addClass('divider').text('/')
		if value
			name += ": " + value
		el = $('<li>').text(name).appendTo(breadcrumb)
		if value
			el.addClass('hidden-phone')
		else
			el.addClass('visible-phone')

	field 'Room', info.name if /stalker/.test(room.name)
	field 'Category', info.category
	field 'Difficulty', info.difficulty
	if info.tournament and info.year
		field 'Tournament', info.year + ' ' + info.tournament
	else if info.year
		field 'Year', info.year
	else if info.tournament
		field 'Tournament', info.tournament
	field info.year + ' ' + info.difficulty + ' ' + info.category

	breadcrumb.find('li').last().append $('<span>').addClass('divider hidden-phone').text('/')

	breadcrumb.append $('<li>').addClass('clickable hidden-phone').text('Report').click (e) ->
		unless bundle.find('.report-form').length > 0
			create_report_form(info).insertBefore(bundle.find(".annotations")).hide().slideDown()
		e.stopPropagation()
		e.preventDefault()

	breadcrumb.append $('<li>').addClass('pull-right answer').text(info.answer)
	readout = $('<div>').addClass('readout')
	well = $('<div>').addClass('well').appendTo(readout)
	well.append $('<span>').addClass('unread').text(info.question)
	bundle
		.append($('<ul>').addClass('breadcrumb').append(breadcrumb))
		.append(readout)
		.append($('<div>').addClass('sticky'))
		.append($('<div>').addClass('annotations'))


createBundle = ->
	create_bundle {
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


reader_children = null
reader_last_state = -1

updateTextPosition = ->
	return unless room.question and room.timing

	timeDelta = room.time() - room.begin_time
	start_index = Math.max(0, reader_last_state)
	index = start_index
	index++ while timeDelta > room.cumulative[index]

	if start_index > index
		for word_index in [index...start_index]		
			reader_children[word_index].className = 'unread'

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
		if children.eq(i).html() is elements[i].html()
			children.eq(i).addClass('unread')
		else
			if children.eq(i).length > 0
				children.eq(i).replaceWith(elements[i])
			else
				readout.append elements[i]

	reader_children = readout[0].childNodes
	reader_last_state = -1

	updateTextPosition()
