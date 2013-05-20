#= include ./lib/modernizr.js
#= include ./lib/bootstrap.js

assertion = null
auth = null

auth_cookie = (new_cookie) ->
	if new_cookie
		jQuery.cookie 'protoauth', new_cookie
	else if typeof new_cookie isnt 'undefined'
		jQuery.cookie 'protoauth', null
	
	try
		[pseudo_hmac, cookie_base] = jQuery.cookie('protoauth').split('&')
		auth = JSON.parse(decodeURIComponent(cookie_base))
	catch e
		auth = null

	$("body").toggleClass "authenticated", !!auth

	if $("#userinfo").is(":hidden") or !!auth == $("#user").is(":hidden")
		# if auth is different from presented state
		$("#userinfo").fadeOut 'normal', ->
			if auth
				$("#signin").hide()
				$('.user-name').text(auth.email)
				$("#user").show()
				$("#userinfo").fadeIn()
			else
				$("#signin").show()
				$("#user").hide()
				$("#userinfo").fadeIn()

auth_cookie()

$(document).ready ->
	
	console.log 'persona init', auth
	# persona_ready = false
	navigator?.id?.watch {
		loggedInUser: auth?.email,
		onlogin: (ass) -> # this is a rather unfortunate variable name
			assertion = ass
			if connected() and has_connected
				# console.log 'link 2'
				me.link assertion

		onlogout: ->
			assertion = null
			auth_cookie null

			sock.socket.disconnect()
			sock.socket.reconnect()

		onready: ->
			# persona_ready = true
			# $("#aboutlink").hide()
			console.log 'now ready'
			
	}
	# setTimeout ->
	# 	unless persona_ready
	# 		$("#aboutlink").fadeIn()
	# , 4 * 1000

logged_in = (data) ->
	assertion = null	
	if data?.status isnt 'okay'
		navigator?.id?.logout()
	else
		auth_cookie? data.cookie
		sock.socket.disconnect()
		sock.socket.reconnect()



$("a[href='#signin']").click (e) ->
	console.log 'login'
	navigator?.id?.request()
	e.preventDefault()

$("a[href='#logout']").click (e) ->
	console.log 'logout'
	navigator?.id?.logout()
	e.preventDefault()

