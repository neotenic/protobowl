sock = io.connect()
sync = {}
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

sock.on 'connect', ->
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

	console.log 'sync', data
	for attr of data
		sync[attr] = data[attr]
	renderState()


last_question = null

renderState = ->
	# render the user list and that stuff
	if sync.users
		for user in sync.users
			votes = []
			for action of sync.voting
				if user.id in sync.voting[action]
					votes.push action
			user.votes = votes.join(', ')
			# user.name + " (" + user.id + ") " + votes.join(", ")
		list = $('.leaderboard tbody')
		list.find('tr').remove() #abort all people
		count = 0
		for user in sync.users
			count++
			row = $('<tr>').appendTo list
			$('<td>').text(count).appendTo row
			$('<td>').text(user.name).appendTo row
			$('<td>').text(user.votes || 0).appendTo row
			$('<td>').text(7).appendTo row
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

	


setInterval renderState, 1000
setInterval renderPartial, 50

renderTimer = (ms) ->
	
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

chatAnnotation = (name, text) ->
	line = $('<p>')
	$('<span>').addClass('author').text(name+" ").appendTo line
	$('<span>').addClass('comment').text(text).appendTo line
	addAnnotation line

addAnnotation = (el) ->
	el.css('display', 'none').prependTo $('#history .bundle .annotations').first()
	el.slideDown()



jQuery('.bundle .breadcrumb').live 'click', ->
	unless $(this).is jQuery('.bundle .breadcrumb').first()
		$(this).parent().find('.readout').slideToggle()

document.addEventListener 'keydown', (e) ->
	if e.keyCode is 32 #space = skip
		sock.emit 'skip', 'yay'
		e.preventDefault()
	else if e.keyCode is 80
		sock.emit 'pause', 'yay'
	else if e.keyCode is 90
		sock.emit 'unpause', 'yay'


# $('.leaderboard tbody tr').live 'click', ->

# $('.leaderboard').popover {
# 	placement: "left",
# 	selector: ".leaderboard tbody tr"
# }

$('.leaderboard tbody tr').popover {
	placement: "left"
}

# get em out of phase
# n = 0
# setInterval ->
# 	if n++ % 4 == 0
# 		transitionQuestion()
# 	else
# 		chatAnnotation('cucumber', 'im a dumb dinosaur '+ n)
# , 1000


