# Here goes the dragons
# I mean polyfills


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
	value = !!value # force it into a bool
	$(this).each ->
		if $(this).prop('disabled') != value
			$(this).prop 'disabled', value

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

	# 4:20pm 4/20
	dt = new Date()
	dt.setHours(12 + 4)
	dt.setMinutes(20)
	dt.setSeconds(0)
	dt.setMonth(3)
	dt.setDate(20)
	time_delta = dt - Date.now()
	
	if time_delta < 2147483647 and time_delta > 0
		setTimeout ->
			protobot_write 'pass the weed, man'
		, time_delta

	# Ben's birthday
	dt = new Date()
	dt.setHours(0)
	dt.setMinutes(0)
	dt.setSeconds(0)
	dt.setMonth(8)
	dt.setDate(5)
	time_delta = dt - Date.now()
	if time_delta < 2147483647 and time_delta > 0
		setTimeout ->
			addImportant($('<div>').addClass('alert alert-info').html("Today is protobowl developer <b>Ben Vest</b>'s birthday. Send him an email at <code>vestben@gmail.com</code> or something."))
		, time_delta


check_holiday = ->
	now = new Date()
	# lets see what day it is
	if now.getDate() in [24, 25] and now.getMonth() is 11
		$('body').addClass 'christmas'
	
	# superbowl is first sunday of february
	else if now.getMonth() is 1 and now.getDay() is 0 and now.getDate() <= 7
		$('a.brand strong').text('Super')
	# earth day, man
	else if now.getMonth() is 3 and now.getDate() is 22
		$('body').addClass('earthday')
		$('a.brand .motto').text "growing one thing and growing it well"

	else if now.getMonth() is 7 and now.getDate() is 28
		$('a.brand .motto').text "on August 28, 2012, protobowl was first <a href='http://hsquizbowl.org/forums/viewtopic.php?f=123&t=13478'>announced</a>"
	# another arguable protobowl birthday
	else if now.getMonth() is 5 and now.getDate() is 30
		$('a.brand .motto').text "protobowl's precursor, <a href='https://github.com/polarcuke/its-ac-attack'>its-ac-attack</a> was started June 30, 2012"
	# arguable protobowl birthday
	else if now.getMonth() is 6 and now.getDate() is 20
		$('a.brand .motto').text "the first line of protobowl code was written July 20, 2012"
	# april fools
	else if now.getMonth() is 3 and now.getDate() is 1
		$('a.brand').html('<u><b>Quizbowl DB</b></u> <em style="font-size:small">Welcome to Quizbowl DB, the best way to get better at quizbowl!</em>')
		$('body').addClass('aprilfools')
	else
		tomorrow = new Date
		tomorrow.setDate(now.getDate() + 1)
		tomorrow.setHours(0)
		tomorrow.setMinutes(0)
		tomorrow.setSeconds(0)
		setTimeout check_holiday, Math.max(100, tomorrow - Date.now())




check_holiday()

unless console?
	window.console = {
		log: -> null,
		trace: -> null,
		error: -> null
	}

# https://developer.mozilla.org/en-US/docs/JavaScript/Reference/Global_Objects/Array/map#Compatibility
# Production steps of ECMA-262, Edition 5, 15.4.4.19
# Reference: http://es5.github.com/#x15.4.4.19
unless Array::map
	Array::map = (callback, thisArg) ->
		T = undefined
		A = undefined
		k = undefined
		throw new TypeError(" this is null or not defined")  unless this?
		
		# 1. Let O be the result of calling ToObject passing the |this| value as the argument.
		O = Object(this)
		
		# 2. Let lenValue be the result of calling the Get internal method of O with the argument "length".
		# 3. Let len be ToUint32(lenValue).
		len = O.length >>> 0
		
		# 4. If IsCallable(callback) is false, throw a TypeError exception.
		# See: http://es5.github.com/#x9.11
		throw new TypeError(callback + " is not a function")  if typeof callback isnt "function"
		
		# 5. If thisArg was supplied, let T be thisArg; else let T be undefined.
		T = thisArg  if thisArg
		
		# 6. Let A be a new array created as if by the expression new Array(len) where Array is
		# the standard built-in constructor with that name and len is the value of len.
		A = new Array(len)
		
		# 7. Let k be 0
		k = 0
		
		# 8. Repeat, while k < len
		while k < len
			kValue = undefined
			mappedValue = undefined
			
			# a. Let Pk be ToString(k).
			#   This is implicit for LHS operands of the in operator
			# b. Let kPresent be the result of calling the HasProperty internal method of O with argument Pk.
			#   This step can be combined with c
			# c. If kPresent is true, then
			if k of O
				
				# i. Let kValue be the result of calling the Get internal method of O with argument Pk.
				kValue = O[k]
				
				# ii. Let mappedValue be the result of calling the Call internal method of callback
				# with T as the this value and argument list containing kValue, k, and O.
				mappedValue = callback.call(T, kValue, k, O)
				
				# iii. Call the DefineOwnProperty internal method of A with arguments
				# Pk, Property Descriptor {Value: mappedValue, : true, Enumerable: true, Configurable: true},
				# and false.
				
				# In browsers that support Object.defineProperty, use the following:
				# Object.defineProperty(A, Pk, { value: mappedValue, writable: true, enumerable: true, configurable: true });
				
				# For best browser support, use the following:
				A[k] = mappedValue
			
			# d. Increase k by 1.
			k++
		
		# 9. return A
		A
		