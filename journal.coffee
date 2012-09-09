# this is sort of a metaphor to what a journal is in an actual filesystem
# it has a pretty simple function and very restricted opreating conditions
# which is great because it sort of acts as an intrinsic shield from murphy's
# law, which is that everything that can go wrong will. Well, this effect
# is quite greatly exasperated by the existence of users hammering your
# service, and one forseeable way to avoid this is to eliminate access by
# your users. Or, as the rich old guy from the movie Contact said it, first
# rule of Protobowl spending, why have one when you can have two at twice
# the price? Yeah, that's what this is. The journal.

# It stores essentially a passive copy of all the sync data. It's like having
# a room state for every single room, except not really because there arent
# any methods attached to any of the rooms. Instead, it's just the raw state
# which is stored. It has a clone of the main garbage collector (reaper) and
# it operates offline here.

# but, whenever something happens and the main server is unexpectedly (or 
# even when it is expectedly) shut down and restarted, it boots up and loads
# the current (last stored) state from the journal (this server), and 
# continues operating from that state.

# likewise, when the journal is for some reason shut down, once it gets back
# online, the main application resumes sending things to the journal.

http = require 'http'

rooms = {}

server = http.createServer (req, res) ->
	if req.url is '/journal' and req.method is 'POST'
		# console.log req
		req.setEncoding 'utf-8'
		packet = ''
		req.on 'data', (chunk) ->
			packet += chunk
		req.on 'end', ->
			json = JSON.parse(packet)
			rooms[json.room] ||= {}
			for field, value of json.data
				rooms[json.room][field] = value
		res.writeHead 200, {'Content-Type': 'text/plain'}
		res.end 'saved'
	else if req.url is '/retrieve'
		res.writeHead 200, {'Content-Type': 'application/json'}
		res.end JSON.stringify rooms
	else	
		res.writeHead 200, {'Content-Type': 'text/plain'}
		res.end JSON.stringify rooms, null, '  '

server.listen 15865