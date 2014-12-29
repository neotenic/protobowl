render_categories = ->
	# turns out this function is quite slow

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
		$('<a>').attr('href', '#').addClass('percentage pull-right').appendTo item
		

		value = $(item).data('value')
		percentage = room.distribution[value] / s
		$(item).find('.percentage').html("#{Math.round(100 * percentage)}% &nbsp;").attr('title', room.distribution[value] + ' shares')
		$(item).find('.increase').removeClass('disabled')
		if percentage > 0 and s > 1
			$(item).find('.decrease').removeClass('disabled')
		else
			$(item).find('.decrease').addClass('disabled')
			$(item).find('.name').css('font-weight', 'normal')
		if percentage > 0
			$(item).find('.name').css('font-weight', 'bold')


# TODO: support holding down on a button and having it auto-repeat like with a a keyboard key

increment_category = (category) ->
	return unless room.distribution
	item = $(this).parents('.category-item')
	obj = clone_shallow(room.distribution)
	obj[category]++
	me.set_distribution obj

decrement_category = (category) ->
	return unless room.distribution

	s = 0
	s += val for cat, val of room.distribution
	obj = clone_shallow(room.distribution)
	if obj[category] > 0 and s > 1
		obj[category]--
		me.set_distribution obj

$('.category-item .percentage').live 'click', (e) ->
	return unless room.distribution
	e.preventDefault()

	# TODO: better algorithm for this
	item = $(this).parents('.category-item')
	category = $(item).data('value')
	
	s = 0
	s += val for cat, val of room.distribution
	# calculate the total number of things

	blah = window.prompt "Enter new percentage value for #{category}", Math.round(100 * room.distribution[category] / s)
	pct = parseInt(blah, 10) / 100
	if !isNaN(pct) and 0 <= pct <= 1
		# s - room.distribution[category]
		obj = clone_shallow(room.distribution)
		
		obj[category] = Math.round(s * pct)
		if pct > 0
			# if changing percentage to zero, dont bother redistributing
			shares = s - obj[category]
			for cat, val of obj when cat isnt category
				obj[cat] = Math.round(val / s * shares)

		me.set_distribution obj
	else
		alert('invalid value' + blah)
		

$('.dist-picker .increase').live 'mousedown', (e) ->
	item = $(this).parents('.category-item')
	increment_category($(item).data('value'))

$('.dist-picker .decrease').live 'mousedown', (e) ->
	item = $(this).parents('.category-item')
	decrement_category($(item).data('value'))


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
	$('.multibuzz').prop 'checked', !room.max_buzz
	$('.allowskip').prop 'checked', !room.no_skip
	$('.allowpause').prop 'checked', !room.no_pause
	$('.adhd').prop 'checked', !!me.prefs.distraction
	$('body').toggleClass 'distraction', !!me.prefs.distraction


	if $('.settings').is(':hidden')
		$('.settings').slideDown()
		$(window).resize()
	
	$('.bundle.active').toggleClass 'semi', room.semi

	if me.id of room.users  and 'prefs' of room.users[me.id]

		if !$('.timer-widget').data('hidden') != !me.prefs.timer_hide
			if me.prefs.timer_hide
				$('.timer-widget').data('hidden', true)
				$('.timer, .progress').slideUp().queue ->
						$(this).css('opacity', '').dequeue()
						$('.expand-timer').fadeIn()
			else
				$('.timer-widget').data('hidden', false)
				$('.expand-timer').fadeOut()
				$('.timer, .progress').slideDown().animate({opacity: 0.7}).queue ->
						$(this).css('opacity', '').dequeue()


		$('.livechat').prop 'checked', !!me.prefs.typing
		$('.sounds').prop 'checked', !!me.prefs.sounds
		$('.lock').prop 'checked', !!me.lock
		$('.teams').val me.team

		$('.microwave').toggle !(me.muwave)

		if me.metrics().guesses > 0
			$('.reset-score').slideDown()
		else
			$('.reset-score').slideUp()

		if me.authorized('moderator') and !me.authorized('admin')
			$('.relinquish-command').slideDown()
			$('.set-name').slideUp()
		else
			$('.relinquish-command').slideUp()
			$('.set-name').slideDown()

		count = (1 for u of room.users).length
		if count > 1
			$('.set-team').slideDown()
		else
			$('.set-team').slideUp()

	if me.id and me.id[0] is '_'
		$('a.brand').prop('href', '/stalkermode')
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
				$('.prompt_input').val(room.attempt.text).focus()
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

			find_question room.qid, (question) ->
				update_question_cache(question)
			# update_question_cache?()
	
	updateTextPosition()

	# #render the time
	renderTimer()


renderTimer = ->
	if room.end_time and room.begin_time
		$('.timer').removeClass 'disabled'
	else
		$('.timer').addClass 'disabled'
		
	time = Math.max(room.begin_time, room.time())

	if connected() or sock?.hide_disconnect
		$('.offline-badge').capQueue().fadeOut()
	else
		$('.offline-badge').capQueue().fadeIn()
	
	
	$('.chatbtn').disable !me.authorized(room.mute)

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
			if !room.scoring?.interrupt and time < room.end_time - room.answer_duration
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

	if room.no_skip
		$('.skipbtn').disable true

	unless $('.timer-widget').data('hidden')		
	
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
		if me.prefs.movingwindow
			score = user.score() - [0].concat(user.history).slice(-me.prefs.movingwindow)[0]
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

	if lock_electorate <= 2 or room.escalate >= room.acl.moderator
		$('.lockvote').slideUp()
		
	else
		$('.lockvote').slideDown()
		
		if lock_votes < needed
			$('.lockvote .electorate').text "#{needed-lock_votes} needed"
		else
			$('.lockvote .electorate').text "#{lock_votes}/#{lock_electorate} votes"
		
	$('.lockvote .status_icon').removeClass('icon-lock icon-unlock icon-flag')
	
	$('.request-access button').disable !!me.elect

	$('.globalsettings').toggleClass 'escalate', !(room.escalate > room.acl.unlocked)

	if me.authorized()
		# woo ima adminiman
		if room.locked()
			$('.lockvote .status_icon').addClass('icon-flag')
		else
			$('.lockvote .status_icon').addClass('icon-unlock')
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
			# attrs.interrupts = Sum(u.metrics().interrupts for u in attrs.members)
			attrs.metrics = ->
				all = {}
				for u in attrs.members
					for m, v in u.metrics()
						all[m] = 0 unless all[m]
						all[m] += v
				return all
			
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
			badge.addClass('badge-info').prop('title', 'You')
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
				badge.addClass('badge-success').prop('title', 'Online')
			else if idle_count > 0
				badge.addClass('badge-warning').prop('title', 'Idle')
		if subordinate
			row.addClass('subordinate')
			$('<td>').addClass('rank').appendTo(row)
		else
			$('<td>').addClass('rank').append(user.rank).appendTo(row)
		$('<td>').addClass('score').append(badge).appendTo(row)

		name = $('<td>').appendTo row

		$('<td>').addClass('negs').text(user.metrics().interrupts).appendTo row

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

	# display top 3
	for i in [0...TOP_NUM] when i < entities.length
		create_row entities[i]
		render_count++
	# if more than three, add ellipsis bar
	if entities.length > TOP_NUM
		ellipsis = $('<tr>').addClass('ellipsis refreshed').appendTo list

	# if i exist on the leaderboard, and i'm 
	if me_entity and me_entity.position >= TOP_NUM + CONTEXT * 2 and !me.prefs.leaderboard
		# thresh = TOP_NUM
		bottom_size = Math.min(entities.length, me_entity.position + CONTEXT) - (me_entity.position - CONTEXT)

		# i have no idea what this code does
		# for i in [TOP_NUM...TOP_NUM + (CONTEXT * 2 - bottom_size)] when i < entities.length
		# 	create_row entities[i]
		# 	render_count++

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

		if me.prefs.leaderboard
			for i in [thresh...entities.length]
				create_row entities[i]
	
	list.find('tr:not(.refreshed)').remove()
	if ellipsis 
		# if entities.length - render_count > 0
		status = "(<b>#{entities.length - render_count}</b> hidden)"
		if me.prefs.leaderboard
			status = "(hide <b>#{entities.length - render_count}</b>)"
		
		msg = $('<span>')
			.css('position', 'relative')
			.html(" <span class='badge badge-success'>#{room.active_count()}</span> active <span class='badge'>#{user_count}</span> users")
		
		# col2 = $('<td colspan=4>').appendTo(ellipsis).append($('<span>').html(status))
		col1 = $('<td colspan=4>')
			.appendTo(ellipsis)
			.append($('<span>').html(status))
			.append(' ')
			.append(msg)


	#console.timeEnd('draw board')
	# this if clause is ~5msecs
	# console.log entities, room.users, me.id
	if user_count > 1 and (connected() or sock?.hide_disconnect)
		if $('.leaderboard').is(':hidden')
			$('.leaderboard').slideDown()
			$('.singleuser').slideUp()
	else if room.users[me.id]
		$('.singleuser .stats').empty().append(createStatSheet(room.users[me.id], !!$('.singleuser').data('full')))
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

			suggested_candidates.sort (a, b) -> data[b] - data[a]

			if suggested_candidates.length > 0
				links = (
					for can in suggested_candidates
						cantext = can.replace(/\/lobby$/g, '')
						cantext.link("/" + can) + "&nbsp;(#{data[can]}) " 
				)
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
	table = $('<div>').addClass('pseudotable')
	# body = $('<tbody>').appendTo(table)
	row = (name, val) ->
		$('<div>')
			.addClass('pseudorow')
			.appendTo(table)
			.append($("<span>").addClass("left").text(name))
			.append($("<span>").addClass("right").append(val))
	
	fullrow = (args...) -> row(args...).addClass('full').toggle(full)

	mini = (title, data) -> " <span class='mini-stat' title='#{title}'> / #{data}</span>"

	m = user.metrics()

	row	"Score", $('<span>').addClass('badge').text(get_score(user))
	row	"Correct", m.correct + mini("Current Streak", user.streak) + mini("Streak Record", user.streak_record)

	if room?.scoring?.interrupt
		row	"Interrupts", m.interrupts + mini("Current Streak", user.negstreak) + mini("Streak Record", user.negstreak_record)

		fullrow "Early", m.early + mini("Powermarked Seen", user.earlyseen)
	else
		row	"Incorrect", m.wrong + mini("Current Streak", user.negstreak) + mini("Streak Record", user.negstreak_record)

	row	"Seen", user.seen + mini("Guesses", m.guesses)

	row "Team", user.team if user.team
	
	if user.admin_name
		row "Auth", user.admin_name

	fullrow "ID", user.id.slice(0, 10)
	
	fullrow "Last Seen", "<span style='font-size:x-small'>#{formatRelativeTime(user.last_action)}</span>"
	
	if full and user.id isnt me.id and me.authorized('moderator')
		line = $('<span>')
		line.append admin_panel(user.id, true)
		row "Admin", line
	return table

createTeamStatSheet = (team, full) ->
	# table = $('<table>').addClass('table headless')
	table = $('<div>').addClass('pseudotable')
	# body = $('<tbody>').appendTo(table)
	row = (name, val) ->
		$('<div>')
			.addClass('pseudorow')
			.appendTo(table)
			.append($("<span>").addClass("left").text(name))
			.append($("<span>").addClass("right").append(val))

	row	"Score", $('<span>').addClass('badge').text(get_score(team))

	row	"Correct", Sum(user.metrics().correct for user in team.members)

	if room.interrupts
		row "Interrupts", Sum(user.metrics().interrupts for user in team.members)
		row "Early", Sum(user.metrics().early for user in team.members) if full
	# row "Incorrect", team.guesses - team.correct  if full
	row "Guesses", Sum(user.metrics().guesses for user in team.members)
	# row "Seen", team.seen
	
	row "Members", team.members.length

	# row "ID", team.id.slice(0, 10) if full
	# row "Last Seen", formatRelativeTime(team.last_action) if full
	return table

createBundle = ->
	create_bundle jQuery.extend(jQuery.extend(true, {}, room.info), {
		qid: room.qid,
		question: room.question,
		generated_time: room.generated_time,
		answer: room.answer
	})



changeQuestion = ->
	return unless room.question and room.generated_time
	cutoff = 15
	#smaller cutoff for phones which dont place things in parallel
	cutoff = 1 if mobileLayout()
	$('.bundle .ruling').tooltip('destroy')

	#remove the old crap when it's really old (and turdy)
	$('#history .bundle').slice(cutoff).find('.annotations').slideUp 'normal', -> 
			$(this).remove()

	$('#history .bundle').slice(cutoff).slideUp 'normal', -> 
		if $(this).is('.bookmarked')
			# move it over to special space
			$("#bookmarks").prepend $(this).slideDown()
			
			if $('#bookmarks .bundle').length
				$("#whale").slideDown()
		else
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
		for el in nested
			if $(el).data('text')
				el.childNodes[0].nodeValue = $(el).data('text')
				
		old.find('.readout .well').append nested.contents()
		nested.remove()

		old.find('.readout')[0].normalize()

		old.queue ->
			old.find('.readout').slideUp("normal")
			$(this).dequeue()

	update_visibility()




create_report_form = (info) ->
	div = $("<div>").addClass("alert alert-block alert-info report-form")
	
	div.append $("<button>", {
		"data-dismiss": "alert",
		"type": "button"
	})
	.html("&times;")
	.addClass("close")

	# div.append $("<h4>").text "Change Question"
	form = $("<form>")
	form.addClass('form-horizontal').appendTo div
	rtype = $('<div>').addClass('control-group').appendTo(form)
	rtype.append $("<label>").addClass('control-label').text('Description')
	controls = $("<div>").addClass('controls').appendTo rtype
	for option in ["Wrong category", "Incorrectly bolded", "Change tags", "Broken question"]
		controls.append $("<label>")
			.addClass("radio")
			.append($("<input type=radio name=description>").val(option.split(" ")[1].toLowerCase()))
			.append(option)

	submit_btn = $('<button>', { type: "submit" })
		.addClass('btn btn-primary')
		.text('Submit')

	form.find(":radio").change ->
		if form.find(":radio:checked").val() is 'category'
			ctype.slideDown()
			$(cat_list).trigger('change')
		else
			ctype.slideUp()

		if form.find(":radio:checked").val() is 'bolded'
			answer.slideDown()
			submit_btn.disable(invalid_answerline())
		else
			answer.slideUp()

		if form.find(":radio:checked").val() is 'question'
			comment.slideDown()
			submit_btn.disable(false)
		else
			comment.slideUp()

		if form.find(":radio:checked").val() is 'tags'
			tags.slideDown()
			submit_btn.disable(false)
		else
			tags.slideUp()

	tags = $('<div>').addClass('control-group').appendTo(form).hide()
	tags.append $("<label>").addClass('control-label').text('Tags')

	taglist = $('<select>')
	tags.append $("<div>").addClass('controls').append taglist	
	tagdb = {
		"Science": ["Biology", "Chemistry", "Physics", "Math", "Geology", "Astronomy"],
		"History": ["American", "Ancient", "European", "World"],
		"Fine Arts": ["Art", "Music", "Other"],
		"Literature": ["American", "European", "Language Arts", "World"],
		"Social Science": ["Anthropology", "Economics", "Geography", "Psychology"],
		"Trash": ["Film", "Sports", "Games", "TV", "Music"]
	}
	taglist.append new Option('None', '')

	taglist.append new Option(cat) for cat in (tagdb[info.category] || [])
	# $(cat_list).change ->	


	ctype = $('<div>').addClass('control-group').appendTo(form)
	ctype.append $("<label>").addClass('control-label').text('Category')

	comment = $('<div>').addClass('control-group').appendTo(form).hide()
	comment.append $("<label>").addClass('control-label').text('Comment')
	ragequit = $("<input type=text>").attr('placeholder', 'What needs to be fixed')
	comment.append $("<div>").addClass('controls').append(ragequit)

	answer = $('<div>').addClass('control-group').appendTo(form).hide()
	answer.append $("<label>").addClass('control-label').text('Answer')
	navver = $("<ul>").addClass("nav nav-pills emboldinator")

	answer.append $("<div>").addClass('controls').append navver

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
					# console.log line, info.answer
					submit_btn.disable invalid_answerline()

					return false

	cat_list = $('<select>')
	ctype.append $("<div>").addClass('controls').append cat_list
	

	cat_list.append new Option(cat) for cat in room.categories
	$(cat_list).change ->
		# console.log 'got soul', (cat_list.val() is info.category)
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
		if describe is 'bolded'
			# this is such an epidemic that we'll just push things straight to the db
			me.change_bold { id: info.qid, answer: reconstruct_answerline() }
		else if describe is 'tags'
			# console.log info.qid
			if $(taglist).val() is ''
				me.tag_question { id: info.qid, tags: [] }
			else
				me.tag_question { id: info.qid, tags: [$(taglist).val()] }	
		else

			if describe is 'category'
				info.fixed_category = cat_list.val()
			info.describe = describe
			
			info.type = room.type
			info.comment = ragequit.val()

			me.report_question info
		
		# createAlert('Reported Question', 'You have successfully reported a question. It will be reviewed and the database may be updated to fix the problem. Thanks.')
		createAlert('Reported Question', 'Protobowl has a new answer checking algorithm (finally!), it takes into account which words are bolded in the answer line to determine what to accept, prompt or reject. Please hit Edit and revise the bolding.')
			.addClass('alert-success')
			.insertAfter(div.parent().find('.annotations'))

		div.slideUp 'normal', ->
			$(this).remove()

		return false

	controls.find('input:radio')[0].checked = true
	# controls.find("input:radio").change()

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
			# info.bookmarked = !info.bookmarked
			# bundle.toggleClass 'bookmarked', info.bookmarked
			
			# $(".qid-#{info.qid} .bookmark")
			# 	.toggleClass('icon-star-empty', !info.bookmarked)
			# 	.toggleClass('icon-star', info.bookmarked)
			
			# toggle_bookmark info, info.bookmarked
			
			if e.shiftKey
				find_question info.qid, (snapshot) ->
					set_bookmark info.qid, snapshot.bookmarked + 1
			else if bundle.hasClass('bookmarked')
				set_bookmark info.qid, 0
			else
				set_bookmark info.qid, 1
			# console.log 'changing stuff'

	# star.toggleClass 'icon-star-empty', !info.bookmarked
	# star.toggleClass 'icon-star', info.bookmarked
	
	check_bookmark? info.qid
	star.addClass 'icon-star-empty'
	breadcrumb.append $('<li>').addClass('pull-right').append(star)

	field = (name) ->
		breadcrumb.find('li:not(.pull-right)').last().append $('<span>').addClass('divider').text('/')
		# if value
		# 	name += ": " + value
		el = $('<li>').text(name).appendTo(breadcrumb)
		# if value
		# 	el.addClass('hidden-phone')
		# else
		# 	el.addClass('visible-phone')

	# field info.year + ' ' + info.difficulty + ' ' + info.category
	
	if info.tournament and info.date
		field info.date
	else if info.tournament and info.year
		field info.year + ' ' + info.tournament
	else if info.year
		field info.year
	else if info.tournament
		field info.tournament
	
	field info.difficulty
	field info.category

	if info.group
		field(info.group).css('font-weight', 'bold')

	if info.tags
		field tag for tag in info.tags

	breadcrumb.find('li').last().append $('<span>').addClass('divider hidden-phone hidden-offline edit-button').text('/')

	breadcrumb.append $('<li>').addClass('clickable hidden-phone hidden-offline edit-button').text('Edit').click (e) ->
		unless bundle.find('.report-form').length > 0
			create_report_form(info).insertBefore(bundle.find(".annotations")).hide().slideDown()
		e.stopPropagation()
		e.preventDefault()
	
	answer = $('<li>').addClass('pull-right answer')
	pad_answer = $('<li>').addClass('pull-right answer')
	padding_text = rewrite_word(info.answer)

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
# alphanum_xor = (input) ->
# 	alpha = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
# 	throw 'non-even count' if alpha.length % 2 != 0

# 	num_cycle = [141,592,653,589,793,238,462,643,383,279,502,884,197,169,399,375,105,820,974,944,592]
# 	counter = 0
# 	num = input.length

# 	permutation_cycle = (index) -> 
# 		narwhal = [alpha[0]]
# 		for i in [1...alpha.length]
# 			j = (index % (i + 1))
# 			narwhal[i] = narwhal[j]
# 			narwhal[j] = alpha[i]
# 		return narwhal

# 	mod = for letter in input.split('')
# 		counter++
# 		num += num_cycle[counter % num_cycle.length]
# 		if alpha.indexOf(letter) == -1
# 			letter
# 		else
# 			tmp_dict = permutation_cycle(num).join('')
# 			tmp_dict[(tmp_dict.indexOf(letter) + tmp_dict.length * 1.5) % tmp_dict.length]
# 	return mod.join('')


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
		text = $(reader_children[word_index]).data('text')
		if text
			reader_children[word_index].childNodes[0].nodeValue = text
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

width_to_letter = {}
letter_to_width = {}

calculate_widths = ->
	# console.time('widthify')	
	fake_well = $("<div>").addClass("well")
	container = $("<div>").css('overflow', 'hidden').css('width', 0).css('height', 0).appendTo("body").append(fake_well)
	span = $("<span>").appendTo(fake_well)
	
	for code in [33...126]
		letter = String.fromCharCode(code)
		span.text letter
		width = span.width()
		width_to_letter[width] = letter
		letter_to_width[letter] = width
	container.remove()
	# console.timeEnd('widthify')

rewrite_word = (text) ->
	unless letter_to_width['x'] > 0
		calculate_widths()

	word = for letter in text
		if letter of letter_to_width
			width_to_letter[letter_to_width[letter]]
		else
			letter

	word.join('')



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
			word = words[i]
			# inner_span = $('<span>')
			# inner_span.append(word + " ")
			# element.append(inner_span)
			# element.append(word + " ")
			element.data('text', word + " ")
			if room.semi
				element.append(word + " ")
			else
				element.append(rewrite_word(word) + " ")


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
