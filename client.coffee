sock = io.connect()
sync = {}
users = {}
sync_offsets = []
sync_offset = 0


# $('html').toggleClass 'touchscreen', Modernizr.touch

generateName = ->
	adjective = 'flaming,aberrant,agressive,warty,hoary,breezy,dapper,edgy,feisty,gutsy,hardy,intrepid,jaunty,karmic,lucid,maverick,natty,oneric,precise,quantal,quizzical,curious,derisive,bodacious,nefarious,nuclear,nonchalant'
	animal = 'monkey,axolotl,warthog,hedgehog,badger,drake,fawn,gibbon,heron,ibex,jackalope,koala,lynx,meerkat,narwhal,ocelot,penguin,quetzal,kodiak,cheetah,puma,jaguar,panther,tiger,leopard,lion,neanderthal,walrus,mushroom,dolphin'
	pick = (list) -> 
		n = list.split(',')
		n[Math.floor(n.length * Math.random())]
	pick(adjective) + " " + pick(animal)

public_name = generateName()
$('#username').val public_name
$('#username').keydown (e) ->
	e.stopPropagation()

$('#username').keyup ->
	if $(this).val().length > 0
		sock.emit 'rename', $(this).val()

avg = (list) ->
	sum = 0
	sum += item for item in list
	sum / list.length

stdev = (list) ->
	mu = avg(list)
	Math.sqrt avg((item - mu) * (item - mu) for item in list)

cumsum = (list, rate) ->
	sum = 0
	for num in list
		sum += Math.round(num) * rate #always round!

###
	So in this application, we have to juggle around not one, not two, but three notions of time
	(and possibly four if you consider freezable time, which needs a cooler name, like what 
	futurama calls intragnizent, so I'll use that, intragnizent time) anyway. So we have three
	notions of time. The first and simplest is server time, which is an uninterruptable number
	of milliseconds recorded by the server's +new Date. Problem is, that the client's +new Date
	isn't exactly the same (can be a few seconds off, not good when we're dealing with precisions
	of tens of milliseconds). However, we can operate off the assumption that the relative duration
	of each increment of time is the same (as in, the relativistic effects due to players in
	moving vehicles at significant fractions of the speed of light are largely unaccounted for
	in this version of the application), and even imprecise quartz clocks only loose a second
	every day or so, which is perfectly okay in the short spans of minutes which need to go 
	unadjusted. So, we can store the round trip and compare the values and calculate a constant
	offset between the client time and the server time. However, for some reason or another, I
	decided to implement the notion of "pausing" the game by stopping the flow of some tertiary
	notion of time (this makes the math relating to calculating the current position of the read
	somewhat easier).

	This is implemented by an offset which is maintained by the server which goes on top of the
	notion of server time. 

	Why not just use the abstraction of that pausable (tragnizent) time everywhere and forget
	about the abstraction of server time, you may ask? Well, there are two reasons, the first
	of which is that two offsets are maintained anyway (the first prototype only used one, 
	and this caused problems on iOS because certain http requests would have extremely long
	latencies when the user was scrolling, skewing the time, this new system allows the system
	to differentiate a pause from a time skew and maintain a more precise notion of time which
	is calculated by a moving window average of previously observed values)

	The second reason, is that there are times when you actually need server time. Situations
	like when you're buzzing and you have a limited time to answer before your window shuts and
	control gets handed back to the group.
###



time = -> if sync.time_freeze then sync.time_freeze else serverTime() - sync.time_offset

serverTime = -> new Date - sync_offset


window.onbeforeunload = ->
	localStorage.old_socket = sock.socket.sessionid
	return null

sock.on 'echo', (data, fn) ->
	fn 'alive'

sock.on 'disconnect', ->
	# make it so that refreshes dont show disco flash
	setTimeout ->
		$('#disco').modal('show')
	, 1000

sock.once 'connect', ->
	$('.actionbar button').attr 'disabled', false
	sock.emit 'join', {
		old_socket: localStorage.old_socket,
		room_name: channel_name,
		public_name: public_name
	}


sock.on 'sync', (data) ->
	#here is the rather complicated code to calculate
	#then offsets of the time synchronization stuff
	#it's totally not necessary to do this, but whatever
	#it might make the stuff work better when on an
	#apple iOS device where screen drags pause the
	#recieving of sockets/xhrs meaning that the sync
	#might be artificially inflated, so this could
	#counteract that. since it's all numerical math
	#hopefully it'll be fast even if sync_offsets becomes
	#really really huge
	sync_offsets.push +new Date - data.real_time
	thresh = avg sync_offsets
	below = (item for item in sync_offsets when item <= thresh)
	sync_offset = avg(below)

	$('#sync_offset').text(sync_offset.toFixed(1) + '/' + stdev(below).toFixed(1))

	# console.log 'sync', data
	for attr of data
		sync[attr] = data[attr]
	if 'users' of data
		renderState()
	else
		renderPartial()
	if sync.time_offset isnt null
		$('#time_offset').text(sync.time_offset.toFixed(1))


latency_log = []
testLatency = ->
	initialTime = +new Date
	sock.emit 'echo', {}, (firstServerTime) ->
		recieveTime = +new Date
		sock.emit 'echo', {}, (secondServerTime) ->
			secondTime = +new Date
			CSC1 = recieveTime - initialTime
			CSC2 = secondTime - recieveTime
			SCS1 = secondServerTime - firstServerTime
			latency_log.push CSC1
			latency_log.push SCS1
			latency_log.push CSC2
			# console.log CSC1, SCS1, CSC2

setTimeout ->
	testLatency()
	setInterval testLatency, 60 * 1000
, 2500

last_question = null

sock.on 'chat', (data) ->
	chatAnnotation data


computeScore = (user) ->
	user.correct * 15 - user.interrupts * 5

renderState = ->
	# render the user list and that stuff
	if sync.users
		for user in sync.users
			votes = []
			for action of sync.voting
				if user.id in sync.voting[action]
					votes.push action
			user.votes = votes.join(', ')
			users[user.id] = user

			# user.name + " (" + user.id + ") " + votes.join(", ")
		list = $('.leaderboard tbody')
		# list.find('tr').remove() #abort all people
		count = 0
		list.find('tr').addClass 'to_remove'

		for user in sync.users.sort((a, b) -> computeScore(b) - computeScore(b))
			$('.user-' + user.id).text(user.name)
			count++
			row = list.find '.sockid-' + user.id
			if row.length < 1
				console.log 'recreating user'
				row = $('<tr>').appendTo list 

				row.popover {
					placement: ->
						if matchMedia('(max-width: 768px)').matches
							return "top"
						else
							return "left"
					, 
					title: user.name + "'s stats",
					trigger: 'manual'
				}
				row.click ->
					$('.leaderboard tbody tr').not(this).popover 'hide'
					$(this).popover 'toggle'

				# row.mouseover (e) ->
				# 	$('.leaderboard tbody tr').not(this).popover 'hide'
				# 	if $(this).data('popover'),$(this).data('popover').tip().hasClass('out')
				# 		$(this).popover 'show'
				# row.mouseout (e) ->
				# 	console.log $(this).data('popover'),$(this).data('popover').tip().hasClass('in')
				# 	# $(this).popover 'hide'

			row.attr 'data-content', "User ID: #{user.id}\n
										Correct: #{user.correct}\n
										Incorrect: #{user.guesses - user.correct}\n
										Interrupts: #{user.interrupts}\n
										Guesses: #{user.guesses}".replace(/\n/g, '<br>')
			row.find('td').remove()
			row.addClass 'sockid-' + user.id
			row.removeClass 'to_remove'
			badge = $('<span>').addClass('badge').text(computeScore(user))
			badge.addClass 'badge-success' if user.id is sock.socket.sessionid #green if me
			$('<td>').text(count).append('&nbsp;').append(badge).appendTo row
			$('<td>').text(user.name).appendTo row
			$('<td>').text(user.interrupts).appendTo row
			# $('<td>').text(7).appendTo row

		list.find('tr.to_remove').remove()
		# console.log users.join ', '
		# document.querySelector('#users').innerText = users.join(', ')

	renderPartial()

renderPartial = ->
	return unless sync.question and sync.timing
	
	#render the question 
	if sync.question isnt last_question
		changeQuestion() #whee slidey
		last_question = sync.question
	timeDelta = time() - sync.begin_time
	words = sync.question.split ' '
	{list, rate} = sync.timing
	cumulative = cumsum list, rate
	index = 0
	index++ while timeDelta > cumulative[index]
	# index++ if timeDelta > cumulative[0]
	bundle = $('#history .bundle.active') #$('#history .bundle').first()
	new_text = words.slice(0, index).join(' ')
	old_text = bundle.find('.readout .visible').text().replace(/\s+/g, ' ')
	#this more complicated system allows text selection
	#while it's still reading out stuff
	# for word in words.slice(0, index)
	spots = for buzz in (bundle.data('starts') || [])
		del = buzz - sync.begin_time
		i = 0
		i++ while del > cumulative[i]
		i - 1

	visible = bundle.find('.readout .visible')
	old_spots = visible.data('spots') is spots.join(',')
	if new_text isnt old_text or !old_spots
		# console.log spots
		if new_text.indexOf(old_text.trim()) is 0 and old_spots
			bundle.find('.readout .visible').append(new_text.slice old_text.length)
		else
			# console.log 'redo'
			visible.data('spots', spots.join(','))
			visible.text ''
			for i in [0...index]
				visible.append(words[i] + " ")
				if i in spots
					# visible.append('<span class="label label-important">'+words[i]+'</span> ')
					visible.append ' <span class="buzzicon label label-important"><i class="icon-white icon-bell"></i></span> '
		

	# if new_text isnt old_text
	# 	if new_text.indexOf(old_text) is 0
	# 		node = bundle.find('.readout .visible')[0]
	# 		change = new_text.slice old_text.length
	# 		node.appendChild document.createTextNode(change)
	# 	else
	# 		bundle.find('.readout .visible').text new_text
	bundle.find('.readout .unread').text words.slice(index).join(' ')
	#render the time
	renderTimer()
	

	# manipulate the action bar
	# $('.pausebtn, .buzzbtn').attr 'disabled', !!sync.attempt
	if sync.attempt
		guessAnnotation sync.attempt


	if latency_log.length > 0
		$('#latency').text(avg(latency_log).toFixed(1) + "/" + stdev(latency_log).toFixed(1))

	


setInterval renderState, 10000
setInterval renderPartial, 50

renderTimer = ->
	# $('#pause').show !!sync.time_freeze
	# $('.buzzbtn').attr 'disabled', !!sync.attempt
	if sync.time_freeze
		if sync.attempt
			
			starts = ($('.bundle.active').data('starts') || [])
			starts.push(sync.attempt.start) if sync.attempt.start not in starts
			$('.bundle.active').data('starts', starts)

			$('.label.pause').hide()
			$('.label.buzz').fadeIn()

		else
			$('.label.pause').fadeIn()
			$('.label.buzz').hide()

		if $('.pausebtn').text() != 'Resume'
			$('.pausebtn')
			.text('Resume')
			.addClass('btn-success')
			.removeClass('btn-warning')

	else
		$('.label.pause').fadeOut()
		$('.label.buzz').fadeOut()
		if $('.pausebtn').text() != 'Pause'
			$('.pausebtn')
			.text('Pause')
			.addClass('btn-warning')
			.removeClass('btn-success')

	$('.timer').toggleClass 'buzz', !!sync.attempt


	$('.progress').toggleClass 'progress-warning', !!(sync.time_freeze and !sync.attempt)
	$('.progress').toggleClass 'progress-danger', !!sync.attempt
	
	

	if sync.attempt
		elapsed = serverTime() - sync.attempt.realTime
		ms = sync.attempt.duration - elapsed
		progress = elapsed / sync.attempt.duration
		$('.pausebtn, .buzzbtn').attr 'disabled', true
	else
		ms = sync.end_time - time()
		progress = (time() - sync.begin_time)/(sync.end_time - sync.begin_time)
		$('.pausebtn, .buzzbtn').attr 'disabled', (ms < 0)
		if ms < 0
			$('.bundle.active').find('.answer').css('visibility', 'visible')
	
	if $('.progress .bar').hasClass 'pull-right'
		$('.progress .bar').width (1 - progress) * 100 + '%'
	else
		$('.progress .bar').width progress * 100 + '%'

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

changeQuestion = ->
	cutoff = 15
	#smaller cutoff for phones which dont place things in parallel
	cutoff = 1 if matchMedia('(max-width: 768px)').matches
	#remove the old crap when it's really old (and turdy)
	$('.bundle').slice(cutoff).slideUp 'normal', -> 
			$(this).remove()
	old = $('#history .bundle').first()
	# old.find('.answer').css('visibility', 'visible')
	old.removeClass 'active'
	old.find('.breadcrumb').click -> 1 # register a empty event handler so touch devices recognize
	#merge the text nodes, perhaps for performance reasons
	bundle = createBundle().width($('#history').width()) #.css('display', 'none')
	bundle.addClass 'active'
	$('#history').prepend bundle.hide()
	
	
	bundle.slideDown("slow").queue ->
		bundle.width('auto')
		$(this).dequeue()
	if old.find('.readout').length > 0
		old.find('.readout')[0].normalize() 
		
		old.queue ->
			old.find('.readout').slideUp("slow")
			$(this).dequeue()

createBundle = ->
	breadcrumb = $('<ul>').addClass('breadcrumb')
	addInfo = (name, value) ->
		breadcrumb.find('li').last().append $('<span>').addClass('divider').text('/')
		breadcrumb.append $('<li>').text(name + ": " + value)
	
	addInfo 'Category', sync.info.category
	addInfo 'Difficulty', sync.info.difficulty
	addInfo 'Tournament', sync.info.year + ' ' + sync.info.tournament
	# addInfo 'Year', sync.info.year
	# addInfo 'Number', sync.info.num
	# addInfo 'Round', sync.info.round
	breadcrumb.append $('<li>').addClass('answer pull-right')
		.text("Answer: " + sync.answer)
	readout = $('<div>').addClass('readout')
	well = $('<div>').addClass('well').appendTo(readout)
	well.append $('<span>').addClass('visible')
	well.append document.createTextNode(' ') #space: the frontier in between visible and unread
	well.append $('<span>').addClass('unread').text(sync.question)
	annotations = $('<div>').addClass 'annotations'
	$('<div>').addClass('bundle')
		.append(breadcrumb)
		.append(readout)
		.append(annotations)


userSpan = (user) ->
	$('<span>')
		.addClass('user-'+user)
		.text(users[user]?.name || '[name missing]')

addAnnotation = (el) ->
	el.css('display', 'none').prependTo $('#history .bundle .annotations').first()
	el.slideDown()
	return el


guessAnnotation = ({session, text, user, final, correct}) ->
	# TODO: make this less like chats
	id = user + '-' + session
	if $('#' + id).length > 0
		line = $('#' + id)
	else
		line = $('<p>').attr('id', id)
		line.append $('<span>').addClass('label label-important').text("Buzz")
		line.append " "
		line.append userSpan(user).addClass('author')
		line.append document.createTextNode ' '
		$('<span>')
			.addClass('comment')
			.appendTo line
		ruling = $('<span>').addClass('label ruling').hide()
		line.append ' '
		line.append ruling
		addAnnotation line
	if final
		if text is ''
			line.find('.comment').html('<em>(blank)</em>')
		else
			line.find('.comment').text(text)
	else
		line.find('.comment').text(text)
	if final
		ruling = line.find('.ruling').show()
		if correct
			ruling.addClass('label-success').text('Correct')
		else
			ruling.addClass('label-warning').text('Wrong')
		if actionMode is 'guess'
			setActionMode ''
	# line.toggleClass 'typing', !final

chatAnnotation = ({session, text, user, final}) ->
	id = user + '-' + session
	if $('#' + id).length > 0
		line = $('#' + id)
	else
		line = $('<p>').attr('id', id)
		line.append userSpan(user).addClass('author')
		line.append document.createTextNode ' '
		$('<span>')
			.addClass('comment')
			.appendTo line
		addAnnotation line
	if final
		if text is ''
			line.find('.comment').html('<em>(no message)</em>')
		else
			line.find('.comment').text(text)
	else
		line.find('.comment').text(text)
	line.toggleClass 'typing', !final

sock.on 'introduce', ({user}) ->
	line = $('<p>').addClass 'log'
	line.append userSpan(user)
	line.append " joined the room"
	addAnnotation line

sock.on 'leave', ({user}) ->
	line = $('<p>').addClass 'log'
	line.append userSpan(user)
	line.append " left the room"
	addAnnotation line

# chatAnnotationOld = (name, text) ->
# 	line = $('<p>')
# 	$('<span>').addClass('author').text(name+" ").appendTo line
# 	$('<span>').addClass('comment').text(text).appendTo line
# 	addAnnotation line




jQuery('.bundle .breadcrumb').live 'click', ->
	unless $(this).is jQuery('.bundle .breadcrumb').first()
		readout = $(this).parent().find('.readout')
		readout.width($('#history').width()).slideToggle "slow", ->
			readout.width 'auto'

actionMode = ''
setActionMode = (mode) ->
	actionMode = mode
	$('.guess_input, .chat_input').blur()
	$('.actionbar' ).toggle mode is ''
	$('.chat_form').toggle mode is 'chat'
	$('.guess_form').toggle mode is 'guess'
	$(window).resize() #reset expandos

$('.chatbtn').click ->
	setActionMode 'chat'
	# create a new input session id, which helps syncing work better
	$('.chat_input')
		.data('input_session', Math.random().toString(36).slice(3))
		.val('')
		.focus()

$('.skipbtn').click ->
	sock.emit 'skip', 'yay'


$('.buzzbtn').click ->
	return if $('.buzzbtn').attr('disabled') is 'disabled'
	setActionMode 'guess'
	$('.guess_input')
		.val('')
		.focus()
	# so it seems that on mobile devices with on screen virtual keyboards
	# if your focus isn't event initiated (eg. based on the callback of
	# some server query to confirm control of the textbox) it wont actualy
	# bring up the keyboard, so the solution here is to first open it up
	# and ask nicely for forgiveness otherwise
	sock.emit 'buzz', 'yay', (data) ->
		if data isnt 'http://www.whosawesome.com/'
			setActionMode ''
			console.log 'you arent cool enough'
			# TODO: disable buzz and continue/pause buttons when in a buzz
			# $('.buzzbtn').attr 'disabled', true

$('.pausebtn').click ->
	if !!sync.time_freeze
		console.log 'unapuse'
		sock.emit 'unpause', 'yay'
	else
		sock.emit 'pause', 'yay'


$('input').keydown (e) ->
	e.stopPropagation() #make it so that the event listener doesnt pick up on stuff

$('.chat_input').keyup (e) ->
	return if e.keyCode is 13
	sock.emit 'chat', {
		text: $('.chat_input').val(), 
		session: $('.chat_input').data('input_session'), 
		final: false
	}

$('.chat_form').submit (e) ->
	sock.emit 'chat', {
		text: $('.chat_input').val(), 
		session: $('.chat_input').data('input_session'), 
		final: true
	}
	e.preventDefault()
	setActionMode ''

$('.guess_input').keyup (e) ->
	return if e.keyCode is 13
	sock.emit 'guess', {
		text: $('.guess_input').val(), 
		final: false
	}

	
$('.guess_form').submit (e) ->
	sock.emit 'guess', {
		text: $('.guess_input').val(), 
		final: true
	}
	e.preventDefault()
	setActionMode ''

$('body').keydown (e) ->
	if actionMode is 'chat'
		return $('.chat_input').focus()

	if actionMode is 'guess'
		return $('.guess_input').focus()
	
	return if e.shiftKey or e.ctrlKey or e.metaKey

	if e.keyCode is 32
		e.preventDefault()
		$('.buzzbtn').click()
	else if e.keyCode in [83, 78, 74] # S, N, J
		$('.skipbtn').click()
	else if e.keyCode in [80, 82] # P, R
		$('.pausebtn').click()
	else if e.keyCode in [47, 111, 191, 67] # / (forward slash), C
		console.log "slash"
		e.preventDefault()
		$('.chatbtn').click()

	console.log e.keyCode


# possibly this should be replaced by something smarter using CSS calc()
# but that would be a 
$(window).resize ->
	$('.expando').each ->
		add = $(this).find('.add-on').outerWidth()
		size = $(this).width()
		outer = $(this).find('input').outerWidth() - $(this).find('input').width()
		$(this).find('input').width size - outer - add

$(window).resize()

#display a tooltip for keyboard shortcuts on keyboard machines
unless Modernizr.touch
	$('.actionbar button').tooltip()
	# hide crap when clicked upon
	$('.actionbar button').click -> 
		$('.actionbar button').tooltip 'hide'


if Modernizr.touch
	$('.show-keyboard').hide()
	$('.show-touch').show()
else
	$('.show-keyboard').show()
	$('.show-touch').hide()