#= require ../shared/player.coffee
#= require ../shared/room.coffee
#= require ../shared/names.coffee
#= require ../shared/removeDiacritics.js
#= require ../shared/levenshtein.js
#= require ../shared/porter.js
#= require ../shared/syllable.js

#= require ../shared/answerparse.coffee



# handleCacheEvent = ->
# 	status = applicationCache.status
# 	switch applicationCache.status
# 		when applicationCache.UPDATEREADY
# 			$('#cachestatus').text 'Updated'
# 			console.log 'update is ready'
# 			applicationCache.swapCache()
# 			$('#update').slideDown()		
			
# 			if localStorage.auto_reload is "yay"
# 				setTimeout ->
# 					location.reload()
# 				, 500
# 		when applicationCache.UNCACHED
# 			$('#cachestatus').text 'Uncached'
# 		when applicationCache.OBSOLETE
# 			$('#cachestatus').text 'Obsolete'
# 		when applicationCache.IDLE
# 			$('#cachestatus').text 'Cached'
# 		when applicationCache.DOWNLOADING
# 			$('#cachestatus').text 'Downloading'
# 		when applicationCache.CHECKING
# 			$('#cachestatus').text 'Checking'

# do -> # isolate variables from globals
# 	if window.applicationCache
# 		for name in ['cached', 'checking', 'downloading', 'error', 'noupdate', 'obsolete', 'progress', 'updateready']
# 			applicationCache.addEventListener name, handleCacheEvent

# # asynchronously load offline components
# #also, html5slider isnt actually for offline,
# # but it can be loaded async, so lets do that, 
# # and reuse all the crap that can be reused
# setTimeout ->
# 	window.exports = {}
# 	window.require = -> window.exports
# 	deps = ["html5slider", "levenshtein", "removeDiacritics", "porter", "answerparse", "syllable", "names", "offline"]
# 	loadNextResource = ->
# 		$.ajax {
# 			url: "lib/#{deps.shift()}.js",
# 			cache: true,
# 			dataType: "script",
# 			success: ->
# 				if deps.length > 0
# 					loadNextResource()
# 		}
# 	loadNextResource()
# , 10

