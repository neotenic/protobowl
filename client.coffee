sock = io.connect()
sync = {}
users = {}
sync_offsets = []
sync_offset = 0

is_touch = !!('ontouchstart' in window)
$('html').toggleClass 'touchscreen', is_touch

generateName = ->
	adjective = 'flaming,aberrant,agressive,warty,hoary,breezy,dapper,edgy,feisty,gutsy,hardy,intrepid,jaunty,karmic,lucid,maverick,natty,oneric,precise,quantal,quizzical,curious,derisive,bodacious,nefarious'
	animal = 'monkey,axolotl,warthog,hedgehog,badger,drake,fawn,gibbon,heron,ibex,jackalope,koala,lynx,meerkat,narwhal,ocelot,penguin,quetzal,kodiak,cheetah,puma,jaguar,panther,tiger,leopard,lion,neandertal'
	pick = (list) -> 
		n = list.split(',')
		n[Math.floor(n.length * Math.random())]
	pick(adjective) + " " + pick(animal)

public_name = generateName()
$('#username').val public_name
$('#username').keydown (e) ->
	e.stopPropagation()

$('#username').keyup ->
	console.log 'renaming'
	sock.emit 'rename', $(this).val()

avg = (list) ->
	sum = 0
	sum += item for item in list
	sum / list.length

cumsum = (list, rate) ->
	sum = 0
	for num in list
		sum += Math.round(num) * rate #always round!

time = ->
	return if sync.time_freeze then sync.time_freeze else new Date - sync_offset - sync.time_offset


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

	$('#sync_offset').text(sync_offset.toFixed(1) + '/' + thresh.toFixed(1))


	console.log 'sync', data
	for attr of data
		sync[attr] = data[attr]
	renderState()

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
		for user in sync.users
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
					trigger: 'manual',
					content: 'well, they dont exist. sorry. '+ user.id
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
			row.find('td').remove()
			row.addClass 'sockid-' + user.id
			row.removeClass 'to_remove'

			$('<td>').text(count).appendTo row
			$('<td>').text(user.name).appendTo row
			$('<td>').text(user.votes || 0).appendTo row
			$('<td>').text(7).appendTo row

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
	index++ if timeDelta > cumulative[0] / 2
	bundle = $('#history .bundle').first()
	new_text = words.slice(0, index).join(' ')
	old_text = bundle.find('.readout .visible').text()
	#this more complicated system allows text selection
	#while it's still reading out stuff
	if new_text isnt old_text
		if new_text.indexOf old_text is 0
			node = bundle.find('.readout .visible')[0]
			change = new_text.slice old_text.length
			node.appendChild document.createTextNode(change)
		else
			bundle.find('.readout .visible').text new_text
		bundle.find('.readout .unread').text words.slice(index).join(' ')
	#render the time
	renderTimer sync.end_time - time()
	progress = (time() - sync.begin_time)/(sync.end_time - sync.begin_time)
	# console.log progress
	$('.progress .bar').width progress * 100 + '%'

	if latency_log.length > 0
		$('#latency').text(avg(latency_log).toFixed(1))

	


setInterval renderState, 10000
setInterval renderPartial, 50

renderTimer = (ms) ->
	# $('#pause').show !!sync.time_freeze
	if sync.time_freeze
		$('#pause').fadeIn()
	else
		$('#pause').fadeOut()

	$('.progress').toggleClass 'progress-warning', !!sync.time_freeze
	# $('.progress').toggleClass 'active', ms < 0
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
	cutoff = 10
	#smaller cutoff for phones which dont place things in parallel
	cutoff = 1 if matchMedia('(max-width: 768px)').matches
	#remove the old crap when it's really old (and turdy)
	$('.bundle').slice(cutoff).slideUp 'normal', -> 
			$(this).remove()
	old = $('#history .bundle').first()
	# old.find('.answer').css('visibility', 'visible')
	old.removeClass 'active'
	#merge the text nodes, perhaps for performance reasons
	if old.find('.readout').length > 0
		old.find('.readout')[0].normalize() 
	old.find('.readout').slideUp('slow')
	bundle = createBundle().width($('#history').width()) #.css('display', 'none')
	bundle.addClass 'active'
	$('#history').prepend bundle.hide()
	bundle.slideDown('slow')
	bundle.width('auto')


createBundle = ->
	breadcrumb = $('<ul>').addClass('breadcrumb')
	addInfo = (name, value) ->
		breadcrumb.find('li').last().append $('<span>').addClass('divider').text('/')
		breadcrumb.append $('<li>').text(name + ": " + value)
	addInfo 'Category', sync.info.category
	addInfo 'Difficulty', sync.info.difficulty
	addInfo 'Tournament', sync.info.tournament
	addInfo 'Year', sync.info.year
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
		.text(users[user].name)

addAnnotation = (el) ->
	el.css('display', 'none').prependTo $('#history .bundle .annotations').first()
	el.slideDown()
	return el


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
		$(this).parent().find('.readout').slideToggle()

$('.main_input').keydown (e) ->
	e.stopPropagation()

$('.main_input').keyup (e) ->
	mode = $('.main_input').data('mode')
	if mode is 'buzz'
		if e.keyCode is 13
			sock.emit 'guess', {text: $(this).val(), final: true}
			$('.main_input').attr('disabled', true).val('').blur()
			$('.main_input').data('mode', '')
		else
			sock.emit 'guess', {text: $(this).val()}
	else if mode is 'chat'
		val = $(this).val().replace(/^.*?: ?/g, '')
		if e.keyCode is 13
			sock.emit 'chat', {text: val, final: true, session: $(this).data('input_session')}
			$('.main_input').attr('disabled', true).val('').blur()
			$('.main_input').data('mode', '')
		else
			sock.emit 'chat', {text: val, session: $(this).data('input_session')}

$('body').keydown (e) ->
	mode = $('.main_input').data('mode')
	if mode is 'chat'
		$('.main_input').focus()
		return
	if e.keyCode is 32
		sock.emit 'buzz', 'MARP', (result) ->
			console.log result
			$('.main_input').data('mode', 'buzz')
			$('.main_input').attr('disabled', false).focus()
		e.preventDefault()
	else if e.keyCode is 83 # S
		sock.emit 'skip', 'yay'
	else if e.keyCode is 80 # P
		sock.emit 'pause', 'yay'
	else if e.keyCode is 90 # Z
		sock.emit 'unpause', 'yay'
	else if e.keyCode in [47, 111, 191] # / (forward slash)
		console.log "slash"
		e.preventDefault()
		$('.main_input').data('mode', 'chat')
		$('.main_input').data('input_session', Math.random().toString(36).slice(3))
		$('.main_input').attr('disabled', false).val('chat: ').focus()
	
	# console.log e
