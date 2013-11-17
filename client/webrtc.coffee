localStream = null
peerStreams = {}

$('.webrtc').change ->
	if $('.webrtc')[0].checked
		initUserMedia()
	else if localStream
		localStream.stop()
		for user, stream of peerStreams
			stream.close()
		localStream = null
		peerStreams = {}
		me.verb "disabled audio chat"

	if !localStream
		me.pref 'webrtc', false

	# me.pref 'webrtc', $('.webrtc')[0].checked
	# if me.prefs.webrtc
	# 	initializeWebRTC()

	# turnUrl = 'https://computeengineondemand.appspot.com/turn?username=19498870&key=4080218913'

if (window.mozRTCPeerConnection || window.webkitRTCPeerConnection || window.RTCPeerConnection)
	$('.webrtc')[0].checked = false
	$('.checkrtc').slideDown()
	

getRTCCandidates = ->
	for id, user of room.users when user.prefs.webrtc and id isnt me.id
		if id of peerStreams
			# yay already exists
		else
			initCall(id)

		console.log id, user

onRTCSignal = (source, {session, candidate, type}) ->
	unless source of peerStreams
		createConnection source
	
	pc = peerStreams[source]

	if type is 'candidate'
		console.log "importing ice can", candidate
		candidate = new RTCIceCandidate candidate
		pc.addIceCandidate(candidate)

	else

		onRemoteError = (error) ->
			console.log 'set remote error', error
		
		onReplyError = (error) ->
			console.log 'reply eerrror', error

		if session.type in ['offer', 'answer']
			setRemote = ->
				console.log "set remote woot"

			pc.setRemoteDescription(new RTCSessionDescription(session), setRemote, onRemoteError)

		if session.type is 'offer'
			sendReply = (sessDesc) ->
				pc.setLocalDescription(sessDesc)

				me.rtc_signal { target: source, session: sessDesc }

			pc.createAnswer(sendReply, onReplyError)

		console.log 'rtc signal', session, 'from', source



initTurn = ->

	iceServers = [{"url": "stun:stun.l.google.com:19302"}]
	return if webrtcDetectedBrowser is 'firefox' and webrtcDetectedVersion <= 22
	return if (1 for server in iceServers when server.url.substr(0, 5) is 'turn:').length >= 1
	# return if document.domain.search('localhost') is -1 and document.domain.search('apprtc') is -1


createConnection = (id) ->

	pcConfig = {iceServers: [{url: "stun:stun.l.google.com:19302"}]}
	pcConstraints = {"optional": [{"DtlsSrtpKeyAgreement": true}]}
	
	pc = new RTCPeerConnection(pcConfig, pcConstraints)
	
	pc.onicecandidate = (event) ->
		return unless event.candidate
		can = event.candidate

		console.log 'icecan', can
		me.rtc_signal target: id, type: 'candidate', candidate: {sdpMLineIndex: can.sdpMLineIndex, candidate: can.candidate}
			
	pc.onaddstream = (event) ->
		console.log 'stream add', event.stream
		aud = document.createElement('audio')
		aud.autoplay = true
		document.body.appendChild aud
		attachMediaStream aud, event.stream

	pc.onremovestream = ->
		console.log 'remote removed stream'

	pc.onsignalingstatechange = ->
		console.log('sig cahnge')

	pc.oniceconnectionstatechange = ->
		console.log 'ice state change'

	pc.addStream localStream

	peerStreams[id] = pc

initCall = (id) ->
	pc = createConnection id

	sendOffer = (sessDesc) ->
		# sessDesc.sdp = maybePreferAudioReceiveCodec(sessDesc.sdp)
		pc.setLocalDescription(sessDesc)

		console.log('sess desc', sessDesc)
		me.rtc_signal { target: id, session: sessDesc }

	onError = (err) ->
		console.log 'error creating offer', err


	pc.createOffer sendOffer, onError


initUserMedia = ->
	onSuccess = (stream) ->
		localStream = stream

		me.pref 'webrtc', true
		me.verb "enabled audio chat"
		# verbAnnotation verb: "woot i gots yer hears"
		getRTCCandidates()
	
	onError = (err) ->
		console.log(err)
		verbAnnotation verb: "error acquiring audio signal from browser"
	try
		getUserMedia {
			audio: true,
			video: false
		}, onSuccess, onError
	catch e
		onError(e)