#= require ./lib/modernizr.js
#= require ./lib/bootstrap.js

$(document).ready ->
	console.log 'starting persona', navigator.id

	navigator?.id?.watch {
		onlogin: (assertion) ->
			console.log assertion
		onlogout: ->
			$("#userinfo").fadeOut 'normal', ->
				$("#signin").show()
				$("#userinfo").hide()
				$("#userinfo").fadeIn()
	}


$("a[href='#signin']").click (e) ->
	console.log 'login'
	navigator?.id?.request()
	e.preventDefault()

$("a[href='#logout']").click (e) ->
	console.log 'logout'
	navigator?.id?.logout()
	e.preventDefault()


magical_ponies = 4