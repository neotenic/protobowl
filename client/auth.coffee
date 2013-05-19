#= include ./lib/modernizr.js
#= include ./lib/bootstrap.js

assertion = null

$(document).ready ->
	auth = null
	try
		[pseudo_hmac, cookie_base] = jQuery.cookie('protoauth').split('&')
		auth = JSON.parse(decodeURIComponent(cookie_base))
	
	console.log 'persona init', auth

	navigator?.id?.watch {
		loggedInUser: auth?.email,
		onlogin: (ass) -> # this is a rather unfortunate variable name
			console.log 'on loggin'
			assertion = ass
			if connected() and has_connected
				console.log 'link 2'
				me.link assertion

		onlogout: ->
			console.log 'logging out'
			assertion = null
			# sock.disconnect()
			# sock.socket.reconnect()
			$("#userinfo").fadeOut 'normal', ->
				$("#signin").show()
				$("#user").hide()
				$("#userinfo").fadeIn()

		onready: ->
			console.log 'now ready'
			unless assertion
				$("#userinfo").fadeOut 'normal', ->
					$("#signin").show()
					$("#user").hide()
					$("#userinfo").fadeIn()
	}

logged_in = (data) ->
	assertion = null
	if data?.status isnt 'okay'
		navigator?.id?.logout()
	else
		console.log 'logged in', data
		if $("#user").is(":hidden")
			$("#userinfo").fadeOut 'normal', ->
				$("#signin").hide()
				$('.user-name').text(data.email)
				$("#user").show()
				$("#userinfo").fadeIn()

$("a[href='#signin']").click (e) ->
	console.log 'login'
	navigator?.id?.request()
	e.preventDefault()

$("a[href='#logout']").click (e) ->
	console.log 'logout'
	navigator?.id?.logout()
	e.preventDefault()

