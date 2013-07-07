#= include ./lib/modernizr.js
#= include ./lib/bootstrap.js

assertion = null
auth = null

auth_cookie = (new_cookie) ->
	if new_cookie
		jQuery.cookie 'protoauth', new_cookie
	else if typeof new_cookie isnt 'undefined'
		jQuery.cookie 'protoauth', ''
	
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
	if protobowl_config?.auth
		navigator?.id?.watch {
			loggedInUser: auth?.email,
			onlogin: (ass) -> # this is a rather unfortunate variable name
				assertion = ass
				if connected() and has_connected
					me.link assertion

			onlogout: ->
				assertion = null
				if auth
					verbAnnotation {verb: "logging out of the current authenticated session"}
					switch_socket()
					
				auth_cookie(null)
				

			# onready: ->
			# 	console.log 'now ready'
		}

logged_in = (data) ->
	assertion = null	
	if data?.status isnt 'okay'
		verbAnnotation verb: "server rejected login request: #{data?.reason}"
		navigator?.id?.logout()
		# console.log data
		
	else
		unless auth
			me.accelerate_cleanup()
		verbAnnotation {verb: "logging in and beginning a new authenticated session"}
		auth_cookie? data.cookie
		switch_socket()

switch_socket = ->
	return unless sock
	console.log 'merpity werpity'
	sock.hide_disconnect = true
	sock.socket.disconnect()
	room.users = {}
	sock.socket.reconnect()
	sock.hide_disconnect = false


$("a[href='#signin']").click (e) ->
	navigator?.id?.request()
	e.preventDefault()

$("a[href='#logout']").click (e) ->
	navigator?.id?.logout()
	e.preventDefault()

