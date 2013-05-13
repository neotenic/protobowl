cache_status = (text) ->
	document.getElementById('cache_status').innerHTML = text
	window.parent.postMessage "CacheStatus:#{text}", "*"

cache_event = ->
	status = applicationCache.status
	switch applicationCache.status
		when applicationCache.UPDATEREADY
			cache_status 'Updated'
			applicationCache.swapCache()
		when applicationCache.UNCACHED
			cache_status 'Uncached'
		when applicationCache.OBSOLETE
			cache_status 'Obsolete'
		when applicationCache.IDLE
			cache_status 'Cached'
		when applicationCache.DOWNLOADING
			cache_status 'Downloading'
		when applicationCache.CHECKING
			cache_status 'Checking'


cache_error = (e) ->
	# console.log('cache error', e)
	window.parent.postMessage "CacheStatus:Error", "*"

if window.applicationCache
	for name in ['cached', 'checking', 'downloading', 'noupdate', 'obsolete', 'progress', 'updateready']
		applicationCache.addEventListener name, cache_event, false

	applicationCache.addEventListener 'error', cache_error, false


	window.addEventListener 'message', (evt) ->
		if evt.data == "CacheUpdate"
			applicationCache.update()

	, false