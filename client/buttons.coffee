$('#username').keyup (e) ->
	if e.keyCode is 13
		$(this).blur()

	name = $(this).val()
	if name.length > 0
		me.set_name name
		localStorage.username = name

$('.generate-name').click ->
	if generateName?
		$('#username').val generateName()
		$('#username').keyup().focus()

jQuery('.bundle .breadcrumb').live 'click', ->
	unless $(this).is jQuery('.bundle .breadcrumb').first()
		readout = $(this).parent().find('.readout')
		readout.width($('#history').width()).slideToggle "normal", ->
			readout.width 'auto'

actionMode = ''
setActionMode = (mode) ->
	if mode != actionMode and actionMode
		$('.prompt_input, .guess_input, .chat_input').blur()
	actionMode = mode
	
	$('.actionbar' ).toggle mode is ''
	$('.chat_form').toggle mode is 'chat'
	$('.guess_form').toggle mode is 'guess'
	$('.prompt_form').toggle mode is 'prompt'

	$(window).resize() #reset expandos

$('.chatbtn').click ->
	$('.chat_input').val('')
	open_chat()


open_chat = ->
	return if room.mute and !room.authorized(2)

	if actionMode != 'chat'
		setActionMode 'chat'
		# create a new input session id, which helps syncing work better
		$('.chat_input')
			.data('input_session', Math.random().toString(36).slice(3))
			.data('begin_time', +new Date)
	
	$('.chat_input')
		.keyup()
		.focus()

recent_actions = [0]
rate_limit_ceiling = 0
rate_limit_check = ->
	return false if location.hostname is 'localhost' or me.id[0] is '_'

	return false if !connected()
	rate_threshold = 7
	current_time = +new Date
	filtered_actions = []
	rate_limited = false
	for action in recent_actions when current_time - action < 5000
		# only look at past 5 seconds
		filtered_actions.push action
	# console.log filtered_actions.length, rate_threshold
	if filtered_actions.length >= rate_threshold
		rate_limited = true
	if rate_limit_ceiling > current_time
		rate_limited = true
	recent_actions = filtered_actions.slice(-10)
	recent_actions.push current_time
	if rate_limited
		rate_limit_ceiling = current_time + 5000
		createAlert $('.bundle.active'), 'Rate Limited', "You been rate limited for doing too many things in the past five seconds. "
	return rate_limited


skip = ->
	return if rate_limit_check()
	me.skip()

next = ->
	# reduce dat server load
	if room.time() >= room.end_time and !room.attempt
		me.next()

$('.skipbtn').click skip

$('.nextbtn').click next

$('.buzzbtn').click ->
	return if $('.buzzbtn').attr('disabled') is 'disabled'
	return if rate_limit_check()
	setActionMode 'guess'
	$('.guess_input')
		.val('')
		.addClass('disabled')
		.focus()
	# so it seems that on mobile devices with on screen virtual keyboards
	# if your focus isn't event initiated (eg. based on the callback of
	# some server query to confirm control of the textbox) it wont actualy
	# bring up the keyboard, so the solution here is to first open it up
	# and ask nicely for forgiveness otherwise
	submit_time = +new Date
	if $('.sounds')[0].checked and !$('.sounds').data('ding_sound')
		$('.sounds').data('ding_sound', new Audio('/sound/ding.wav'))

	me.buzz room.qid, (status) ->
		if status is 'http://www.whosawesome.com/'
			$('.guess_input').removeClass('disabled')
			if $('.sounds')[0].checked
				$('.sounds').data('ding_sound').play()
			_gaq.push ['_trackEvent', 'Game', 'Response Latency', 'Buzz Accepted', new Date - submit_time] if window._gaq
		else
			setActionMode ''
			_gaq.push ['_trackEvent', 'Game', 'Response Latency', 'Buzz Rejected', new Date - submit_time] if window._gaq

$('.score-reset').click -> 
	# i could have structured this is a more concise but weirder way
	# but for some reason i decided against that, and I know not why
	if me.score() > 50
		bootbox.confirm "Are you sure you want to reset your score?", (result) ->
			me.reset_score() if result
	else
		me.reset_score()

$('.lose-command').click -> me.cincinnatus()

$('.pausebtn').click ->
	return if rate_limit_check()
	if !!room.time_freeze
		me.unpause()
	else
		me.pause()


$('.chat_input').keydown (e) ->
	if e.keyCode in [47, 111, 191] and $(this).val().length is 0 and !e.shiftKey
		e.preventDefault()
	if e.keyCode in [27] #escape key
		$('.chat_input').val('')
		$('.chat_form').submit()


$('input').keydown (e) ->
	e.stopPropagation() #make it so that the event listener doesnt pick up on stuff
	if $(this).hasClass("disabled")
		e.preventDefault()


$('.chat_input').typeahead {
	source: -> list_targets(this.query)
	matcher: (candidate) ->
		this.query[0] == '@' and candidate.toLowerCase().indexOf(this.query.toLowerCase()) == 0

}

list_targets = (query) ->
	prefix = '@' + query.slice(1).split(',').slice(0, -1).join(',')
	existing = ($.trim(option) for option in query.slice(1).split(',').slice(0, -1))
	prefix += ', ' if prefix.length > 1
	# names = (user.name for id, user of room.users when user isnt me)
	names = ['individuals']
	for id, user of room.users
		names.push user.name if user.name not in names
		names.push user.team if user.team and user.team not in names
	("#{prefix}#{name}" for name in names when name not in existing)

findReferences = (text) ->
	reconstructed = '@'
	changed = true
	entities = {}
	for id, {name, team} of room.users
		entities[name] = '!@' + id + ', '
		team ||= 'individuals'
		entities[team] = '*@' + team + ', '
	while changed is true
		changed = false
		text = text.replace(/^[@\s,]*/g, '')
		for name, identity of entities
			if text.slice(0, name.length) is name
				reconstructed += identity
				text = text.slice(name.length)
				changed = true
				break
	# final pass for incompletes
	for name, identity of entities
		if text.slice(0, name.length) is name and text.length > 0
			reconstructed += identity
			text = text.slice(name.length)
			# changed = true
			break
	return [reconstructed.replace(/[\s,]*$/g, ''), text]

protobot_engaged = false
protobot_last = ''
last_target = ''

protobot_write = (message) ->
	count = 0
	session = Math.random().toString(36).slice(2)
	writeLetter = ->
		if ++count <= message.length
			chatAnnotation {
				text: message.slice(0, count),
				session,
				user: '__protobot',
				done: count == message.length,
				time: room.serverTime()
			}
			setTimeout writeLetter, 1000 * 60 / 6 / (80 + Math.random() * 50)
	writeLetter()

chat = (text, done) ->
	text = text.slice(0, 1000)

	if text.length < 15 and /lonely/i.test(text) and /re |m /i.test(text) and !/you/i.test(text) and !protobot_engaged
		protobot_engaged = true
		protobot_last = $('.chat_input').data('input_session')
		protobot_write "I'm lonely too. Plz talk to meeeee"
	else if protobot_engaged
		pick = (list) -> list[Math.floor(list.length * Math.random())]
		if done and /stahp|stop|not lonely/i.test(text)
			protobot_write 'Protobot disengaged. Prepare to languish in your solitude.'
			protobot_engaged = false
		else if omeglebot_replies? and protobot_last isnt $('.chat_input').data('input_session')
			if text.replace(/[^a-z]/g, '') of omeglebot_replies and Math.random() > 0.3 # probablistic everything
				protobot_write pick(omeglebot_replies[text.replace(/[^a-z]/g, '')])
				protobot_last = $('.chat_input').data('input_session')
			else if done
				if Math.random() < 0.1 and room.active_count() > 1
					protobot_write 'Looks like some other people exist. Just say "stahp" if you want me to die in a hole, or if you want to stop sounding schizophrenic.'
				else
					reply = pick Object.keys(omeglebot_replies)
					reply = pick omeglebot_replies[reply]
					protobot_write reply
					# doesnt matter to set protobot last because you dont repeat afterwars anyway
		

	if text.slice(0, 1) is '@'
		refs = findReferences(text)
		if refs[0] is '@'
			text = '@' + refs[1]
		else
			new_target = text.trim().slice(0, text.trim().length - refs[1].trim().length).trim()

			unless new_target is '@' + (me.team || 'individuals')
				last_target = new_target + ' '

			text = refs.join(' ')

	me.chat {
		text: text, 
		session: $('.chat_input').data('input_session'), 
		done: done
	}

$('.chat_input').keyup (e) ->
	return if e.keyCode is 13
	if $('.livechat')[0].checked and !me.muwave and $('.chat_input').val().slice(0, 1) != '@'
		$('.chat_input').data('sent_typing', '')
		chat $('.chat_input').val(), false
	else if $('.chat_input').data('sent_typing') isnt $('.chat_input').data('input_session')
		chat '(typing)', false
		$('.chat_input').data 'sent_typing', $('.chat_input').data('input_session')


$('.chat_form').submit (e) ->
	setActionMode ''
	chat $('.chat_input').val(), true
	e.preventDefault()
	
	time_delta = new Date - $('.chat_input').data('begin_time')
	_gaq.push ['_trackEvent', 'Chat', 'Typing Time', 'Posted Message', time_delta] if window._gaq

$('.guess_input').keyup (e) ->
	return if e.keyCode is 13
	me.guess {
		text: $('.guess_input').val(), 
		done: false
	}

	
$('.guess_form').submit (e) ->
	setActionMode ''
	me.guess {
		text: $('.guess_input').val(), 
		done: true
	}
	e.preventDefault()
	

$('.prompt_input').keyup (e) ->
	return if e.keyCode is 13
	me.guess {
		text: $('.prompt_input').val(), 
		done: false
	}

	
$('.prompt_form').submit (e) ->
	setActionMode ''
	me.guess {
		text: $('.prompt_input').val(), 
		done: true
	}
	e.preventDefault()
	
$('.textbar-submit').click ->
	$(this).parents('form').submit()
	
key_can_skip = true

$('body').keyup (e) ->
	if e.keyCode in [83] # S
		key_can_skip = true

$('body').keydown (e) ->
	if actionMode is 'chat'
		return $('.chat_input').focus()

	if actionMode is 'guess'
		return $('.guess_input').focus()
	
	if e.keyCode is 50 and e.shiftKey
		$('.chatbtn').click()
		$('.chat_input').focus()

	return if e.shiftKey or e.ctrlKey or e.metaKey

	if e.keyCode is 32
		e.preventDefault()
		if $('.start-page').length is 1
			$('.nextbtn').click()
		else
			$('.buzzbtn').click()
	else if e.keyCode in [83] # S
		if key_can_skip
			key_can_skip = false
			skip()
	else if e.keyCode in [78, 74] # N, J
		next()
	else if e.keyCode in [75]
		# toggle the thing for the most recent question
		$('.bundle:not(.active):first .readout').slideToggle()
	else if e.keyCode in [80, 82] # P, R
		$('.pausebtn').click()
	else if e.keyCode in [47, 111, 191, 67, 65, 13] # / (forward slash), C, A, Enter
		e.preventDefault()
		$('.chatbtn').click()
	else if e.keyCode in [87, 222] # W
		# whisper
		e.preventDefault()
		$('.chat_input').val(last_target || '@')
		open_chat()
	else if e.keyCode in [84] # T
		e.preventDefault()
		$('.chat_input').val('@' + (me.team || 'individuals') + " ")
		open_chat()
		
	else if e.keyCode in [70] # F
		me.finish()
	else if e.keyCode in [66]
		$('.bundle.active .bookmark').click()

	# debugging shortcuts	
	if location.hostname is 'localhost' or me.id?[0] is '_' or 'dev' of location.query
		# console.log e.keyCode, 'local'
		if e.keyCode in [68] # D
			me.buzz(room.qid)
			me.guess { text: room.answer.replace(/(\(|\[).*/, '').replace(/\{|\}/g, ''), done: true }
		else if e.keyCode in [69] # E
			me.buzz(room.qid)
			me.guess { text: '', done: true }
		# console.log e.keyCode

	# console.log e.keyCode


$('.speed').change ->
	$('.speed').not(this).val($(this).val())
	$('.speed').data("last_update", +new Date)
	rate = 1000 * 60 / 5 / Math.round($(this).val())
	if +$('.speed').val() > $('.speed').attr('max') - 10
		# technically not speed, but duration per syllable
		# 0.1 is close enough, though 0.01 might be better
		me.set_speed 0.1
	else
		me.set_speed rate
	# console.log rate
		
$('.categories').change ->
	me.set_category $('.categories').val()

$('.difficulties').change -> me.set_difficulty $('.difficulties').val()

# Why should I clutter my mind with general information 
# when I have men around me who can supply any knowledge I need?

$("#make_button").click ->
	if $("#team_input").val() is '__create'
		$("#team_input").val('Boxxy')
		notifyTrolls()

	me.set_team $("#team_input").val()
	$("#team_modal").data('set_team', true).modal("hide")
	$("#team_input").blur()

$("#team_modal").on 'hidden', ->
	unless $("#team_modal").data('set_team')
		me.set_team me.team

$('#team_modal').on 'shown', ->
	$("#team_input").focus()

$("#team_modal form").submit (e) ->
	e.preventDefault()
	$("#make_button").click()

$('.teams').change ->
	if $('.teams').val() is '__create'
		$("#team_modal").modal("show").data('set_team', false)
			.find('input').val(me.team)
		
	else
		me.set_team $('.teams').val()

$('.multibuzz').change -> me.set_max_buzz (if $('.multibuzz')[0].checked then null else 1)

$('.allowskip').change -> me.set_skip $('.allowskip')[0].checked

$('.showbonus').change -> me.set_bonus $('.showbonus')[0].checked

$('.livechat').change -> me.set_show_typing $('.livechat')[0].checked

$('.lock').change -> me.set_lock $('.lock')[0].checked

$('.request-access').click -> me.nominate()

$('.movingwindow').change -> 
	if $('.movingwindow')[0].checked
		me.set_movingwindow 20
	else
		me.set_movingwindow false

$('.sounds').change -> 
	me.set_sounds $('.sounds')[0].checked
	$('.sounds').data('ding_sound', new Audio('/sound/ding.wav'))

mobileLayout = -> 
	if window.matchMedia
		matchMedia('(max-width: 768px)').matches
	else
		return false

#display a tooltip for keyboard shortcuts on keyboard machines
if !Modernizr.touch and !mobileLayout()
	$('.actionbar button').tooltip()
	# hide crap when clicked upon
	$('.actionbar button').click -> 
		$('.actionbar button').tooltip 'hide'

	$('#history, .settings').tooltip {
		selector: "[rel=tooltip]", 
		placement: -> 
			if mobileLayout() then "error" else "left"
	}

$('body').click (e) ->
	$('.bundle .ruling').tooltip('destroy')

	if $(e.target).parents('.leaderboard, .popover').length is 0
		$('.leaderboard tbody tr').popover 'destroy'

		$('.popover').remove()

$('.singleuser').click ->
	$('.singleuser .stats').slideUp().queue ->
		$('.singleuser').data 'full', !$('.singleuser').data('full')
		renderUsers()
		$(this).dequeue().slideDown()

$('.show_image').live 'click', (e) ->
	e.preventDefault()
	$(this).parent().find('.chat_image').slideToggle()

$('.username').live 'click', (e) ->	
	user = room.users[$(this).data('id')]
	# console.log e, user
	return unless user
	return unless e.shiftKey or e.ctrlKey or e.metaKey

	e.preventDefault()
	if actionMode is 'chat' and $('.chat_input').val()[0] == '@'
		if $('.chat_input').val().indexOf(user.name) is -1
			$('.chat_input').val $('.chat_input').val().replace('@', '@' + user.name + ', ')
	else
		$('.chat_input').val  '@' + user.name + ' '
	
	open_chat()
	return


$('.banhammer.make-tribunal').live 'click', (e) ->
	e.preventDefault()
	me.trigger_tribunal $(this).data('id')

$('.banhammer.instaban').live 'click', (e) ->
	e.preventDefault()
	me.ban_user $(this).data('id')

$(".leaderboard tbody tr").live 'click', (e) ->
	if $(this).is(".ellipsis")
		# console.log 'toggle show all'
		me.leaderboard = !me.leaderboard
		me.set_leaderboard me.leaderboard
		renderUsers()
		return
	
	user = $(this).data('entity')

	if e.shiftKey or e.ctrlKey or e.metaKey
		e.preventDefault()
		if actionMode is 'chat' and $('.chat_input').val()[0] == '@'
			if $('.chat_input').val().indexOf(user.name) is -1
				$('.chat_input').val $('.chat_input').val().replace('@', '@' + user.name + ', ')
		else
			$('.chat_input').val  '@' + user.name + ' '
		
		open_chat()
		return

	

	enabled = $(this).data('popover')?.enabled
	# console.log $('.leaderboard tbody tr').not(this).popover 'toggle'
	accessible = $('.leaderboard tbody tr').map ->
		$(this).data('popover')?.$tip[0]
	
	$('.popover').not(accessible).fadeOut 'fast', ->
		$(this).remove()
	

	$('.leaderboard tbody tr').popover 'destroy'
	unless enabled
		$(this).popover {
			placement: if mobileLayout() then "top" else "left"
			trigger: "manual",
			title: "#{user.name}",
			content: ->
				createStatSheet(user, true)
		}
		$(this).popover 'toggle'


if Modernizr.touch
	$('.show-keyboard').hide()
	$('.show-touch').show()
else
	$('.show-keyboard').show()
	$('.show-touch').hide()

$('.show-sidebar').click (e) ->
	$('.sidebar').toggleClass('shown')
	if $('.sidebar').hasClass('shown')
		$('.show-sidebar i').removeClass('icon-circle-arrow-right')
		$('.show-sidebar i').addClass('icon-circle-arrow-left')
	else
		$('.show-sidebar i').removeClass('icon-circle-arrow-left')
		$('.show-sidebar i').addClass('icon-circle-arrow-right')
	e.preventDefault()

$('body').live 'swiperight', ->
	$('.sidebar').addClass('shown')

$('body').live 'swipeleft', ->
	$('.sidebar').removeClass('shown')