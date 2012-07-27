sock = io.connect()
sync = {}
sync_offsets = []
sync_offset = 0

generateName = ->
	adjective = 'aberrant,agressive,warty,hoary,breezy,dapper,edgy,feisty,gutsy,hardy,intrepid,jaunty,karmic,lucid,maverick,natty,oneric,precise,quantal,quizzical,curious,derisive,bodacious,nefarious'
	animal = 'axolotl,warthog,hedgehog,badger,drake,fawn,gibbon,heron,ibex,jackalope,koala,lynx,meerkat,narwhal,ocelot,penguin,quetzal,kodiak,cheetah,puma,jaguar,panther,tiger,leopard,lion,neandertal'
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
	#the offsets of the time synchronization stuff
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
	# renderState()

renderState = ->
	# render the user list and that stuff
	if sync.users
		users = for user in sync.users
			votes = []
			for action of sync.voting
				if user.id in sync.voting[action]
					votes.push action
			user.name + " (" + user.id + ") " + votes.join(", ")
		document.querySelector('#users').innerText = users.join(', ')

	#render the question 
	if sync.question
		timeDelta = time() - sync.begin_time
		words = sync.question.split ' '
		{list, rate} = sync.timing
		cumulative = cumsum list, rate
		index = 0
		index++ while timeDelta > cumulative[index]
		index++ if timeDelta > cumulative[0] / 2
			
		document.querySelector("#visible").innerText = words.slice(0, index).join(' ') + " "
		document.querySelector("#unread").innerText = words.slice(index).join(' ')



transitionQuestion = ->
	$('#history .bundle .readout').first().slideUp(1000)
	bundle = createBundle().width($('#history').width()) #.css('display', 'none')
	$('#history').prepend bundle.hide()
	bundle.slideDown(1000)
	bundle.width('auto')


TestingQuestion = {"category": "Trash", "pKey": "His creation is attributed to either Bill Finger or Jerry Robinson, with the distinctive look based partly on the look of actor Conrad Veidt in one film. This man, perhaps originally Red Hood, is cred", "difficulty": "HS", "tournament": "QuAC I", "question": "His creation is attributed to either Bill Finger or Jerry Robinson, with the distinctive look based partly on the look of actor Conrad Veidt in one film. This man, perhaps originally Red Hood, is credited with killing Sarah Gordon and Jason Todd as well as permanently injuring Oracle, while another story sees his psychiatrist Harleen Quinzl falling in love with him and attempting to feed his arch-nemesis to piranhas. In television and movies, he's been played by Cesar Romero and Jack Nicholson. For 10 points name this fictional villain more recently played by Heath Ledger, a nemesis of the Batman.", "accept": null, "question_num": 12, "year": 2008, "answer": "The Joker", "round": "Round1Final.doc"}

createBundle = ->
	breadcrumb = $('<ul>').addClass('breadcrumb')
	addInfo = (name, value) ->
		breadcrumb.find('li').last().append $('<span>').addClass('divider').text('/')
		breadcrumb.append $('<li>').text(name + ": " + value)
	addInfo 'Category', 'Robots'
	# addInfo 'Difficulty', 'Google Fiber Middle School'
	addInfo 'Cupholders', 'Large'
	breadcrumb.append $('<li>').addClass('answer pull-right')
		.text("Answer: Robot Ponies")
	readout = $('<div>').addClass('readout')
	well = $('<div>').addClass('well').appendTo(readout)
	well.append $('<span>').addClass('visible').text(TestingQuestion.question)
	well.append $('<span>').addClass('unread')
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

$('html').toggleClass 'touchscreen', !!('ontouchstart' in window)

jQuery('.bundle .breadcrumb').live 'click', ->
	unless $(this).is jQuery('.bundle .breadcrumb').first()
		$(this).parent().find('.well').slideToggle()

document.addEventListener 'keydown', (e) ->
	if e.keyCode is 32 #space = skip
		sock.emit 'skip', 'yay'
	else if e.keyCode is 80
		sock.emit 'pause', 'yay'
	else if e.keyCode is 90
		sock.emit 'unpause', 'yay'

# setInterval renderState, 50

# $('.leaderboard tbody tr').live 'click', ->

# $('.leaderboard').popover {
# 	placement: "left",
# 	selector: ".leaderboard tbody tr"
# }

$('.leaderboard tbody tr').popover {
	placement: "left"
}

# get em out of phase
n = 0
setInterval ->
	if n++ % 4 == 0
		transitionQuestion()
	else
		chatAnnotation('cucumber', 'im a dumb dinosaur')
, 1000


