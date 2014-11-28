createAlert = (title, message, delay = 5000) ->
	div = $("<div>").addClass("alert").hide()
	div.append $("<button>", {
			"data-dismiss": "alert",
			"type": "button"
		})
		.html("&times;")
		.addClass("close")
	div.append $("<strong>").text(title)
	div.append " "
	div.append message
	setTimeout ->
		div.slideDown()
	, 10
	setTimeout ->
		div.slideUp().queue ->
			$(this).dequeue()
			$(this).remove()
	, delay
	return div
	
		
addAnnotation = (el, name = sync?.name) ->
	# destroy the tooltip
	$('.bundle .ruling').tooltip('destroy')
	current_bundle = $('.room-' + (name || '').replace(/[^a-z0-9]/g, ''))
	if current_bundle.length is 0
		current_bundle = $('#history .bundle.active')
	current_block = current_bundle.eq(0).find('.annotations')
	if current_block.length is 0
		current_block = $('#history .annotations').eq(0)
	el.prependTo current_block
	
	unless el.hasClass('annoying') and me.prefs.distraction
		el.css('display', 'none').slideDown()

	return el

addImportant = (el) ->
	$('.bundle .ruling').tooltip('destroy')
	if $('#history .bundle.active .sticky').length isnt 0
		el.css('display', 'none').prependTo $('#history .bundle.active .sticky')
	else
		el.css('display', 'none').prependTo $('#history .sticky:first')
	el.slideDown()
	return el


userSpan = (id, global) ->
	user = room?.users[id]

	span = $(document.createElement('span')).data('id', id)
		
	if id.slice(0, 2) == "__"
		span.text(id.slice(2).replace(/_/g, ' '))
	else
		span.text(user?.name || "[name missing]")
	
	icon = (name) -> span.prepend "<i class='icon-#{name} user-prefix'></i>"

	if id.slice(0, 2) is '__'
		if /ninja/.test id
			icon 'magic'
		else
			icon 'bullhorn'
	if user?.banned and user.banned > room.serverTime()
		icon 'ban-circle'
	if user?.authorized('moderator')
		icon 'star-empty'
	if user?.prefs?.webrtc
		icon 'microphone'
	if user?.prefs?.distraction
		icon 'eye-close'
		span.attr 'title', 'This user has enabled distraction-free mode.'
	
	if user?.auth
		span.addClass 'auth'


	if user?._suffix
		span.append ' '
		span.append $('<span style="color: rgb(150, 150, 150)">').text(user._suffix)
		

	hash = 'userhash-'+encodeURIComponent(span.attr('class') + span.html()).replace(/[^a-z0-9]/g, '')
	
	span.addClass("username user-#{id}")

	if global
		$(".user-#{id}:not(.#{hash})").replaceWith ->
			span.clone()

	return span



render_admin_panel = (el) ->
	if !el
		$('.tooltip').remove()
		$('.banham').each ->
			render_admin_panel $(this)

	return unless el

	
	# # go through each one
	# $('.banham').each ->
	full = el.hasClass('full')
	id = el.data('uid')

	# secret ninjas can not be in trouble
	return if id[0] is '_'

	return unless connected()
	
	# reset it
	el.html('')

	return unless room.users[id]

	button_type = ""

	if id is me.id
		button_type = "identity"
		el.append $('<span>', {
			'title': 'This post can be used against you',
			rel: 'tooltip'
		})
		# .addClass('label label-info pull-right banhammer reprimand')
		.addClass('pull-right banhammer')
		.append($('<i>').addClass('icon-legal'))

	else if me.reprimand_embargo < room.serverTime() or me.authorized('elected')
		button_type = "reprimand"
		
	if 1000 * 60 * 10 > Date.now() - room.users[id].__reprimanded > 1000 * 10 and me.tribunal_embargo < room.serverTime() and !room.admin_online()
		button_type = "tribunal"

	unless full or me.authorized('moderator')
		if room.users[id].banned > room.serverTime()
			el.append $('<span>')
			.addClass('pull-right banhammer')
			.css('color', '#c83025')
			.append($('<i>').addClass('icon-ban-circle'))
			button_type = ''

		else if button_type is ''
			el.append $('<span>')
			.addClass('pull-right banhammer')
			.append($('<i>').addClass('icon-legal'))

	if button_type is 'reprimand' or full
		el.append $('<a>', {
			href: '#', 
			title: 'Reprimand this user',
			rel: 'tooltip',
			'data-id': id
		})
		.addClass('label label-info pull-right banhammer reprimand')
		.append($('<i>').addClass('icon-thumbs-down'))

	if button_type is 'tribunal' or full
		el.append $('<a>', {
			href: '#', 
			title: 'Initiate ban tribunal for this user',
			rel: 'tooltip',
			'data-id': id
		})
		.addClass('label label-warning pull-right banhammer make-tribunal')
		.append($("<i>").addClass('icon-legal'))

	if full or me.authorized('moderator')
		el.append $('<a>', {
			href: '#', 
			title: 'Instantly ban this user for 10 minutes',
			rel: 'tooltip',
			'data-id': id
		})
		.addClass('label label-important pull-right banhammer instaban')
		.append($("<i>").addClass('icon-ban-circle'))
			


			


admin_panel = (id, arg = false) -> 
	# the sequel to banButton, inspired by userSpan

	new_el = $("<span>")
		.addClass("banham banham-#{id}")
		.attr('data-uid', id)

	
	if typeof arg is 'boolean' and arg == true
		new_el.addClass('full') 

	if typeof arg is 'string' and arg
		new_el.attr('data-reason', arg)

	render_admin_panel new_el

	return new_el




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
		line = $('<p>').attr('id', id).addClass('guess')
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
		line.append userSpan(user) #.addClass('author')
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
		annotation_spot = $('#history .bundle:first .annotations')
		if annotation_spot.length is 0
			annotation_spot = $('#history .annotations:first')
		line.css('display', 'none').prependTo annotation_spot
		line.slideDown()
	if done
		if text is ''
			line.find('.comment').html('<em>(blank)</em>')
		else
			line.find('.comment').text(text)
	else
		if me.muwave
			line.find('.comment').html('<em style="color:gray">(typing...)</em>')
		else
			line.find('.comment').text(text)


	if done
		ruling = line.find('.ruling').css('display', 'none')
		decision = ""
		if correct is "prompt"
			ruling.addClass('label-info').text('Prompt')
			decision = "prompt"
		else if correct
			decision = "correct"
			ruling.addClass('label-success').text('Correct')

			if room.users[user]?.streak > 3 and room.active_count() > 2
				line.prepend admin_panel(user)

			if user is me.id # if the person who got it right was me
				old_score = me.score()
				checkScoreUpdate = ->
					updated_score = me.score()
					if updated_score is old_score
						setTimeout checkScoreUpdate, 100
						return

					magic_multiple = 1000
					magic_number = Math.round(old_score / magic_multiple) * magic_multiple
					# console.log updated_score, old_score
					return if magic_number is 0 # 0 is hardly an accomplishment
					if magic_number > 0
						if old_score < magic_number and updated_score >= magic_number  and room.scoring?.normal?[0] < 20
							$('body').fireworks(Math.min(60, magic_number / magic_multiple * 10))
							createAlert('Congratulations', "You have over #{magic_number} points! Here's some fireworks.")
								.addClass('alert-success')
								.insertAfter(ruling.parents('.bundle').find('.annotations'))
				checkScoreUpdate()
		else
			decision = "wrong"
			ruling.addClass('label-warning').text('Wrong')
			if (room.users[user]?.negstreak > 3 or room.users[user]?.score() < 0) and room.active_count() > 2 or check_profanity?(text)
				line.prepend admin_panel(user, 'bad language')
			
			if user is me.id and me.id of room.users
				old_score = me.score()
				 # just a little way of saying "you suck" 
				if old_score < -250 and room.scoring?.normal?[0] < 20
					createAlert('you suck', 'like seriously you really really suck. you are a turd.')
						.addClass('alert-info')
						.insertAfter(ruling.parents('.bundle').find('.annotations'))

		ruling.fadeIn().css('display', 'inline')

		answer = room.answer
		qid = room.qid
		ruling.click ->
			me.report_answer {guess: text, answer: answer, ruling: decision, qid}
			createAlert('Reported Answer', "You have successfully told me that my algorithm sucks. Thanks, I'll fix it eventually. ")
				.addClass('alert-success')
				.insertAfter(ruling.parents('.bundle').find('.annotations'))
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
	if !session
		session = 'auto-'+Math.random().toString(36).slice(3)
	id = user + '-' + session
	if $('#' + id).length > 0
		line = $('#' + id)
	else
		line = $('<p>').attr('id', id).addClass('chat annoying')
		line.append $('<span>').addClass('author').append(userSpan(user).attr('title', formatTime(time)))
		line.append $('<span>').addClass('timecolon').append(" (#{formatTime(time)}): ")
		line.append document.createTextNode ' '
		$('<span>')
			.addClass('comment')
			.appendTo line
		addAnnotation line, room.users[user]?.room?.name
	user_list = []
	url_regex = /\b((?:https?:\/\/|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/ig
	html = text.replace(/</g, '&lt;').replace(/>/g, '&gt;')
	.replace(/(^|\s+)(\/[a-z0-9\-]+\/?[a-z0-9\-]*)(\s+|$)/g, (all, pre, room, post) ->
		# console.log all, pre, room, post
		return pre + "<a href='#{room}'>#{room}</a>" + post
	).replace(url_regex, (url) ->
		real_url = url
		real_url = "http://#{url}" unless /:\//.test(url)
		if /\.(jpe?g|gif|png)$/i.test(url)
			# return ""
			return "<a href='#{real_url}' class='show_image' target='_blank'>#{url}</a> (click to show) 
				<div style='display:none;overflow:hidden' class='chat_image'>
					<img src='#{real_url}' alt='#{url}'>
				</div>"
		else
			return "<a href='#{real_url}' target='_blank'>#{url}</a>"
	).replace(/!@([a-z0-9]+)/g, (match, user) ->
		user_list.push user
		return userSpan(user).wrap('<span>').parent().addClass('recipient').clone().wrap('<div>').parent().html()
	)
	# get a list of teams and highlight them
	team_map = {}
	team_map[u.team || 'individuals'] = 1 for i, u of room.users
	team_list = []
	for team of team_map
		html = html.replace(new RegExp('\\*@(' + RegExp.quote(team) + ')', 'g'), (match, team_name) ->
			team_list.push team_name
			return $('<span>').text(team_name).addClass('team-recipient').wrap('<div>').parent().html()
		)

	if done
		line.removeClass('buffer')
		
		restricted_see = (me.team || 'individuals') in team_list or me.id in user_list or me.id[0] is '_' or user is me.id
		
		can_see = text[0] != '@' or restricted_see
		
		if restricted_see
			line.removeClass 'annoying'

		if text is '' or !can_see
			line.find('.comment').html('<em>(no message)</em>')
			line.slideUp 'normal', ->
				line.remove()
		else

			if text.slice(0, 1) is '@'
				if team_list.length > 0
					line.prepend '<i class="icon-group"></i> '
				else
					line.prepend '<i class="icon-user"></i> '
			
			dirty = check_profanity? text
			
			if dirty and room.name is 'lobby'
				html = html.replace(/nigger/gi, '******')

			line.find('.comment').html html
			
			if user of room.users
				if dirty
					line.prepend admin_panel(user, 'bad language')
				else if text.length > 70 
					line.prepend admin_panel(user, 'spamming')

	else
		if !$('.livechat')[0].checked or text is '(typing)'
			line.addClass('buffer')
			line.find('.comment').text(' is typing...')
		else
			line.removeClass('buffer')
			# line.find('.comment').text(text)

			line.find('.comment').html html

	line.toggleClass 'typing', !done
	line.data 'last_update', time


reprimandAnnotation = ({time, trigger, reason}) ->
	# destroy the tooltip
	setTimeout ->
		$('.bundle .ruling').tooltip('destroy')
	, 100

	line = $('<p>').addClass 'log'
	line.prepend '<i class="icon-thumbs-down"></i> '
	if trigger?[0] != '_' and room.users[trigger]
		line.append userSpan(trigger)
		line.append ' has issued you a warning for '
		if reason
			line.append reason
		else
			line.append 'your behavior'
		line.append ' '
	else
		line.append 'your behavior has been reprimanded'
		if reason
			line.append ' for '
			line.append reason
		
	addAnnotation line



boldAnnotation = ({user, qid, time, answer}) ->
	setTimeout ->
		$('.bundle .ruling').tooltip('destroy')
	, 100
	line = $("<p>").addClass 'log'
	line.append userSpan(user).attr('title', formatTime(time))
	line.append ' changed the answer line to '
	line.append answer.replace(/\{/g, '<strong>').replace(/\}/g, '</strong>')
	$(".bundle.qid-#{qid} .annotations").prepend line.hide()

	line.slideDown()


verbAnnotation = ({user, verb, time, notify}) ->
	# destroy the tooltip
	setTimeout ->
		$('.bundle .ruling').tooltip('destroy')
	, 100
	
	verbclass = "verb-#{user}-#{verb.replace(/[^a-z]/ig, ' ').split(' ').slice(0, 2).join('-')}"

	line = $('<p>').addClass 'log annoying'
	line.addClass(verbclass)
	
	if user
		if user is me.id and !/skip|pause|resume/.test(verb)
			line.removeClass 'annoying'

		if notify
			line.prepend '<i class="icon-user"></i> '
		
		line.append userSpan(user).attr('title', formatTime(time))
		line.append " " + verb.replace /!@([a-z0-9]+)/g, (match, user) ->
			return userSpan(user).clone().wrap('<div>').parent().html()
	else
		line.append verb


	# if /paused the/.test(verb)
	if /paused the/.test(verb) or /skipped/.test(verb) or /category/.test(verb) or /difficulty/.test(verb) or /ban tribunal/.test(verb) or me.id[0] == '_'
		# banButton user, line
		line.prepend admin_panel(user)

	left = $(".bundle.active .verb-#{user}-left-the")
	if verb.split(' ')[0] is 'joined' and left.length > 0
		left.slideUp 'normal', ->
			$(this).remove()
		verbAnnotation {user, verb: 'reloaded the page', time}
		return



	selection = $(".bundle.active .#{verbclass}")

	if selection.length > 0
		# For Thine is
		# Life is
		# For Thine is the

		# This is the way the world ends
		# This is the way the world ends
		# This is the way the world ends
		# Not with a bang but a whimper.


		line.data 'count', selection.data('count') + 1
		line.hide()
		line.prepend $('<span style="margin-right:5px">').addClass('badge').text(line.data('count') + 'x')
		selection.slideUp 'normal', ->
			$(this).remove()
		# line.slideDown 'normal'
		addAnnotation line
	else
		line.data 'count', 1
		addAnnotation line

logAnnotation = (text) ->
	line = $('<pre>')
	line.append text
	$("#history").prepend line.hide().slideDown()
	# addAnnotation line


notifyTrolls = ->
	addAnnotation($('<iframe width="420" height="315" src="http://www.youtube.com/embed/6bMLrA_0O5I?rel=0" frameborder="0" allowfullscreen></iframe>'))

notifyLike = ->
	message = $("<span>").html('<b>Like Protobowl?</b> Consider liking us on <a href="https://www.facebook.com/protobowl">Facebook</a>. ')
	likebtn = $('<iframe src="https://www.facebook.com/plugins/like.php?href=https%3A%2F%2Fwww.facebook.com%2Fprotobowl&amp;send=false&amp;layout=button_count&amp;width=450&amp;show_faces=false&amp;font&amp;colorscheme=light&amp;action=like&amp;height=21&amp;appId=111694105666039" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:150px; height:21px;" allowTransparency="true"></iframe>')
	$('body').append(likebtn.css('vertical-align', 'bottom').hide())
	setTimeout ->
		addAnnotation $('<p>').append(message).append(likebtn.show())
	, 1000


notifyMobile = ->
	message = $("<span>").html('<b>Try Protobowl for Mobile!</b> Download the free Protobowl app for <a href="https://itunes.apple.com/us/app/protobowl/id716914125">iOS (iPod Touch, iPhone or iPad)</a> or <a href="https://play.google.com/store/apps/details?id=com.minibit.protobowl">Android</a>.')
	setTimeout ->
		addAnnotation $('<p>').append(message)
	, 1000

# Ummmm ahh such as like, like the one where I'm like mmm and it says, 
# "I saw watchoo did there!" 
# And like and and then like you peoples were all like, 
# "YOU IS TROLLIN!" 
# and I was like 
# "I AM NOT TROLLING!! 
# I AM BOXXY YOU SEE! Mm!"

# (contemporary poetry)

boxxyAnnotation = ({id, tribunal}) ->
	{votes, time, witnesses, against, initiator} = tribunal
	
	return if me.id not in witnesses and me.id[0] != '_' # people who havent witnessed the crime do not constitute a jury of peers
	# majority + opposers - votes
	votes_needed = Math.floor((witnesses.length - 1)/2 + 1) - votes.length + against.length

	line = $('<div>').addClass('alert').addClass('troll-' + id)
	
	initiator = '' if initiator and initiator[0] is '_' # diplomatic immunity?

	if id is me.id # who would vote for their own banning?
		if initiator
			line.append userSpan(initiator)
			line.append ' has complained about your behavior and created a ban tribunal. '
		else
			line.text('Protobowl has detected abnormally high activity from your computer.\n')
		line.append " <strong> Currently #{votes.length} of #{witnesses.length-1} users have voted</strong> (#{votes_needed} more votes are needed to ban you from this room)."
	else
		line.append $("<strong>").append('Is ').append(userSpan(id)).append(' trolling? ')
		if initiator
			line.append userSpan(initiator)
			line.append ' has created a ban tribunal for '
			line.append userSpan(id)
			line.append '. '
		else
			line.append 'Protobowl has detected abnormally high rates of activity from '
			line.append userSpan(id)
			line.append '. '

		# line.append 'The user may be sent to '
		# line.append "<a href='/b'>/b</a> and banned from this room if a majority of users vote to do so. <br> "

		line.append '<br>'

		guilty = $('<button>').addClass('btn btn-small').text('Ban this user')
		line.append guilty
		line.append ' '
		not_guilty = $('<button>').addClass('btn btn-small').text("Don't ban")
		line.append not_guilty
		line.append " <strong> Currently #{votes.length} of #{witnesses.length-1} users have voted</strong> (#{votes_needed} more votes needed)"
		guilty.click ->
			me.vote_tribunal {user: id, position: 'ban'}
		not_guilty.click ->
			me.vote_tribunal {user: id, position: 'free'}
		
		guilty.add(not_guilty).disable((me.id in votes) or (me.id in against))
	
	if $('.troll-'+id).length > 0 and $('.troll-'+id).parents('.active').length > 0
		$('.troll-'+id).replaceWith line
	else
		$('.troll-'+id).slideUp 'normal', ->
			$(this).remove()
		addImportant line

# ERMAGERD HOUSE OF CARDS IS SOOO GOOODDDD

# Power is a lot like real estate
# It's all about location, location, location
# The closer you are to the source, the higher your property value
# Centuries from now, when people watch this footage
# who will they see smiling at the edge of this frame?

congressionalAnnotation = ({id, elect}) ->
	line = $('<div>').addClass('alert alert-info').addClass('elect-' + id)

	if elect.term
		{witnesses, impeach} = elect
		
		return if me.id not in witnesses and me.id[0] != '_'

		votes_needed = Math.floor((witnesses.length - 1)/2 + 1) - impeach.length

		if room.serverTime() > elect.term
			$('.elect-'+id).slideUp 'normal', ->
				$(this).remove()
			return
		if id is me.id
			updateTermTimeout = ->
				remaining = Math.round(Math.max(0, me.elect.term - room.serverTime()) / 1000)
				$('.term-timeout').text(remaining)
				if remaining > 0
					setTimeout updateTermTimeout, 1000

			line.html("You have access to the settings for <b>the next <span class='term-timeout'>60</span> seconds</b>. \n")
			
			updateTermTimeout()

			finish = $('<button>').addClass('btn btn-small').text('Done')
			finish.click ->
				me.finish_term()
			line.append finish

		else
			# line.append $("<strong>").append('Impeach ').append(userSpan(id)).append('? ')
			# line.append "You have the option to impeach your elected officials. <br>"
			impeacher = $('<button>').addClass('btn btn-small').text("Impeach")
			impeacher.click ->
				me.vote_election {user: id, position: 'impeach'}
			
			line.append impeacher.disable(me.id in impeach)

			line.append " <strong> #{impeach.length} of #{witnesses.length-1} users have voted to impeach </strong>"
			line.append userSpan(id).css('font-weight', 'bold')
			line.append " (#{votes_needed} more votes needed)"

	else
		{votes, time, witnesses, against} = elect
		
		return if me.id not in witnesses and me.id[0] != '_'

		votes_needed = Math.floor((witnesses.length)/2 + 1) - votes.length + against.length
		if id is me.id # who would vote for their own banning?
			# line.html("You are a contestant in Protobowl's <i>Who Wants to be an Admin (for 60 seconds)</i>.\n")
			line.append " <strong>#{votes.length} of #{witnesses.length} users have voted</strong> (#{votes_needed} more votes are needed)"
		else
			line.append $("<strong>").append('Is ').append(userSpan(id)).append(' trustworthy? ')
			
			line.append "Grant control over the room settings if you believe the motives of "
			line.append userSpan(id)
			line.append " are pure. Elected terms are 1 minute. <br>"
			# line.append "will be granted one minute of control over the settings. You have one minute to cast your vote. <br> "
			worthy = $('<button>').addClass('btn btn-small').text('Grant access')
			line.append worthy
			line.append ' '
			not_worthy = $('<button>').addClass('btn btn-small').text("Deny")
			line.append not_worthy
			line.append " <strong> #{votes.length} of #{witnesses.length} users have voted</strong> (#{votes_needed} more votes needed)"
			worthy.click ->
				me.vote_election {user: id, position: 'elect'}
			not_worthy.click ->
				me.vote_election {user: id, position: 'deny'}
			
			worthy.add(not_worthy).disable((me.id in votes) or (me.id in against))
	
	if $('.elect-'+id).length > 0
		$('.elect-'+id).replaceWith line
	else
		addAnnotation line
	