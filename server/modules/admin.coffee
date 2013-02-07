util = require('./utils')

module.exports = (app, remote) ->
	app.post '/stalkermode/kickoffline', (req, res) ->
		clearInactive 1000 * 5 # five seconds
		res.redirect '/stalkermode'

	app.post '/stalkermode/announce', (req, res) ->
		io.sockets.emit 'chat', {
			text: req.body.message,
			session: Math.random().toString(36).slice(3),
			user: '__' + req.body.name,
			done: true,
			time: +new Date
		}
		res.redirect '/stalkermode'

	# i forgot why it was called al gore; possibly change
	app.post '/stalkermode/algore', (req, res) ->
		remote.populate_cache (layers) ->
			res.end("counted all cats #{JSON.stringify(layers, null, '  ')}")

	app.get '/stalkermode/users', (req, res) -> res.render './ninja/users.jade', { rooms: rooms }


	app.get '/stalkermode/cook', (req, res) ->
		remote.cook?(req, res)
		res.redirect '/stalkermode'

	app.get '/stalkermode/logout', (req, res) ->
		res.clearCookie 'protoauth'
		res.redirect '/stalkermode'


	app.get '/stalkermode/user/:room/:user', (req, res) ->
		req.params.room = req.params.room.replace(/~/g, '/')
		u = rooms?[req.params.room]?.users?[req.params.user]
		u2 = {}
		u2[k] = v for k, v of u when k not in ['room'] and typeof v isnt 'function'

		res.render './ninja/user.jade', { room: req.params.room, id: req.params.user, user: u, text: util.inspect(u2), ips: u?.ip() }


	app.get '/stalkermode/room/:room', (req, res) ->
		u = rooms?[req.params.room.replace(/~/g, '/')]
		u2 = {}
		u2[k] = v for k, v of u when k not in ['users', 'timing', 'cumulative'] and typeof v isnt 'function'
		res.render './ninja/control.jade', { room: u, name: req.params.room.replace(/~/g, '/'), text: util.inspect(u2)}

	app.post '/stalkermode/stahp', (req, res) -> process.exit(0)

	app.post '/stalkermode/the-scene-is-safe', (req, res) ->
		io.sockets.emit 'impending_doom', Date.now()

		user_names = (name for name, time of journal_queue)
		restart_server = ->
			console.log 'Server shutdown has been manually triggered'
			setTimeout ->
				process.exit(0)
			, 250
		if user_names.length is 0
			res.end 'Nothing to save; Server restarted.'
			restart_server()
			return
		start_time = Date.now()
		saved = 0
		increment_and_check = ->
			saved++
			if saved is user_names.length
				res.end "Saved #{user_names.length} rooms (#{user_names.join(', ')}) in #{Date.now() - start_time}ms; Server restarted."
				restart_server()
		for name in user_names
			remote.archiveRoom? rooms[name], increment_and_check


	app.post '/stalkermode/clear_bans/:room', (req, res) ->
		delete rooms?[req.params.room.replace(/~/g, '/')]?._ip_bans
		res.redirect "/stalkermode/room/#{req.params.room}"

	app.post '/stalkermode/anarchy/:room', (req, res) ->
		room = rooms?[req.params.room.replace(/~/g, '/')]
		room?.admins = []
		room?.sync(1)
		res.redirect "/stalkermode/room/#{req.params.room}"

	app.post '/stalkermode/delete_room/:room', (req, res) ->
		if rooms?[req.params.room.replace(/~/g, '/')]?.users
			for id, u of rooms[req.params.room.replace(/~/g, '/')].users
				for sock in u.sockets
					io.sockets.socket(sock).disconnect()
		rooms[req.params.room.replace(/~/g, '/')] = new SocketQuizRoom(req.params.room.replace(/~/g, '/'))
		res.redirect "/stalkermode/room/#{req.params.room}"


	app.post '/stalkermode/disco_room/:room', (req, res) ->
		if rooms?[req.params.room.replace(/~/g, '/')]?.users
			for id, u of rooms[req.params.room.replace(/~/g, '/')].users
				for sock in u.sockets
					io.sockets.socket(sock).disconnect()
		res.redirect "/stalkermode/room/#{req.params.room}"


	app.post '/stalkermode/emit/:room/:user', (req, res) ->
		u = rooms?[req.params.room.replace(/~/g, '/')]?.users?[req.params.user]
		u.emit req.body.action, req.body.text
		res.redirect "/stalkermode/user/#{req.params.room}/#{req.params.user}"

	app.post '/stalkermode/exec/:command/:room/:user', (req, res) ->
		rooms?[req.params.room.replace(/~/g, '/')]?.users?[req.params.user]?[req.params.command]?()
		res.redirect "/stalkermode/user/#{req.params.room}/#{req.params.user}"

	app.post '/stalkermode/unban/:room/:user', (req, res) ->
		rooms?[req.params.room.replace(/~/g, '/')]?.users?[req.params.user]?.banned = 0
		res.redirect "/stalkermode/user/#{req.params.room}/#{req.params.user}"


	app.post '/stalkermode/negify/:room/:user/:num', (req, res) ->
		rooms?[req.params.room.replace(/~/g, '/')]?.users?[req.params.user]?.interrupts += (parseInt(req.params.num) || 1)
		rooms?[req.params.room.replace(/~/g, '/')]?.sync(1)
		res.redirect "/stalkermode/user/#{req.params.room}/#{req.params.user}"

	app.post '/stalkermode/cheatify/:room/:user/:num', (req, res) ->
		rooms?[req.params.room.replace(/~/g, '/')]?.users?[req.params.user]?.correct += (parseInt(req.params.num) || 1)
		rooms?[req.params.room.replace(/~/g, '/')]?.sync(1)
		res.redirect "/stalkermode/user/#{req.params.room}/#{req.params.user}"


	app.post '/stalkermode/disco/:room/:user', (req, res) ->
		u = rooms?[req.params.room.replace(/~/g, '/')]?.users?[req.params.user]
		io.sockets.socket(sock).disconnect() for sock in u.sockets
		res.redirect "/stalkermode/user/#{req.params.room}/#{req.params.user}"


	gammasave = false

	app.get '/stalkermode/gamma-off', (req, res) ->
		gammasave = false
		res.redirect '/stalkermode'

	app.get '/stalkermode/hulk-smash', (req, res) ->
		gammasave = Date.now()
		res.redirect '/stalkermode'


	setInterval ->
		if gammasave
			io.sockets.emit 'application_update', Date.now()
	, 1000 * 25

	app.get '/stalkermode', (req, res) ->
		latencies = []
		for name, room of rooms
			latencies.push(user._latency[0]) for id, user of room.users when user._latency and user.online()
		os_info = {
			hostname: os.hostname(),
			type: os.type(),
			platform: os.platform(),
			arch: os.arch(),
			release: os.release(),
			loadavg: os.loadavg(),
			uptime: os.uptime(),
			totalmem: os.totalmem(),
			freemem: os.freemem()
		}
		res.render './ninja/admin.jade', {
			env: app.settings.env,
			mem: util.inspect(process.memoryUsage()),
			start: uptime_begin,
			reaped,
			gammasave,
			avg_latency: helper.Med(latencies),
			std_latency: helper.IQR(latencies),
			cookie: req.protocookie,
			queue: Object.keys(journal_queue).length,
			os: os_info,
			os_text: util.inspect(os_info),
			codename,
			message_count,
			rooms
		}

	app.post '/stalkermode/reports/remove_report/:id', (req, res) ->
		mongoose = require 'mongoose'
		remote.Report.remove {_id: mongoose.Types.ObjectId(req.params.id)}, (err, docs) ->
			res.end 'REMOVED IT' + req.params.id


	app.post '/stalkermode/reports/remove_question/:id', (req, res) ->
		mongoose = require 'mongoose'
		remote.Question.remove {_id: mongoose.Types.ObjectId(req.params.id)}, (err, docs) ->
			res.end 'REMOVED IT' + req.params.id


	app.post '/stalkermode/reports/change_question/:id', (req, res) ->
		mongoose = require 'mongoose'
		blacklist = ['inc_random', 'seen']
		remote.Question.findById mongoose.Types.ObjectId(req.params.id), (err, doc) ->
			criterion = {
				difficulty: req.body.difficulty || doc.difficulty,
				category: req.body.category || doc.category,
				type: req.body.type || doc.type
			}
			remote.Question.collection.findOne criterion, null, { sort: { inc_random: 1 } }, (err, existing) ->
				for key, val of req.body when key not in blacklist
					doc[key] = val
				doc.inc_random = existing.inc_random - 0.1 # show it now
				doc.save()
				res.end('gots it')

	app.post '/stalkermode/reports/simple_change/:id', (req, res) ->
		mongoose = require 'mongoose'
		blacklist = ['inc_random', 'seen', 'category', 'difficulty']
		remote.Question.findById mongoose.Types.ObjectId(req.params.id), (err, doc) ->

			for key, val of req.body when key not in blacklist
				doc[key] = val
			# console.log doc
			doc.save()
			res.end('gots it')


	app.get '/stalkermode/to_boldly_go', (req, res) ->
		remote.Question.findOne { fixed: -1 }, (err, doc) ->
			if !doc
				remote.Question.findOne { fixed: null }, (err, doc) ->
					res.end JSON.stringify doc
				return
			res.end JSON.stringify doc

	app.get '/stalkermode/reports/all', (req, res) ->
		return res.render './ninja/reports.jade', { reports: [], categories: [] } unless remote.Report
		remote.Report.find {}, (err, docs) ->
			res.render './ninja/reports.jade', { reports: docs, categories: remote.get_categories('qb') }

	app.get '/stalkermode/reports/:type', (req, res) ->
		return res.render './ninja/reports.jade', { reports: [], categories: [] } unless remote.Report

		remote.Report.find {describe: req.params.type}, (err, docs) ->
			res.render './ninja/reports.jade', { reports: docs, categories: remote.get_categories('qb') }

	app.get '/stalkermode/audacity', (req, res) ->
		res.render './ninja/audacity.jade', { }


	app.get '/stalkermode/patriot', (req, res) -> res.render './ninja/dash.jade'

	app.get '/stalkermode/archived', (req, res) ->
		return res.render './ninja/archived.jade', { list: [], rooms } unless remote.listArchived
		remote.listArchived (list) ->
			res.render './ninja/archived.jade', { list, rooms }

	app.get '/stalkermode/:other', (req, res) -> res.redirect '/stalkermode'

	app.get '/perf-histogram', (req, res) -> res.end util.inspect(perf_hist)

