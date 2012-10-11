createAlert = (bundle, title, message) ->
	div = $("<div>").addClass("alert alert-success")
		.insertAfter(bundle.find(".annotations")).hide()
	div.append $("<button>")
		.attr("data-dismiss", "alert")
		.attr("type", "button")
		.html("&times;")
		.addClass("close")
	div.append $("<strong>").text(title)
	div.append " "
	div.append message
	div.slideDown()
	setTimeout ->
		div.slideUp().queue ->
			$(this).dequeue()
			$(this).remove()
	, 5000
	

userSpan = (user, global) ->
	prefix = ''

	if me.id and me.id.slice(0, 2) == "__"
		prefix = (room.users[user]?.room?.name || 'unknown') + '/'
	text = ''

	if user.slice(0, 2) == "__"
		text = prefix + user.slice(2)
	else
		text = prefix + (room.users[user]?.name || "[name missing]")
	
	hash = 'userhash-' + escape(text).toLowerCase().replace(/[^a-z0-9]/g, '')
	
	if global
		scope = $(".user-#{user}:not(.#{hash})")
		# get rid of the old hashes
		for el in scope
			for c in $(el).attr('class').split('\s') when c.slice(0, 8) is 'userhash'
				$(el).removeClass(c)
			
	else
		scope = $('<span>')
	scope
		.addClass(hash)
		.addClass('user-'+user)
		.addClass('username')
		.text(text)
		
addAnnotation = (el, name = sync?.name) ->
	# destroy the tooltip
	$('.bundle .ruling').tooltip('destroy')
	current_bundle = $('.room-' + (name || '').replace(/[^a-z0-9]/g, ''))
	if current_bundle.length is 0
		current_bundle = $('#history .bundle.active')
	current_block = current_bundle.eq(0).find('.annotations')
	if current_block.length is 0
		current_block = $('<div>').addClass('annotations').prependTo('#history')
	el.css('display', 'none').prependTo current_block
	el.slideDown()
	return el

addImportant = (el) ->
	$('.bundle .ruling').tooltip('destroy')
	if $('#history .bundle.active .important').length isnt 0
		el.css('display', 'none').prependTo $('#history .bundle.active .important')
	else
		el.css('display', 'none').prependTo $('#history')
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
		if prompt
			prompt_el = $('<a>').addClass('label prompt label-info').text('Prompt')
			line.append ' '
			line.append prompt_el
		else
			marker = $('<span>').addClass('label').text("Buzz")
			if early
				# do nothing, use default
			else if interrupt
				marker.addClass 'label-important'
			else
				marker.addClass 'label-info'
			line.append marker
		

		line.append " "
		line.append userSpan(user).addClass('author')
		line.append document.createTextNode ' '
		$('<span>')
			.addClass('comment')
			.appendTo line

		ruling = $('<a>')
			.addClass('label ruling')
			.hide()
			.attr('href', '#')
			.attr('title', 'Click to Report')
			.data('placement', 'right')
		line.append ' '
		line.append ruling
		# addAnnotation line
		annotation_spot = $('#history .bundle[name="' + room.qid + '"]').eq(0).find('.annotations')
		if annotation_spot.length is 0
			annotation_spot = $('#history')
		line.css('display', 'none').prependTo annotation_spot
		line.slideDown()
	if done
		if text is ''
			line.find('.comment').html('<em>(blank)</em>')
		else
			line.find('.comment').text(text)
	else
		line.find('.comment').text(text)


	if done
		ruling = line.find('.ruling').show().css('display', 'inline')
		# setTimeout ->
		# 	ruling.tooltip('show')
		# , 100
		# setTimeout ->
		# 	ruling.tooltip('hide')
		# , 1000
		decision = ""
		if correct is "prompt"
			ruling.addClass('label-info').text('Prompt')
			decision = "prompt"
		else if correct
			decision = "correct"
			ruling.addClass('label-success').text('Correct')
			if user is me.id # if the person who got it right was me
				old_score = computeScore(me)
				checkScoreUpdate = ->
					updated_score = computeScore(me)
					if updated_score is old_score
						setTimeout checkScoreUpdate, 100
						return

					magic_multiple = 1000
					magic_number = Math.round(old_score / magic_multiple) * magic_multiple
					# console.log updated_score, old_score
					return if magic_number is 0 # 0 is hardly an accomplishment
					if magic_number > 0
						if old_score < magic_number and updated_score >= magic_number
							$('body').fireworks(magic_number / magic_multiple * 10)
							createAlert ruling.parents('.bundle'), 'Congratulations', "You have over #{magic_number} points! Here's some fireworks."
				checkScoreUpdate()
		else
			decision = "wrong"
			ruling.addClass('label-warning').text('Wrong')
			if user is me.id and me.id of room.users
				old_score = computeScore(me)
				if old_score < -100 # just a little way of saying "you suck"
					createAlert ruling.parents('.bundle'), 'you suck', 'like seriously you really really suck. you are a turd.'


		answer = room.answer
		ruling.click ->
			sock.emit 'report_answer', {guess: text, answer: answer, ruling: decision}
			createAlert ruling.parents('.bundle'), 'Reported Answer', "You have successfully told me that my algorithm sucks. Thanks, I'll fix it eventually. "
			# I've been informed that this green box might make you feel bad and that I should change the wording so that it doesn't induce a throbbing pang of guilt in your gut. But the truth is that I really do appreciate flagging this stuff, it helps improve this product and with moar data, I can do science with it.

			# $('#review .review-judgement')
			# 	.after(ruling.clone().addClass('review-judgement'))
			# 	.remove()
				
			# $('#review .review-answer').text answer
			# $('#review .review-response').text text
			# $('#review').modal('show')
			return false

		if actionMode is 'guess'
			setActionMode ''
	# line.toggleClass 'typing', !done
	return line

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
		addAnnotation line, room.users[user]?.room?.name

	url_regex = /\b((?:https?:\/\/|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/ig
	html = text.replace(/</g, '&lt;').replace(/>/g, '&gt;')
	.replace(/(^|\s+)(\/[a-z0-9\-]+)(\s+|$)/g, (all, pre, room, post) ->
		# console.log all, pre, room, post
		return pre + "<a href='#{room}'>#{room}</a>" + post
	).replace(url_regex, (url) ->
		real_url = url
		real_url = "http://#{url}" unless /:\//.test(url)
		if /\.(jpe?g|gif|png)$/.test(url)
			return "<img src='#{real_url}' alt='#{url}'>"
		else
			return "<a href='#{real_url}' target='_blank'>#{url}</a>"
	)
	# console.log html
	if done
		line.removeClass('buffer')
		if text is ''
			line.find('.comment').html('<em>(no message)</em>')
		else
			line.find('.comment').html html
	else
		if !$('.livechat')[0].checked or text is '(typing)'
			line.addClass('buffer')
			line.find('.comment').text(' is typing...')
		else
			line.removeClass('buffer')
			# line.find('.comment').text(text)

			line.find('.comment').html html

	line.toggleClass 'typing', !done


verbAnnotation = ({user, verb}) ->
	line = $('<p>').addClass 'log'
	if user
		line.append userSpan(user)
		line.append " " + verb
	else
		line.append verb
	addAnnotation line

logAnnotation = (text) ->
	line = $('<p>').addClass 'log'
	line.append text
	addAnnotation line

# sock.on 'log',

# logAnnotation 'Initializing ProtoBowl v3'