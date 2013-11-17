$('.webrtc').change -> 
	me.pref 'webrtc', $('.webrtc')[0].checked
	if me.prefs.webrtc
		initializeWebRTC()

	# turnUrl = 'https://computeengineondemand.appspot.com/turn?username=19498870&key=4080218913'

initTurn = ->
	iceServers = [{"url": "stun:stun.l.google.com:19302"}]
	return if webrtcDetectedBrowser is 'firefox' and webrtcDetectedVersion <= 22
	return if (1 for server in iceServers when server.url.substr(0, 5) is 'turn:').length >= 1
	# return if document.domain.search('localhost') is -1 and document.domain.search('apprtc') is -1



initUserMedia = ->
	onSuccess = ->
		verbAnnotation verb: "woot i gots yer hears"
	onError = ->
		verbAnnotation verb: "error acquiring audio signal from browser"
	try
		getUserMedia {
			audio: true,
			video: false
		}, onSuccess, onError
	catch e
		onError()