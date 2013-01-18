window.requestAnimationFrame ||=
  window.webkitRequestAnimationFrame ||
  window.mozRequestAnimationFrame    ||
  window.oRequestAnimationFrame      ||
  window.msRequestAnimationFrame     ||
  (callback, element) ->
    window.setTimeout( ->
      callback(+new Date())
    , 1000 / 60)

Date.now ||= -> new Date().valueOf()

# for internet explorer
unless String::trim
	String::trim = -> @replace(/^\s+/, '').replace(/\s+$/, '')

window.clone_shallow = (obj) ->
	new_obj = {}
	new_obj[attr] = obj[attr] for attr of obj
	return new_obj

RegExp.quote = (str) ->
    return (str+'').replace(/([.?*+^$[\]\\(){}|-])/g, "\\$1")

jQuery.fn.disable = (value) ->
	$(this).each ->
		current = $(this).attr('disabled') is 'disabled'
		if current != value
			$(this).attr 'disabled', value

# inspired by https://gist.github.com/1274961
do ->
	qs = window.location.search?.substr 1
	vars = qs.split '&'
	pairs = ([key, val] = pair.split '=' for pair in vars)
	window.location.query = {}
	window.location.query[key] = val for [key, val] in pairs

# This code is originally taken from the jQuery Cookie plugin by carhartl
# http://plugins.jquery.com/node/1387
# 
# Rewritten in CoffeeScript by Bodacious on 23rd June 2011 for http://urtv.co.uk
jQuery.cookie = (name, value, options) ->
	if typeof value != 'undefined'
		options = options || {}
		if value == null
			value = "" 
			options.expires = -1
		expires = ""
		if options.expires and (typeof options.expires == 'number' or options.expires.toUTCString)
			if typeof options.expires == "number"
				date = new Date
				date.setTime(date.getTime() + (options.expires * 24 * 60 * 60 * 1000))
			else
				date = options.expires
			# use expires attribute, max-age is not supported by IE
			expires = "; expires=#{date.toUTCString()}" 
		path = if options.path then "; path=#{(options.path)}" else ""
		domain = if options.domain then "; domain=#{options.domain}" else ""
		secure = if options.secure then "; secure=#{options.secure}" else ""
		document.cookie = [name, "=", encodeURIComponent(value), expires, path, domain, secure].join("")
	else # only name given, get cookie
		cookieValue = null
		if document.cookie and document.cookie != ""
			cookies = document.cookie.split(";")
			for cookie in cookies
				cookie = jQuery.trim(cookie)
				if cookie.substring(0, (name.length + 1)) == ("#{name}=")
					cookieValue = decodeURIComponent(cookie.substring(name.length + 1))
					break
		# return the value of cookieValue
		cookieValue


jQuery.fn.capQueue = ->
	q = $(this).queue('fx')
	q.splice(1, q.length) if q
	return $(this)

jQuery.fn.fireworks = (times = 5) ->
	for i in [0...times]
		duration = Math.random() * 2000
		@.delay(duration).queue =>
			{top, left} = @position()
			left += jQuery(window).width() * Math.random()
			top += jQuery(window).height() * Math.random()
			color = '#'+Math.random().toString(16).slice(2,8)
			@dequeue()
			for j in [0...50]
				ang = Math.random() * 6.294
				speed = Math.min(100, 150 * Math.random())
				
				vx = speed * Math.cos(ang)
				vy = speed * Math.sin(ang)

				seconds = 2 * Math.random()
				size = 5
				end_size = Math.random() * size
				jQuery('<div>')
				.css({
					"position": 'fixed',
					"background-color": color,
					'width': size,
					'height': size,
					'border-radius': size,
					'top': top,
					'left': left
				})
				.appendTo('body')
				.animate {
					left: "+=#{vx * seconds}",
					top: "+=#{vy * seconds}",
					width: end_size,
					height: end_size
				}, {
					duration: seconds * 1000,
					complete: ->
						$(this).remove()
				}

# an expando is a thing which expands to fill space, minus some fixed width thing in front
# used for lots of ui components in protobowl

$(window).resize ->
	$('.expando').each ->
		add = 0
		add += $(i).outerWidth() for i in $(this).find('.add-on, .padd-on')
		# console.log add
		size = $(this).width()
		input = $(this).find('input, .input')
		if input.hasClass 'input'
			outer = 0
		else
			outer = input.outerWidth() - input.width()
		# console.log 'exp', input, add, outer, size
		# console.log(input[0], outer, add)
		if Modernizr.csscalc
			input.css('width', "-webkit-calc(100% - #{outer + add}px)")
			input.css('width', "-moz-calc(100% - #{outer + add}px)")
			input.css('width', "-o-calc(100% - #{outer + add}px)")
			input.css('width', "calc(100% - #{outer + add}px)")
			
		else
			input.width size - outer - add


$(window).resize()

setTimeout ->
	$(window).resize()
, 762 # feynman

setTimeout ->
	$(window).resize()
, 2718 # euler

setTimeout ->
	$(window).resize()
, 6022 # avogadro


do ->
	# new years woot
	new_year = new Date()
	new_year.setFullYear(new_year.getFullYear() + 1)
	new_year.setHours(0)
	new_year.setMonth(0)
	new_year.setMinutes(0)
	new_year.setSeconds(0)
	new_year.setDate(1)
	time_delta = new_year - Date.now()
	
	if time_delta < 2147483647
		setTimeout ->
			$('body').fireworks(25)
		, time_delta


do ->
	now = new Date()
	if now.getDate() in [24, 25] and now.getMonth() is 11
		$('body').addClass 'christmas'

unless console?
	window.console = {
		log: -> null,
		trace: -> null,
		error: -> null
	}
