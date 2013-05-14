#= require ./lib/modernizr.js
#= require ./lib/bootstrap.js

assertion = null

$(document).ready ->
	console.log 'persona init', navigator.id
	navigator?.id?.watch {
		onlogin: (ass) -> # this is a rather unfortunate variable name
			console.log 'on loggin'
			assertion = ass
			if connected() and has_connected
				me.link assertion

		onlogout: ->
			console.log 'logging out'
			sock.disconnect()
			sock.socket.reconnect()
			$("#userinfo").fadeOut 'normal', ->
				$("#signin").show()
				$("#user").hide()
				$("#userinfo").fadeIn()
	}

logged_in = (data) ->
	if data?.status isnt 'okay'
		navigator?.id?.logout()
	else
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

