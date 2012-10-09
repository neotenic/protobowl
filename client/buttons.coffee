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
	online_count = (user for user in sync.users when user.online and user.last_action > new Date - 1000 * 60 * 10).length
	rate_threshold = 7
	if online_count > 1
		rate_threshold = 3
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
	removeSplash()
	return if rate_limit_check()
	# sock.emit 'skip', 'yay'
	me.skip()

next = ->
	removeSplash()
	# sock.emit 'next', 'yay'
	me.next()

$('.skipbtn').click skip

$('.nextbtn').click next

# try
# 	ding_sound = new Audio('img/ding.wav')
# catch e
# 	# do nothing

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
	me.buzz 'yay', (status) ->
		if status is 'http://www.whosawesome.com/'
			$('.guess_input').removeClass('disabled')
			if $('.sounds')[0].checked
				
				
				ding_sound.play() if ding_sound
			_gaq.push ['_trackEvent', 'Game', 'Response Latency', 'Buzz Accepted', new Date - submit_time] if window._gaq
		else
			setActionMode ''
			_gaq.push ['_trackEvent', 'Game', 'Response Latency', 'Buzz Rejected', new Date - submit_time] if window._gaq

$('.score-reset').click ->
	# sock.emit 'resetscore', 'yay'
	me.reset_score()

$('.pausebtn').click ->
	# removeSplash ->
	if !!sync.time_freeze
		# sock.emit 'unpause', 'yay'
		me.unpause()
	else
		# sock.emit 'pause', 'yay'
		me.pause()


$('.chat_input').keydown (e) ->
	if e.keyCode in [47, 111, 191] and $(this).val().length is 0 and !e.shiftKey
		e.preventDefault()
	if e.keyCode in [27] #escape key
		$('.chat_form').submit()


$('input').keydown (e) ->
	e.stopPropagation() #make it so that the event listener doesnt pick up on stuff
	if $(this).hasClass("disabled")
		e.preventDefault()


$('.chat_input').typeahead {
	source: ->
		names = ['alphabet', 'bowl', 'chevrolet', 'darcy', 'encephalogram', 'facetious', 'glistening', 'high', 'jump rope', 'knowledge', 'loquacious', 'melanin', 'narcotic', 'obecalp', 'placebo', 'quiz', 'rapacious', 'singularity', 'time travel', 'underappreciated', 'vestigial', 'wolfram', 'xetharious', 'yonder', 'zeta function']
		("@#{name}" for name in names)
	matcher: (candidate) ->
		this.query[0] == '@' and this.query.split(' ').length is 1
}


$('.chat_input').keyup (e) ->
	return if e.keyCode is 13

	if $('.livechat')[0].checked and $('.chat_input').val().slice(0, 1) != '@'
		$('.chat_input').data('sent_typing', '')
		me.chat {
			text: $('.chat_input').val(), 
			session: $('.chat_input').data('input_session'), 
			done: false
		}
	else if $('.chat_input').data('sent_typing') isnt $('.chat_input').data('input_session')
		me.chat {
			text: '(typing)', 
			session: $('.chat_input').data('input_session'), 
			done: false
		}
		$('.chat_input').data 'sent_typing', $('.chat_input').data('input_session')


$('.chat_form').submit (e) ->
	me.chat {
		text: $('.chat_input').val(), 
		session: $('.chat_input').data('input_session'), 
		done: true
	}
	e.preventDefault()
	setActionMode ''
	time_delta = new Date - $('.chat_input').data('begin_time')
	_gaq.push ['_trackEvent', 'Chat', 'Typing Time', 'Posted Message', time_delta] if window._gaq

$('.guess_input').keyup (e) ->
	return if e.keyCode is 13
	me.guess {
		text: $('.guess_input').val(), 
		done: false
	}

	
$('.guess_form').submit (e) ->
	me.guess {
		text: $('.guess_input').val(), 
		done: true
	}
	e.preventDefault()
	setActionMode ''

$('.prompt_input').keyup (e) ->
	return if e.keyCode is 13
	me.guess {
		text: $('.prompt_input').val(), 
		done: false
	}

	
$('.prompt_form').submit (e) ->
	me.guess {
		text: $('.prompt_input').val(), 
		done: true
	}
	e.preventDefault()
	setActionMode ''


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
		if $('.bundle .start-page').length is 1
			$('.pausebtn').click()	
		else
			$('.buzzbtn').click()
	else if e.keyCode in [83] # S
		skip()
	else if e.keyCode in [78, 74] # N, J
		next()
	else if e.keyCode in [80, 82] # P, R
		$('.pausebtn').click()
	else if e.keyCode in [47, 111, 191, 67, 65] # / (forward slash), C, A
		e.preventDefault()
		$('.chatbtn').click()
	else if e.keyCode in [70] # F
		# sock.emit 'finish', 'yay'
		me.finish()
	else if e.keyCode in [66]
		$('.bundle.active .bookmark').click()

	# console.log e.keyCode


$('.speed').change ->
	$('.speed').not(this).val($(this).val())
	$('.speed').data("last_update", +new Date)
	rate = 1000 * 60 / 5 / Math.round($(this).val())
	# sock.emit 'speed', rate
	me.set_speed rate
	# console.log rate
		
$('.categories').change ->
	if  $('.categories').val() is 'custom'
		createCategoryList()
		$('.custom-category').slideDown()
	else
		$('.custom-category').slideUp()
	me.set_category $('.categories').val()

$('.difficulties').change ->
	me.set_difficulty $('.difficulties').val()

$('.teams').change ->
	if $('.teams').val() is 'create'
		me.set_team prompt('Enter Team Name') || ''
	else
		me.set_team $('.teams').val()

$('.multibuzz').change ->
	sock.emit 'max_buzz', (if $('.multibuzz')[0].checked then null else 1)

$('.livechat').change ->
	sock.emit 'show_typing', $('.livechat')[0].checked

$('.sounds').change ->
	sock.emit 'sounds', $('.sounds')[0].checked


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
