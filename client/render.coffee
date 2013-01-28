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

	if room.topic
		$('.topic .thumbnail').html(room.topic)
		$('.topic').slideDown()
	else
		$('.topic').slideUp()

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
	
	$('.bundle.active').toggleClass 'semi', room.semi

	if me.id of room.users and 'show_typing' of room.users[me.id]
		$('.livechat').attr 'checked', room.users[me.id].show_typing
		$('.sounds').attr 'checked', room.users[me.id].sounds
		$('.lock').attr 'checked', room.users[me.id].lock
		$('.teams').val room.users[me.id].team

		$('.microwave').toggle !room.users[me.id].muwave

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

		info = $('#history .bundle:first').data('info')
		if info?.generated_time != room?.generated_time or room?.question != info?.question
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
		$('.offline-badge').capQueue().fadeOut()
	else
		$('.offline-badge').capQueue().fadeIn()
	
	
	$('.chatbtn').disable(room.mute and me.id[0] != '_')

	if room.time_freeze
		$('.buzzbtn').disable true

		if room.attempt
			$('.label.pause').hide()
			$('.label.buzz').capQueue().fadeIn()

		else
			$('.label.pause').capQueue().fadeIn()
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
		$('.label.pause').capQueue().fadeOut()
		$('.label.buzz').capQueue().fadeOut()
		if $('.pausebtn').hasClass('btn-success')
			$('.pausebtn .resume').hide()
			$('.pausebtn .pause').show()
			$('.pausebtn')
			.addClass('btn-warning')
			.removeClass('btn-success')
	
	if time >= room.end_time and !room.time_freeze
		$('.label.finished').capQueue().fadeIn()
	else
		$('.label.finished').capQueue().fadeOut()

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
		$('.pausebtn').disable (ms < 0 or room.no_pause)

		unless room.time_freeze
			if !room.interrupts and time < room.end_time - room.answer_duration
				$('.buzzbtn').disable true
			else
				$('.buzzbtn').disable (ms < 0 or elapsed < 100)
		if ms < 0
			$('.bundle.active').addClass('revealed')
			update_visibility()

			ruling = $('.bundle.active').find('.ruling')

			unless ruling.data('shown_tooltip')
				ruling.data('shown_tooltip', true)

				el = $('.bundle.active').find('.ruling').first()
					.tooltip({
						trigger: "manual"
					})
				
				el.tooltip('show')
				
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
	return 0 unless user
	score = 0
	if user.members
		score = Sum(get_score(member) for member in user.members)
	else	
		if me.movingwindow
			score = user.score() - [0].concat(user.history).slice(-me.movingwindow)[0]
			# basis = user.history.concat [user.score()]
			# basis[basis.length - 1]
		else
			# nice and simple; use the actual scores
			score = user.score()
	
	if score is 1335
		return 1337
	else
		return score


render_lock = ->
	lock_votes = 0
	lock_electorate = 0

	for id, user of room.users when user.active()
		if user.active()
			lock_electorate++
			if user.lock
				lock_votes++
	needed = Math.floor(lock_electorate / 2 + 1)

	if lock_electorate <= 2 or room.no_escalate
		$('.lockvote').slideUp()
		
	else
		$('.lockvote').slideDown()
		
		if lock_votes < needed
			$('.lockvote .electorate').text "#{needed-lock_votes} needed"
		else
			$('.lockvote .electorate').text "#{lock_votes}/#{lock_electorate} votes"
		
	$('.lockvote .status_icon').removeClass('icon-lock icon-unlock icon-flag')
	
	$('.request-access button').disable !!me.elect

	$('.globalsettings').toggleClass('escalate', !room.no_escalate)

	if room.locked()
		if me.authorized()
			# woo ima adminiman
			$('.lockvote .status_icon').addClass('icon-flag')
			$('.globalsettings').removeClass('locked')	
			$('.globalsettings .checkbox, .globalsettings .expando')
				.find('select, input')
				.disable(false)
					
		else		
			$('.lockvote .status_icon').addClass('icon-lock')
			$('.globalsettings').addClass('locked')
			$('.globalsettings .checkbox, .globalsettings .expando')
				.find('select, input')
				.disable(true)
	else
		$('.lockvote .status_icon').addClass('icon-unlock')
		$('.globalsettings').removeClass('locked')
		$('.globalsettings .checkbox, .globalsettings .expando')
			.find('select, input')
			.disable(false)

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
			if user.elect
				congressionalAnnotation user
			else
				$('.elect-'+user.id).slideUp 'normal', ->
					$(this).remove()

	render_lock()

	if $('.teams').data('teamhash') isnt team_hash
		$('.teams').data('teamhash', team_hash)
		$('.teams').empty()
		$('.teams')[0].options.add new Option('Individual', '')
		for team, members of teams
			team = team.slice(2)
			$('.teams')[0].options.add new Option("#{team} (#{members.length})", team)
		$('.teams')[0].options.add new Option('Create Team', '__create')
		
		if me.id of room.users
			$('.teams').val(room.users[me.id].team)
	
	#console.time('draw board')
	list = $('.leaderboard tbody')
	# list.find('tr').remove() #abort all people


	get_weight = (user) ->
		# make the user's age a tiny factor, so that the ordering is
		# at least consistent for all users, regardless of whether or
		# not they actually have the same score
		creation = user.created || user.members[0].created
		return get_score(user) + (room.serverTime() - creation) / 1e15 
		
	
	entities = (user for id, user of room.users)

	user_count = entities.length

	team_count = 0
	if $('.teams').val() or me.id.slice(0,2) == "__"
		entities = for team, members of teams
			team = team.slice(2)

			attrs = {room: room} #new Team(room)
			team_count++

			attrs.members = (room.users[member] for member in members)
			attrs.interrupts = Sum(u.interrupts for u in attrs.members)
			
			attrs.name = team
			attrs.id = 'team-' + escape(team).toLowerCase().replace(/[^a-z0-9]/g, '')

			attrs
			
		for id, user of room.users when !user.team 
			entities.push user # add all the unaffiliated users

	entities = entities.sort((a, b) -> get_weight(b) - get_weight(a))

	ranking = 1
	me_entity = null

	for user, user_index in entities
		# if the score is worse, increment ranks
		ranking++ if entities[user_index - 1] and get_score(user) < get_score(entities[user_index - 1])
		user.rank = ranking
		user.position = user_index
		if !me_entity and room.users[me.id] in (user.members || [user])
			me_entity = user

	# list.empty()

	list.find('.refreshed').removeClass('refreshed')

	create_row = (user, subordinate = false) ->
		return unless user
		existing = $(".row-#{user.id}")
		
		if existing.length > 0
			row = existing.first().empty()
		else
			row = $('<tr>').addClass('row-' + user.id)
		
		row
			.addClass('refreshed')
			.data('entity', user)
			.appendTo(list)
			.click( -> 1 ) # iOS devices dont allow things to be clickable unless an event handler is there

		badge = $('<span>').addClass('badge pull-right').text get_score(user)
		if room.users[me.id] in (user.members || [user])
			badge.addClass('badge-info').attr('title', 'You')
		else
			idle_count = 0
			active_count = 0
			for member in (user.members || [user])
				if member.online()
					if member.active()
						active_count++
					else
						idle_count++
						
			if active_count > 0
				badge.addClass('badge-success').attr('title', 'Online')
			else if idle_count > 0
				badge.addClass('badge-warning').attr('title', 'Idle')
		if subordinate
			row.addClass('subordinate')
			$('<td>').addClass('rank').appendTo(row)
		else
			$('<td>').addClass('rank').append(user.rank).appendTo(row)
		$('<td>').addClass('score').append(badge).appendTo(row)

		name = $('<td>').appendTo row

		$('<td>').addClass('negs').text(user.interrupts).appendTo row

		if !user.members #user.members.length is 1 and !users[user.members[0]].team # that's not a team! that's a person!
			name.append($('<span>').append(userSpan(user.id))) #.css('font-weight', 'bold'))
		else
			name.append($('<span>').text(user.name).css('font-weight', 'bold')).append(" (#{user.members.length})")			
			for user in user.members.sort((a, b) -> get_weight(b) - get_weight(a))
				create_row(user, true)

	TOP_NUM = 3
	CONTEXT = 2
	# WHAT DOES THIS MEAN?
	# SHOW 10 users
	ellipsis = null
	render_count = 0

	thresh = TOP_NUM + CONTEXT * 2


	for i in [0...TOP_NUM] when i < entities.length
		create_row entities[i]
		render_count++

	if entities.length > TOP_NUM
		ellipsis = $('<tr>').addClass('ellipsis').appendTo list


	if me_entity and me_entity.position >= TOP_NUM + CONTEXT * 2 and !me.leaderboard
		# thresh = TOP_NUM
		bottom_size = Math.min(entities.length, me_entity.position + CONTEXT) - (me_entity.position - CONTEXT)

		for i in [TOP_NUM...TOP_NUM + (CONTEXT * 2 - bottom_size)] when i < entities.length
			create_row entities[i]
			render_count++

		# row = $('<tr>').addClass('ellipsis').appendTo list
		# ellipsis = $('<td colspan=4>').appendTo(row)
		for i in [me_entity.position - CONTEXT...me_entity.position + CONTEXT] when i >= 0 and i < entities.length
			create_row entities[i]
			render_count++
	else
		for i in [TOP_NUM...thresh] when i >= 0 and i < entities.length
			create_row entities[i]
			render_count++

		# if entities.length - render_count > 0
		# 	row = $('<tr>').addClass('ellipsis').appendTo list
		# 	ellipsis = $('<td colspan=4>').appendTo(row)

		if me.leaderboard
			for i in [thresh...entities.length]
				create_row entities[i]
	
	list.find('tr:not(.refreshed)').remove()
	if ellipsis 
		# if entities.length - render_count > 0
		status = "(<b>#{entities.length - render_count}</b> hidden)"
		if me.leaderboard
			status = "(hide <b>#{entities.length - render_count}</b>)"
		

		
		msg = $('<span>').css('position', 'relative')
		.html(" <span class='badge badge-success'>#{room.active_count()}</span> active <span class='badge'>#{user_count}</span> users")
		
		
		# col2 = $('<td colspan=4>').appendTo(ellipsis).append($('<span>').html(status))
		col1 = $('<td colspan=4>').appendTo(ellipsis).append($('<span>').html(status)).append(' ').append(msg)

	# cts = $('<span>').css('position', 'relative').html(" (<b>click</b> to show)").hide().appendTo ellipsis
	# ellipsis.mouseenter ->
	# 	msg.animate {
	# 		left: '+=' + ellipsis.width()
	# 	}, ->
	# 		msg.hide()
	# 		cts.show().css('left', "-#{ellipsis.width()}px").animate {
	# 			left: '0'
	# 		}
	# ellipsis.mouseleave ->
	# 	cts.animate {
	# 		left: '-=' + ellipsis.width()
	# 	}, ->
	# 		cts.hide()
	# 		msg.show().css('left', "#{ellipsis.width()}px").animate {
	# 			left: '0'
	# 		}



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

last_solitude_check = 0

check_alone = ->
	return unless connected()
	return if me.muwave
	
	active_count = 0
	for id, user of room.users
		if user.online() and room.serverTime() - user.last_action < 1000 * 60 * 10
			active_count++
	
	if active_count is 1
		return if Date.now() - last_solitude_check < 1000 * 60
		last_solitude_check = Date.now()

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
	row	"Correct", "#{user.correct} <span style='color:gray'>/ #{user.guesses}</span>"
	row "Streak",  "#{user.streak} <span style='color:gray'>/ #{user.streak_record}</span>"
	# if full
	# 	row "Record", user.streak_record
	if room.interrupts
		row "Interrupts", user.interrupts
		row "Early", user.early if full
	# if full or !room.interrupts
	# 	row "Incorrect", user.guesses - user.correct  
	# row "Guesses", user.guesses 
	row "Seen", user.seen
	row "Team", user.team if user.team
	row "ID", user.id.slice(0, 10) if full
	if full
		row "Last Seen", "<span style='font-size:x-small'>#{formatRelativeTime(user.last_action)}</span>"
	
	if full and user.id isnt me.id and me.authorized(2)
		line = $('<span>')
		banButton user.id, line, 1
		row "Admin", line
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
	if room.interrupts
		row "Interrupts", Sum(user.interrupts for user in team.members)
		row "Early", Sum(user.early for user in team.members) if full
	# row "Incorrect", team.guesses - team.correct  if full
	row "Guesses", Sum(user.guesses for user in team.members)
	# row "Seen", team.seen
	
	row "Members", team.members.length

	# row "ID", team.id.slice(0, 10) if full
	# row "Last Seen", formatRelativeTime(team.last_action) if full
	return table

createBundle = ->
	create_bundle {
		year: room.info.year, 
		difficulty: room.info.difficulty, 
		category: room.info.category, 
		tournament: room.info.tournament,
		bookmarked: is_bookmarked(room.qid),
		round: room.info.round,
		num: room.info.num,
		qid: room.qid,
		question: room.question,
		generated_time: room.generated_time,
		answer: room.answer
	}



changeQuestion = ->
	return unless room.question and room.generated_time
	cutoff = 15
	#smaller cutoff for phones which dont place things in parallel
	cutoff = 1 if mobileLayout()
	$('.bundle .ruling').tooltip('destroy')

	#remove the old crap when it's really old (and turdy)
	$('#history .bundle').slice(cutoff).find('.annotations').slideUp 'normal', -> 
			$(this).remove()
	$('#history .bundle').slice(cutoff).not('.bookmarked').slideUp 'normal', -> 
			$(this).remove()
	old = $('#history .bundle').first()
	
	$('.bundle').removeClass 'active'

	old.find('.breadcrumb').click -> 1 # register a empty event handler so touch devices recognize
	#merge the text nodes, perhaps for performance reasons
	bundle = createBundle().width($('#history').width()) #.css('display', 'none')
	bundle.addClass 'active'


	$('#history').prepend bundle.hide()
	# updateTextPosition()
	updateInlineSymbols()
	
	$('.chat.typing').each ->
		original = $(this)
		if room.serverTime() - original.data('last_update') > 1000 * 20
			original.removeClass 'typing'
			return
		self_clone = original.clone().insertBefore(original)
		original.appendTo bundle.find('.annotations')
		self_clone.slideUp 'normal', ->
			$(this).remove()
		
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

	update_visibility()




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

is_bookmarked = (qid) ->
	bookmarks = []
	try
		bookmarks = JSON.parse(localStorage.bookmarks)
	for b in bookmarks
		return true if b.qid is qid
	return false


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

# word_archive = 'a,at,one,this,ideas,method,divided,thirteen,developed,government,mercenaries,observations,phenomenology,counterexample,epistemological'.split(',')

create_bundle = (info) ->
	bundle = $('<div>').addClass('bundle')
		.addClass("qid-#{info.qid}")

	bundle.toggleClass 'semi', room.semi

	bundle.data 'info', info

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

	field info.year + ' ' + info.difficulty + ' ' + info.category
	
	field 'Room', info.name if /stalker/.test(room.name)
	field 'Category', info.category
	field 'Difficulty', info.difficulty
	if info.tournament and info.year
		field 'Tournament', info.year + ' ' + info.tournament
	else if info.year
		field 'Year', info.year
	else if info.tournament
		field 'Tournament', info.tournament

	breadcrumb.find('li').last().append $('<span>').addClass('divider hidden-phone hidden-offline').text('/')

	breadcrumb.append $('<li>').addClass('clickable hidden-phone hidden-offline').text('Report').click (e) ->
		unless bundle.find('.report-form').length > 0
			create_report_form(info).insertBefore(bundle.find(".annotations")).hide().slideDown()
		e.stopPropagation()
		e.preventDefault()
	
	answer = $('<li>').addClass('pull-right answer')
	pad_answer = $('<li>').addClass('pull-right answer')
	padding_text = info.answer.replace /\w/g, 'x'
	# text = info.answer.replace /[a-z]+/gi, (e) ->
	# 	next = word_archive[e.length - 1]
	# 	word_archive[e.length - 1] = e if Math.random() > 0.5
	# 	return next || e
	if (info.answer + '').indexOf('{') == -1
		answer.text(info.answer).css('font-weight', 'bold')
		pad_answer.text(padding_text).css('font-weight', 'bold')
	else
		answer.html(info.answer.replace(/\{/g, '<span class="bold">').replace(/\}/g, '</span>'))
		pad_answer.html(padding_text.replace(/\{/g, '<span class="bold">').replace(/\}/g, '</span>'))

	
	pad_answer.data('actual_answer', answer)
	
	breadcrumb.append pad_answer
	readout = $('<div>').addClass('readout')
	well = $('<div>').addClass('well').appendTo(readout)
	well.append $('<span>').addClass('unread').text(info.question)
	bundle
		.append($('<ul>').addClass('breadcrumb').append(breadcrumb))
		.append(readout)
		.append($('<div>').addClass('sticky'))
		.append($('<div>').addClass('annotations'))

# $('.bundle').not('.active').add('.bundle.revealed').find('.answer').not('.done').replaceWith(function(){return $(this).data('actual_answer').addClass('done')})

update_visibility = ->
	$('.bundle').not('.active').add('.bundle.revealed').find('.answer').not('.done').replaceWith -> 
		$(this).data('actual_answer').addClass('done')

# complicated reciprocal cipher for sake of being a complicated reciprocal cipher
alphanum_xor = (input) ->
	alpha = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
	throw 'non-even count' if alpha.length % 2 != 0

	num_cycle = [141,592,653,589,793,238,462,643,383,279,502,884,197,169,399,375,105,820,974,944,592]
	counter = 0
	num = input.length

	permutation_cycle = (index) -> 
		narwhal = [alpha[0]]
		for i in [1...alpha.length]
			j = (index % (i + 1))
			narwhal[i] = narwhal[j]
			narwhal[j] = alpha[i]
		return narwhal

	mod = for letter in input.split('')
		counter++
		num += num_cycle[counter % num_cycle.length]
		if alpha.indexOf(letter) == -1
			letter
		else
			tmp_dict = permutation_cycle(num).join('')
			tmp_dict[(tmp_dict.indexOf(letter) + tmp_dict.length * 1.5) % tmp_dict.length]
	return mod.join('')


reader_children = null
reader_last_state = -1

updateTextPosition = ->
	return unless room.question and room.timing and reader_children

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

	finish_point = bundle.data('finish_point')
	
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
		else if finish_point and i is finish_point
			element.append " <span class='inline-icon'><i class='label icon-white icon-forward label-info'></i></span> "

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
