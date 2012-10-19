$('#username').keyup (e) ->
	if e.keyCode is 13
		$(this).blur()

	if $(this).val().length > 0
		me.set_name $(this).val()
		
jQuery('.bundle .breadcrumb').live 'click', ->
	unless $(this).is jQuery('.bundle .breadcrumb').first()
		readout = $(this).parent().find('.readout')
		readout.width($('#history').width()).slideToggle "normal", ->
			readout.width 'auto'

actionMode = ''
setActionMode = (mode) ->
	actionMode = mode
	$('.prompt_input, .guess_input, .chat_input').blur()
	$('.actionbar' ).toggle mode is ''
	$('.chat_form').toggle mode is 'chat'
	$('.guess_form').toggle mode is 'guess'
	$('.prompt_form').toggle mode is 'prompt'

	$(window).resize() #reset expandos

$('.chatbtn').click ->
	setActionMode 'chat'
	# create a new input session id, which helps syncing work better
	$('.chat_input')
		.data('input_session', Math.random().toString(36).slice(3))
		.data('begin_time', +new Date)
		.val('')
		.focus()
		.keyup()

recent_actions = [0]
rate_limit_ceiling = 0
rate_limit_check = ->
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

# last_skip = 0
skip = ->
	return if rate_limit_check()
	me.skip()

next = ->
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

	me.buzz 'yay', (status) ->
		if status is 'http://www.whosawesome.com/'
			$('.guess_input').removeClass('disabled')
			if $('.sounds')[0].checked
				$('.sounds').data('ding_sound').play()
			_gaq.push ['_trackEvent', 'Game', 'Response Latency', 'Buzz Accepted', new Date - submit_time] if window._gaq
		else
			setActionMode ''
			_gaq.push ['_trackEvent', 'Game', 'Response Latency', 'Buzz Rejected', new Date - submit_time] if window._gaq

$('.score-reset').click -> me.reset_score()

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
	source: ->
		prefix = '@' + this.query.slice(1).split(',').slice(0, -1).join(',')
		existing = ($.trim(option) for option in this.query.slice(1).split(',').slice(0, -1))
		prefix += ', ' if prefix.length > 1
		# names = (user.name for id, user of room.users when user isnt me)
		names = ['individuals']
		for id, user of room.users
			names.push user.name if user.name not in names
			names.push user.team if user.team and user.team not in names
		("#{prefix}#{name}" for name in names when name not in existing and name isnt me.name)
	matcher: (candidate) ->
		this.query[0] == '@' and !findReferences(this.query)[1]
}

findReferences = (text) ->
	reconstructed = '@'
	changed = true
	entities = {}
	for id, {name, team} of room.users
		entities[name] = '!@' + id + ', '
		team ||= 'individuals'
		entities[team] = '' if !entities[team]
		entities[team] += entities[name]


	while changed is true
		changed = false
		text = text.replace(/^[@\s,]*/g, '')
		for name, identity of entities
			if text.slice(0, name.length) is name
				reconstructed += identity
				text = text.slice(name.length)
				changed = true
				break
		# for id, {name} of room.users
		# 	if text.slice(0, name.length) is name
		# 		reconstructed += '!@' + id + ', '
		# 		text = text.slice(name.length)
		# 		changed = true
		# 		break
	# text = reconstructed.replace(/[\s,]*$/g, '') + ' ' + text
	return [reconstructed.replace(/[\s,]*$/g, ''), text]

protobot_engaged = false
protobot_last = ''

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
	if text.length < 15 and /lonely/i.test(text) and /re |m /i.test(text) and !/you/i.test(text) and !protobot_engaged
		protobot_engaged = true
		protobot_last = $('.chat_input').data('input_session')
		protobot_write "I'm lonely too. Plz talk to meeeee"
	else if protobot_engaged and omeglebot_replies? and protobot_last isnt $('.chat_input').data('input_session')
		pick = (list) -> list[Math.floor(list.length * Math.random())]

		if text.replace(/[^a-z]/g, '') of omeglebot_replies and Math.random() > 0.1 # probablistic everything
			protobot_write pick(omeglebot_replies[text.replace(/[^a-z]/g, '')])
			protobot_last = $('.chat_input').data('input_session')
		else if done
			reply = pick Object.keys(omeglebot_replies)
			reply = pick omeglebot_replies[reply]
			protobot_write reply
			# doesnt matter to set protobot last because you dont repeat afterwars anyway

	if text.slice(0, 1) is '@'
		refs = findReferences(text)
		if refs[0] is '@'
			text = '@' + refs[1]
		else
			text = refs.join(' ')

	me.chat {
		text: text, 
		session: $('.chat_input').data('input_session'), 
		done: done
	}

$('.chat_input').keyup (e) ->
	return if e.keyCode is 13

	if $('.livechat')[0].checked and $('.chat_input').val().slice(0, 1) != '@'
		$('.chat_input').data('sent_typing', '')
		chat $('.chat_input').val(), false
		# me.chat {
		# 	text: $('.chat_input').val(), 
		# 	session: $('.chat_input').data('input_session'), 
		# 	done: false
		# }
	else if $('.chat_input').data('sent_typing') isnt $('.chat_input').data('input_session')
		chat '(typing)', false
		# me.chat {
		# 	text: '(typing)', 
		# 	session: $('.chat_input').data('input_session'), 
		# 	done: false
		# }
		$('.chat_input').data 'sent_typing', $('.chat_input').data('input_session')


$('.chat_form').submit (e) ->
	setActionMode ''
	chat $('.chat_input').val(), true
	# me.chat {
	# 	text: $('.chat_input').val(), 
	# 	session: $('.chat_input').data('input_session'), 
	# 	done: true
	# }
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
		skip()
	else if e.keyCode in [78, 74] # N, J
		next()
	else if e.keyCode in [75]
		# toggle the thing for the most recent question
		$('.bundle:not(.active):first .readout').slideToggle()
	else if e.keyCode in [80, 82] # P, R
		$('.pausebtn').click()
	else if e.keyCode in [47, 111, 191, 67, 65, 13] # / (forward slash), C, A
		e.preventDefault()
		$('.chatbtn').click()
	else if e.keyCode in [87] # W
		# whisper
		e.preventDefault()
		$('.chatbtn').click()
		$('.chat_input').val('@')
	else if e.keyCode in [84] # T
		e.preventDefault()
		$('.chatbtn').click()
		$('.chat_input').val('@' + (me.team || 'individuals') + " ")
	else if e.keyCode in [70] # F
		me.finish()
	else if e.keyCode in [66]
		$('.bundle.active .bookmark').click()

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


$('.dist-picker .increase').live 'click', (e) ->
	return unless room.distribution
	item = $(this).parents('.category-item')
	obj = clone_shallow(room.distribution)
	obj[$(item).data('value')]++
	# sock.emit 'distribution', room.distribution
	me.set_distribution obj
	for item in $('.custom-category .category-item')
		renderCategoryItem(item)

$('.dist-picker .decrease').live 'click', (e) ->
	return unless room.distribution
	item = $(this).parents('.category-item')
	s = 0
	s += val for cat, val of room.distribution
	obj = clone_shallow(room.distribution)
	if obj[$(item).data('value')] > 0 and s > 1
		obj[$(item).data('value')]--
		# sock.emit 'distribution', room.distribution
		me.set_distribution obj
	for item in $('.custom-category .category-item')
		renderCategoryItem(item)



$('.teams').change ->
	if $('.teams').val() is 'create'
		me.set_team prompt('Enter Team Name') || ''
	else
		me.set_team $('.teams').val()

$('.multibuzz').change -> me.set_max_buzz (if $('.multibuzz')[0].checked then null else 1)

$('.allowskip').change -> me.set_skip $('.allowskip')[0].checked


$('.livechat').change -> me.set_show_typing $('.livechat')[0].checked

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
	if $(e.target).parents('.leaderboard, .popover').length is 0
		$('.popover').remove()

$('.singleuser').click ->
	$('.singleuser .stats').slideUp().queue ->
		$('.singleuser').data 'full', !$('.singleuser').data('full')
		renderUsers()
		$(this).dequeue().slideDown()

$(".leaderboard tbody tr").live 'click', (e) ->
	# console.log this
	# tmp = $('.popover')
	# allow time delay so that things can be faded out before you kill them
	# setTimeout ->
	# 	tmp.remove()
	# , 1000
	user = $(this).data('entity')
	enabled = $(this).data('popover')?.enabled
	# console.log $('.leaderboard tbody tr').not(this).popover 'toggle'
	$('.leaderboard tbody tr').popover 'destroy'
	unless enabled
		$(this).popover {
			placement: if mobileLayout() then "top" else "left"
			trigger: "manual",
			title: "#{user.name}'s Stats",
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
