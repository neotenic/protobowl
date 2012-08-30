inner_socket = io.connect() if io?
sync = {}
users = {}
sync_offsets = []
sync_offset = 0

sock = {
	listeners: {},
	disconnect: ->
		if inner_socket.socket.connecting
			virtual_connect = ->
				if virtual_server?
					virtual_server.connect()
				else
					setTimeout virtual_connect, 100
			virtual_connect()
		inner_socket.disconnect()

	emit: (name, data, fn) ->
		if connected()
			inner_socket.emit(name, data, fn)
		else if virtual_server?
			if name of virtual_server
				result = virtual_server[name](data)
				fn(result) if fn
				renderPartial()
			else
				console.log name, data, fn
		else
			if $('.active .not-loaded').length > 0
				el = $('.active .not-loaded')
			else
				el = $('<p>').addClass('not-loaded')
				addImportant el
			el.data 'num', (el.data('num') || 0) + 1
			el.text("Offline component not loaded ")
			if el.data('num') > 1
				el.append($('<span>').addClass('label').text("x"+el.data('num')))

	server_emit: (name, data) ->
		sock.listeners[name](data)

	on: (name, listen) ->
		inner_socket.on(name, listen) if inner_socket?
		sock.listeners[name] = listen
}


unless io?
	#do stuff if socket IO doesnt exist, i.e., it's starting up offline
	$('.new-room').remove()


connected = -> inner_socket? and inner_socket.socket.connected

# $('html').toggleClass 'touchscreen', Modernizr.touch

jQuery.fn.disable = (value) ->
	current = $(this).attr('disabled') is 'disabled'
	if current != value
		$(this).attr 'disabled', value

mobileLayout = -> matchMedia('(max-width: 768px)').matches

avg = (list) ->
	sum(list) / list.length

sum = (list) ->
	s = 0
	s += item for item in list
	s

stdev = (list) ->
	mu = avg(list)
	Math.sqrt avg((item - mu) * (item - mu) for item in list)

cumsum = (list, rate) ->
	s = 0 #start nonzero, allow pause before rendering
	for num in [1].concat(list).slice(0, -1)
		s += Math.round(num) * rate #always round!



# So in this application, we have to juggle around not one, not two, but three notions of time
# (and possibly four if you consider freezable time, which needs a cooler name, like what 
# futurama calls intragnizent, so I'll use that, intragnizent time) anyway. So we have three
# notions of time. The first and simplest is server time, which is an uninterruptable number
# of milliseconds recorded by the server's +new Date. Problem is, that the client's +new Date
# isn't exactly the same (can be a few seconds off, not good when we're dealing with precisions
# of tens of milliseconds). However, we can operate off the assumption that the relative duration
# of each increment of time is the same (as in, the relativistic effects due to players in
# moving vehicles at significant fractions of the speed of light are largely unaccounted for
# in this version of the application), and even imprecise quartz clocks only loose a second
# every day or so, which is perfectly okay in the short spans of minutes which need to go 
# unadjusted. So, we can store the round trip and compare the values and calculate a constant
# offset between the client time and the server time. However, for some reason or another, I
# decided to implement the notion of "pausing" the game by stopping the flow of some tertiary
# notion of time (this makes the math relating to calculating the current position of the read
# somewhat easier).

# This is implemented by an offset which is maintained by the server which goes on top of the
# notion of server time. 

# Why not just use the abstraction of that pausable (tragnizent) time everywhere and forget
# about the abstraction of server time, you may ask? Well, there are two reasons, the first
# of which is that two offsets are maintained anyway (the first prototype only used one, 
# and this caused problems on iOS because certain http requests would have extremely long
# latencies when the user was scrolling, skewing the time, this new system allows the system
# to differentiate a pause from a time skew and maintain a more precise notion of time which
# is calculated by a moving window average of previously observed values)

# The second reason, is that there are times when you actually need server time. Situations
# like when you're buzzing and you have a limited time to answer before your window shuts and
# control gets handed back to the group.


time = -> if sync.time_freeze then sync.time_freeze else serverTime() - sync.time_offset

serverTime = -> new Date - sync_offset


window.onbeforeunload = ->
	if inner_socket?
		localStorage.old_socket = inner_socket.socket.sessionid
	return null

sock.on 'echo', (data, fn) ->
	fn 'alive'

sock.on 'disconnect', ->
	sync.attempt = null if sync.attempt?.user isnt public_id # get rid of any buzzes
	line = $('<div>').addClass 'well'
	line.append $('<p>').append("You were ", $('<span class="label label-important">').text("disconnected"), 
			" from the server for some reason. ", $('<em>').text(new Date))
	line.append $('<p>').append("This may be due to a drop in the network 
			connectivity or a malfunction in the server. The client will automatically 
			attempt to reconnect to the server and in the mean time, the app has automatically transitioned
			into <b>offline mode</b>. You can continue playing alone with a limited offline set
			of questions without interruption. However, you might want to try <a href=''>reloading</a>.")
	addImportant $('<div>').addClass('log disconnect-notice').append(line)
	sock.emit 'init_offline', 'yay' #obviously server wont pay attention to that
	renderState()

sock.on 'application_update', ->
	applicationCache.update() if applicationCache?

public_name = null
public_id = null

sock.on 'connect', ->
	$('.actionbar button').disable false
	$('.timer').removeClass 'disabled'
	$('.disconnect-notice').slideUp()

	sock.emit 'join', {
		old_socket: localStorage.old_socket,
		room_name: channel_name
	}, (data) ->
		public_name = data.name
		public_id = data.id
		$('#username').val public_name
		$('#username').disable false
		# $('.settings').slideDown()



$('#username').keyup ->
	if $(this).val().length > 0
		sock.emit 'rename', $(this).val()

synchronize = (data) ->
	if data
		# console.log JSON.stringify(data)

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

		$('#sync_offset').text(sync_offset.toFixed(1) + '/' + stdev(below).toFixed(1) + " (#{sync_offsets.length})")

		# console.log 'sync', data
		for attr of data
			sync[attr] = data[attr]

	if (data and 'difficulties' of data) or ($('.difficulties')[0].options.length == 0 and sync.difficulties)
		# re-generate the lists, yaaay
		$('.difficulties option').remove()
		$('.difficulties')[0].options.add new Option("Any", '')
		for dif in sync.difficulties
			$('.difficulties')[0].options.add new Option(dif, dif)

		$('.categories option').remove()
		$('.categories')[0].options.add new Option('Everything', '')
		for cat in sync.categories
			$('.categories')[0].options.add new Option(cat, cat)

	$('.categories').val sync.category
	$('.difficulties').val sync.difficulty

	if $('.settings').is(':hidden')
		$('.settings').slideDown()
	
	updateTextAnnotations()
	if !data or 'users' of data
		renderState()
	else
		renderPartial()


	if sync.attempt
		guessAnnotation sync.attempt

	wpm = Math.round(1000 * 60 / 5 / sync.rate)
	if !$('.speed').data('last_update') or new Date - $(".speed").data("last_update") > 1337
		if Math.abs($('.speed').val() - wpm) > 1
			$('.speed').val(wpm)


	
	if !sync.attempt or sync.attempt.user isnt public_id
		setActionMode '' if actionMode in ['guess', 'prompt']
	else
		if sync.attempt.prompt
			if actionMode isnt 'prompt'
				setActionMode 'prompt' 
				$('.prompt_input').val('').focus()
		else
			setActionMode 'guess' if actionMode isnt 'guess'

	# if sync.time_offset isnt null
	# 	$('#time_offset').text(sync.time_offset.toFixed(1))




sock.on 'sync', (data) ->
	synchronize(data)

	
latency_log = []
testLatency = ->
	return unless connected()
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
	setInterval testLatency, 30 * 1000
, 2500

last_question = null

sock.on 'chat', (data) ->
	chatAnnotation data

###
	Correct: 10pts
	Early: 15pts
	Interrupts: -5pts
###

computeScore = (user) ->
	
	CORRECT = 10
	EARLY = 15
	INTERRUPT = -5

	return user.early * EARLY + (user.correct - user.early) * CORRECT + user.interrupts * INTERRUPT


formatTime = (timestamp) ->
	date = new Date
	date.setTime timestamp
	(date.getHours() % 12)+':'+
	('0'+date.getMinutes()).substr(-2,2)+
	#':'+ ('0'+date.getSeconds()).substr(-2,2) +
	(if date.getHours() > 12 then "pm" else "am")


createStatSheet = (user, full) ->
	table = $('<table>').addClass('table headless')
	body = $('<tbody>').appendTo(table)
	row = (name, val) ->
		$('<tr>')
			.appendTo(body)
			.append($("<th>").text(name))
			.append($("<td>").addClass("value").append(val))
	
	row	"Score", $('<span>').addClass('badge').text(computeScore(user))
	row	"Correct", user.correct
	row "Interrupts", user.interrupts
	row "Early", user.early  if full
	row "Incorrect", user.guesses - user.correct  if full
	row "Guesses", user.guesses 
	row "ID", user.id.slice(0, 10) if full
	row "Last Seen", formatTime(user.last_action) if full
	return table


renderState = ->
	if latency_log.length > 0
		$('#latency').text(avg(latency_log).toFixed(1) + "/" + stdev(latency_log).toFixed(1) + " (#{latency_log.length})")

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

		for user in sync.users.sort((a, b) -> computeScore(b) - computeScore(a))
			# console.log user.name, count
			$('.user-' + user.id).text(user.name)
			count++
			row = list.find '.sockid-' + user.id
			list.append row			
			if row.length < 1
				# console.log 'recreating user'
				row = $('<tr>').appendTo list 

				row.popover {
					placement: ->
						if mobileLayout()
							return "top"
						else
							return "left"
					, 
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
			row.attr 'data-original-title', "<span class='user-#{user.id}'>#{user.name}</span>'s stats"

			row.attr 'data-content', $('<div>').append(createStatSheet(user, true)).html()
			row.find('td').remove()
			row.addClass 'sockid-' + user.id
			row.removeClass 'to_remove'
			badge = $('<span>').addClass('badge').text(computeScore(user))
			if user.id is public_id
				#its me, you idiot
				badge.addClass 'badge-info'
				badge.attr 'title', 'You'
				$('.singleuser .stats table').replaceWith(createStatSheet(user, !!$('.singleuser').data('full')))
			else
				if user.online
					if serverTime() - user.last_action > 1000 * 60 * 10
						#the user is idle
						badge.addClass 'badge-warning'
						badge.attr 'title', 'Idle'
					else
						# the user is online
						badge.addClass 'badge-success' 
						badge.attr 'title', 'Online'

			$('<td>').text(count).append('&nbsp;').append(badge).appendTo row
			name = $('<td>').text(user.name)
			# if public_id is user.id
			# 	name.append " "
			# 	name.append $('<span>').addClass('label').text('me')
			name.appendTo row
			$('<td>').text(user.interrupts).appendTo row
			# $('<td>').text(7).appendTo row

		list.find('tr.to_remove').remove()
		# console.log users.join ', '
		# document.querySelector('#users').innerText = users.join(', ')
		if sync.users.length > 1 and connected()
			$('.leaderboard').slideDown()
			$('.singleuser').slideUp()
		else
			$('.leaderboard').slideUp()
			$('.singleuser').slideDown()
			
	#fix all the expandos
	$(window).resize()
	renderPartial()


$('.singleuser').click ->
	$('.singleuser .stats').slideUp().queue ->
		$('.singleuser').data 'full', !$('.singleuser').data('full')
		renderState()

		$(this).dequeue().slideDown()

lastRendering = 0
renderPartial = ->
	if !sync.time_freeze or sync.attempt
		if time() < sync.end_time
			requestAnimationFrame(renderPartial)

			if new Date - lastRendering < 1000 / 20
				return

	lastRendering = +new Date
	return unless sync.question and sync.timing


	#render the question 
	if sync.question isnt last_question
		changeQuestion() #whee slidey
		last_question = sync.question

	if !sync.time_freeze
		removeSplash()

	updateTextPosition()

	#render the time
	renderTimer()
	



updateTextAnnotations = ->
	return unless sync.question and sync.timing

	words = sync.question.split ' '
	early_index = sync.question.replace(/[^ \*]/g, '').indexOf('*')
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


				
updateTextPosition = ->
	return unless sync.question and sync.timing

	timeDelta = time() - sync.begin_time
	words = sync.question.split ' '
	cumulative = cumsum sync.timing, sync.rate
	index = 0
	index++ while timeDelta > cumulative[index]
	# console.log index
	bundle = $('#history .bundle.active') 
	readout = bundle.find('.readout .well')
	children = readout.children()
	if children.length != words.length
		updateTextAnnotations()

	children.slice(0, index).removeClass('unread')
	# children.slice(index).addClass('unread')


window.requestAnimationFrame ||=
  window.webkitRequestAnimationFrame ||
  window.mozRequestAnimationFrame    ||
  window.oRequestAnimationFrame      ||
  window.msRequestAnimationFrame     ||
  (callback, element) ->
    window.setTimeout( ->
      callback(+new Date())
    , 1000 / 60)

setInterval renderState, 5000

# setInterval renderPartial, 50



renderTimer = ->
	# $('#pause').show !!sync.time_freeze
	# $('.buzzbtn').attr 'disabled', !!sync.attempt
	if connected()
		$('.offline').fadeOut()
	else
		$('.offline').fadeIn()
	if sync.time_freeze
		if sync.attempt
			do ->
				cumulative = cumsum sync.timing, sync.rate
				del = sync.attempt.start - sync.begin_time
				i = 0
				i++ while del > cumulative[i]
				starts = ($('.bundle.active').data('starts') || [])
				starts.push(i - 1) if (i - 1) not in starts
				$('.bundle.active').data('starts', starts)

			$('.label.pause').hide()
			$('.label.buzz').fadeIn()

		else
			$('.label.pause').fadeIn()
			$('.label.buzz').hide()

		if $('.pausebtn').hasClass('btn-warning')
			$('.pausebtn .resume').show()
			$('.pausebtn .pause').hide()

			$('.pausebtn')
			.addClass('btn-success')
			.removeClass('btn-warning')

	else
		$('.label.pause').fadeOut()
		$('.label.buzz').fadeOut()
		if $('.pausebtn').hasClass('btn-success')
			$('.pausebtn .resume').hide()
			$('.pausebtn .pause').show()
			$('.pausebtn')
			.addClass('btn-warning')
			.removeClass('btn-success')

	$('.timer').toggleClass 'buzz', !!sync.attempt


	$('.progress').toggleClass 'progress-warning', !!(sync.time_freeze and !sync.attempt)
	$('.progress').toggleClass 'active progress-danger', !!sync.attempt

	
	if sync.attempt
		elapsed = serverTime() - sync.attempt.realTime
		ms = sync.attempt.duration - elapsed
		progress = elapsed / sync.attempt.duration
		$('.pausebtn, .buzzbtn').disable true
	else
		ms = sync.end_time - time()
		elapsed = (time() - sync.begin_time)
		progress = elapsed/(sync.end_time - sync.begin_time)
		$('.pausebtn').disable (ms < 0)
		$('.buzzbtn').disable (ms < 0 or elapsed < 100)
		if ms < 0
			$('.bundle.active').find('.answer').css('display', 'inline').css('visibility', 'visible')
	
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


removeSplash = (fn) ->
	bundle = $('.bundle.active')
	start = bundle.find('.start-page')
	if start.length > 0
		bundle.find('.readout')
			.width(start.width())
			.slideDown 'normal', ->
				$(this).width('auto')

		start.slideUp 'normal', ->
			start.remove()
			fn() if fn
	else
		fn() if fn

changeQuestion = ->
	cutoff = 15
	#smaller cutoff for phones which dont place things in parallel
	cutoff = 1 if mobileLayout()
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
	updateTextPosition()

	if !last_question and sync.time_freeze and sync.time_freeze - sync.begin_time < 500
		# console.log 'loading splash page'
		start = $('<div>').addClass('start-page')
		well = $('<div>').addClass('well').appendTo(start)
		$('<button>')
			.addClass('btn btn-success btn-large')
			.text('Start the Question')
			.appendTo(well)
			.click ->
				removeSplash ->
					$('.pausebtn').click()

		
		bundle.find('.readout').hide().before start

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
	bundle = $('<div>').addClass('bundle')
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
	
	addInfo 'Category', sync.info.category
	addInfo 'Difficulty', sync.info.difficulty
	addInfo 'Tournament', sync.info.year + ' ' + sync.info.tournament

	addInfo sync.info.year + ' ' + sync.info.difficulty + ' ' + sync.info.category
	# addInfo 'Year', sync.info.year
	# addInfo 'Number', sync.info.num
	# addInfo 'Round', sync.info.round
	# addInfo 'Report', ''

	breadcrumb.find('li').last().append $('<span>').addClass('divider hidden-phone').text('/')
	breadcrumb.append $('<li>').addClass('clickable hidden-phone').text('Report').click (e) ->
		console.log 'report question'
		$('#report-question').modal('show')
		e.stopPropagation()
		e.preventDefault()


	breadcrumb.append $('<li>').addClass('pull-right answer').text(sync.answer)

	readout = $('<div>').addClass('readout')
	well = $('<div>').addClass('well').appendTo(readout)
	# well.append $('<span>').addClass('visible')
	# well.append document.createTextNode(' ') #space: the frontier in between visible and unread
	well.append $('<span>').addClass('unread').text(sync.question)
	annotations = $('<div>').addClass 'annotations'
	bundle
		.append($('<ul>').addClass('breadcrumb').append(breadcrumb))
		.append(readout)
		.append(annotations)


userSpan = (user) ->
	$('<span>')
		.addClass('user-'+user)
		.text(users[user]?.name || '[name missing]')

addAnnotation = (el) ->
	el.css('display', 'none').prependTo $('#history .bundle.active .annotations')
	el.slideDown()
	return el

addImportant = (el) ->
	el.css('display', 'none').prependTo $('#history .bundle.active .important')
	el.slideDown()
	return el

guessAnnotation = ({session, text, user, done, correct, interrupt, early, prompt}) ->
	# TODO: make this less like chats
	# console.log("guess annotat", text, done)
	# id = user + '-' + session
	id = "#{user}-#{session}-#{if prompt then 'prompt' else 'guess'}"
	# console.log id
	# console.log id
	if $('#' + id).length > 0
		line = $('#' + id)
	else
		line = $('<p>').attr('id', id)
		marker = $('<span>').addClass('label').text("Buzz")
		if early
			# do nothing, use default
		else if interrupt
			marker.addClass 'label-important'
		else
			marker.addClass 'label-info'
		line.append marker

		prompt_el = $('<a>').addClass('label prompt label-inverse').hide().text('Prompt')
		line.append ' '
		line.append prompt_el
		

		line.append " "
		line.append userSpan(user).addClass('author')
		line.append document.createTextNode ' '
		$('<span>')
			.addClass('comment')
			.appendTo line

		ruling = $('<a>').addClass('label ruling').hide().attr('href', '#')
		line.append ' '
		line.append ruling
		addAnnotation line
	if done
		if text is ''
			line.find('.comment').html('<em>(blank)</em>')
		else
			line.find('.comment').text(text)
	else
		line.find('.comment').text(text)

	if prompt
		line.find('.prompt').show().css('display', 'inline')

	if done
		ruling = line.find('.ruling').show().css('display', 'inline')

		if correct is "prompt"
			ruling.addClass('label-inverse').text('Prompt')
		else if correct
			ruling.addClass('label-success').text('Correct')
		else
			ruling.addClass('label-warning').text('Wrong')

		answer = sync.answer
		ruling.click ->
			$('#review .review-judgement')
				.after(ruling.clone().addClass('review-judgement'))
				.remove()
				
			$('#review .review-answer').text answer
			$('#review .review-response').text text
			$('#review').modal('show')
			return false

		if actionMode is 'guess'
			setActionMode ''
	# line.toggleClass 'typing', !done

chatAnnotation = ({session, text, user, done, time}) ->
	id = user + '-' + session
	if $('#' + id).length > 0
		line = $('#' + id)
	else
		line = $('<p>').attr('id', id)
		line.append userSpan(user).addClass('author').attr('title', formatTime(time))
		line.append document.createTextNode ' '
		$('<span>')
			.addClass('comment')
			.appendTo line
		addAnnotation line
	if done
		if text is ''
			line.find('.comment').html('<em>(no message)</em>')
		else
			line.find('.comment').text(text)
	else
		line.find('.comment').text(text)
	line.toggleClass 'typing', !done

# sock.on 'introduce', ({user}) ->
# 	line = $('<p>').addClass 'log'
# 	line.append userSpan(user)
# 	line.append " joined the room"
# 	addAnnotation line

# sock.on 'leave', ({user}) ->
# 	line = $('<p>').addClass 'log'
# 	line.append userSpan(user)
# 	line.append " left the room"
# 	addAnnotation line

sock.on 'log', ({user, verb}) ->
	line = $('<p>').addClass 'log'
	line.append userSpan(user)
	line.append " " + verb
	addAnnotation line

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
		.val('')
		.focus()

skip = ->
	removeSplash()
	sock.emit 'skip', 'yay'

next = ->
	removeSplash()
	sock.emit 'next', 'yay'

$('.skipbtn').click skip

$('.nextbtn').click next

$('.buzzbtn').click ->
	return if $('.buzzbtn').attr('disabled') is 'disabled'
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
	sock.emit 'buzz', 'yay', (status) ->
		if status is 'http://www.whosawesome.com/'
			$('.guess_input').removeClass('disabled')
		else
			setActionMode ''



$('.pausebtn').click ->
	removeSplash ->
		if !!sync.time_freeze
			sock.emit 'unpause', 'yay'
		else
			sock.emit 'pause', 'yay'


$('.chat_input').keydown (e) ->
	if e.keyCode in [47, 111, 191] and $(this).val().length is 0
		e.preventDefault()


$('input').keydown (e) ->
	e.stopPropagation() #make it so that the event listener doesnt pick up on stuff
	if $(this).hasClass("disabled")
		e.preventDefault()



$('.chat_input').keyup (e) ->
	return if e.keyCode is 13
	sock.emit 'chat', {
		text: $('.chat_input').val(), 
		session: $('.chat_input').data('input_session'), 
		done: false
	}

$('.chat_form').submit (e) ->
	sock.emit 'chat', {
		text: $('.chat_input').val(), 
		session: $('.chat_input').data('input_session'), 
		done: true
	}
	e.preventDefault()
	setActionMode ''

$('.guess_input').keyup (e) ->
	return if e.keyCode is 13
	sock.emit 'guess', {
		text: $('.guess_input').val(), 
		done: false
	}

	
$('.guess_form').submit (e) ->
	sock.emit 'guess', {
		text: $('.guess_input').val(), 
		done: true
	}
	e.preventDefault()
	setActionMode ''

$('.prompt_input').keyup (e) ->
	return if e.keyCode is 13
	sock.emit 'guess', {
		text: $('.prompt_input').val(), 
		done: false
	}

	
$('.prompt_form').submit (e) ->
	sock.emit 'guess', {
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
	else if e.keyCode in [47, 111, 191, 67] # / (forward slash), C
		e.preventDefault()
		$('.chatbtn').click()
	else if e.keyCode in [66]
		$('.bundle.active .bookmark').click()

	# console.log e.keyCode


$('.speed').change ->
	$('.speed').not(this).val($(this).val())
	$('.speed').data("last_update", +new Date)
	rate = 1000 * 60 / 5 / Math.round($(this).val())
	sock.emit 'speed', rate
	# console.log rate
		
$('.categories').change ->
	sock.emit 'category', $('.categories').val()

$('.difficulties').change ->
	sock.emit 'difficulty', $('.difficulties').val()

# possibly this should be replaced by something smarter using CSS calc()
# but that would be a 
$(window).resize ->
	$('.expando').each ->
		add = sum($(i).outerWidth() for i in $(this).find('.add-on, .padd-on'))
		# console.log add
		size = $(this).width()
		input = $(this).find('input, .input')
		if input.hasClass 'input'
			outer = 0
		else
			outer = input.outerWidth() - input.width()
		# console.log 'exp', input, add, outer, size
		if Modernizr.csscalc
			input.css('width', "-webkit-calc(100% - #{outer + add}px)")
			input.css('width', "-moz-calc(100% - #{outer + add}px)")
			input.css('width', "-o-calc(100% - #{outer + add}px)")
			input.css('width', "calc(100% - #{outer + add}px)")
			
		else
			input.width size - outer - add


$(window).resize()

#ugh, this is fugly, maybe i should have used calc
setTimeout ->
	$(window).resize()
, 762 

#display a tooltip for keyboard shortcuts on keyboard machines
if !Modernizr.touch and !mobileLayout()
	$('.actionbar button').tooltip()
	# hide crap when clicked upon
	$('.actionbar button').click -> 
		$('.actionbar button').tooltip 'hide'

	$('#history, .settings').tooltip({
		selector: "[rel=tooltip]", 
		placement: -> 
			if mobileLayout() then "error" else "left"
	})


if Modernizr.touch
	$('.show-keyboard').hide()
	$('.show-touch').show()
else
	$('.show-keyboard').show()
	$('.show-touch').hide()


handleCacheEvent = ->
	status = applicationCache.status
	switch applicationCache.status
		when applicationCache.UPDATEREADY
			$('#cachestatus').text 'Updated'
			console.log 'update is ready'
			applicationCache.swapCache()
			$('#update').slideDown()		
			
			if localStorage.auto_reload is "yay"
				setTimeout ->
					location.reload()
				, 500
		when applicationCache.UNCACHED
			$('#cachestatus').text 'Uncached'
		when applicationCache.OBSOLETE
			$('#cachestatus').text 'Obsolete'
		when applicationCache.IDLE
			$('#cachestatus').text 'Cached'
		when applicationCache.DOWNLOADING
			$('#cachestatus').text 'Downloading'
		when applicationCache.CHECKING
			$('#cachestatus').text 'Checking'

do -> # isolate variables from globals
	if window.applicationCache
		for name in ['cached', 'checking', 'downloading', 'error', 'noupdate', 'obsolete', 'progress', 'updateready']
			applicationCache.addEventListener name, handleCacheEvent

# asynchronously load offline components
#also, html5slider isnt actually for offline,
# but it can be loaded async, so lets do that, 
# and reuse all the crap that can be reused
setTimeout ->
	window.exports = {}
	window.require = -> window.exports
	deps = ["html5slider", "levenshtein", "removeDiacritics", "porter", "answerparse", "syllable", "names", "offline"]
	loadNextResource = ->
		$.ajax {
			url: "lib/#{deps.shift()}.js",
			cache: true,
			dataType: "script",
			success: ->
				if deps.length > 0
					loadNextResource()
		}
	loadNextResource()
, 10

