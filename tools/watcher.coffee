fs = require 'fs'
path = require 'path'
wrench = require 'wrench'
util = require 'util'
jade = require 'jade'
crypto = require 'crypto'
ws = require('websocket')
http = require 'http'

dev_port = 5577

server = http.createServer (req, res) ->
	res.writeHead 404
	res.end()

server.listen dev_port, ->
	console.log 'server is listening on ' + dev_port

updater = new ws.server {
	httpServer: server,
	autoAcceptConnections: true
}

connections = []

updater.on 'connect', (connection) ->
	connections.push connection

	connection.on 'close', ->
		connections = (c for c in connections when c isnt connection)
	
	# connection.sendUTF('rawr im a dinosaur')


send_update = -> 
	for c in connections
		c.sendUTF Date.now().toString()

# exports.watch = (fn) -> send_update = fn

less = require 'less'
	
Snockets = require 'snockets'
CoffeeScript = require 'coffee-script'

Snockets.compilers.coffee = 
	match: /\.js$/
	compileSync: (sourcePath, source) ->
		CoffeeScript.compile source, {filename: sourcePath, bare: true}

snockets = new Snockets()

recursive_build = (src, dest, cb) ->
	fs.stat dest, (err, deststat) ->
		# if !err
		# 	return wrench.rmdirRecursive dest, (err) ->
		# 		recursive_build src, dest, cb

		fs.stat src, (err, srcstat) ->
			return cb(err) if err
			fs.mkdir dest, srcstat.mode, (err) ->
				# return cb(err) if err
				fs.readdir src, (err, files) ->
					return cb(err) if err
					copyFiles = (err) ->
						return cb(err) if err
						filename = files.shift()
						return cb() if filename is null or typeof filename is 'undefined'
						
						file = src + '/' + filename
						destfile = dest + '/' + filename

						fs.stat file, (err, filestat) ->
							if filestat.isDirectory()
								recursive_build file, destfile, copyFiles
							else # no need to handle symbolic links
								fs.readFile file, (err, data) ->
									build_file filename, data, (outfile, output) ->
										fs.writeFile dest + '/' + outfile, output, copyFiles
					copyFiles()


build_file = (filename, data, callback) ->
	prefix = path.basename(filename, path.extname(filename))

	if path.extname(filename) is '.coffee'
		callback prefix + '.js', CoffeeScript.compile data.toString(), {filename: filename, bare: true}
	else
		callback filename, data




# simple helper function that hashes things
sha1 = (text) ->
	hash = crypto.createHash('sha1')
	hash.update(text + '')
	hash.digest('hex')




scheduledUpdate = null
path = require 'path'

updateCache = (force_update = false) ->
	source_list = []
	compile_date = new Date
	timehash = ''
	cache_text = ''

	settings = JSON.parse(fs.readFileSync('protobowl.json', 'utf8'))

	compileServer = ->
		recursive_build 'server', 'build/server', ->
			recursive_build 'shared', 'build/shared', ->
				recursive_build 'static', 'build/static', ->

					beginCompile()

	beginCompile = ->

		fs.mkdir 'build/static/min', ->
			fs.mkdir 'build/static/dev', ->
				console.log 'compiling stylesheets'
				compileLess()

	compileLess = ->

		lessPath = 'client/less/protobowl.less'
		fs.readFile lessPath, 'utf8', (err, data) ->
			throw err if err

			parser = new(less.Parser)({
				paths: [path.dirname(lessPath)],
				filename: lessPath
			})

			parser.parse data, (err, tree) ->
				css = tree?.toCSS { compress: false }

				source_list.push {
					hash: sha1(css + ''),
					code: "/* protobowl_css_build_date: #{compile_date} (dev) */\n#{css}",
					err: err,
					file: "dev/protobowl.css"
				}

				css = tree?.toCSS { compress: true }

				source_list.push {
					hash: sha1(css + ''),
					code: "/* protobowl_css_build_date: #{compile_date}*/\n#{css}",
					err: err,
					file: "min/protobowl.css"
				}

				console.log 'compiling templates'
				compileJade()


	jade_list = (file.replace('.jade', '') for file in fs.readdirSync('client/jade') when /jade/.test(file))
	jade_src = ''

	compileJade = ->
		file = jade_list.shift()
		if !file
			fs.writeFile 'client/jade/_compiled.js', jade_src, 'utf8', (err) ->
				throw err if err
				console.log 'compiling application code'
				compileCoffee()
				
			return
		
		jadePath = "client/jade/#{file}.jade"
		
		ext = (original, newstuff) -> 


		
		fs.readFile jadePath, 'utf8', (err, data) ->

			helper = (fn, folder, filename, basis, offline) ->
				opts = {
					development: false
				}
				if folder is 'dev'
					opts.development = true
					opts.dev_port = dev_port

				if offline
					opts.offline = true
				else
					opts.offline = false

				for key, val of basis
					opts[key] = val
				
				opts.build = opts.static + folder + '/'

				error = null
				
				try
					code = fn(opts)
				catch e
					error = e

				source_list.push {
					hash: sha1(data),
					code: code,
					err: error,
					file: folder + '/' + filename
				}


			throw err if err

			if file in ["app", "cacher"]
				local = {
					"static": "http://localhost:#{settings.dev.static_port}/",
					"origin": "http://localhost:#{settings.dev.static_port}/",
					"sockets": ["http://localhost:#{settings.dev.socket_port}/"]
				}
				remote = settings.deploy
				fn = jade.compile(data, { pretty: true, filename: jadePath, compileDebug: true })
				
				helper fn, "dev", "#{file}.html", remote
				helper fn, "dev", "#{file}.local.html", local
				
				if file is 'app'
					helper fn, "dev", "offline.html", remote, true
					helper fn, "dev", "offline.local.html", local, true

				fn = jade.compile(data, { pretty: false, filename: jadePath, compileDebug: true })

				helper fn, "min", "#{file}.html", remote
				helper fn, "min", "#{file}.local.html", local

				if file is 'app'
					helper fn, "min", "offline.html", remote, true
					helper fn, "min", "offline.local.html", local, true
				
				# jade_src += "//file: #{jadePath}\n\nvar #{file} = " + fn.toString() + "\n\n\n\n"
				compileJade()
			
			else

				fn = jade.compile(data, {
						pretty: false,
						filename: jadePath,
						compileDebug: false,
						client: true
					})
				jade_src += "//file: #{jadePath}\n\njade.#{file} = " + fn.toString() + "\n\n\n\n"
				compileJade()


	file_list = ['app', 'offline', 'auth']
	
	script_srcs = ''

	compileCoffee = ->
		file = file_list.shift()
		if !file
			# console.log 'saving files'
			return saveFiles() 

		snockets.getConcatenation "client/#{file}.coffee", minify: false, (err, js) ->
			
			outfile = "dev/#{file}.js" 

			source_list.push {
				hash: sha1(js + ''),
				code: "protobowl_#{file}_build = '#{compile_date}'; //dev\n\n#{js}\n", 
				err: err, 
				file: outfile
			}
			
			outfile = "min/#{file}.js"
			
			snockets.getConcatenation "client/#{file}.coffee", minify: true, (err, js) ->
				if file is 'app'
					code_contents = "protobowl_#{file}_build = '#{compile_date}';\n\n(function(){#{js}})();\n"
				else
					code_contents = "protobowl_#{file}_build = '#{compile_date}';\n\n#{js}\n"
				source_list.push {
					hash: sha1(js + ''),
					code: code_contents, 
					err: err, 
					file: outfile
				}		
				compileCoffee()	

	saveFiles = ->		
		# clean up the jade stuff
		fs.unlink 'client/jade/_compiled.js', (err) ->
			throw err if err

		# its something like a unitard
		unihash = sha1((i.hash for i in source_list).join(''))
		if unihash is timehash and force_update is false
			console.log 'files not modified'
			# compile_server()
			scheduledUpdate = null
			console.timeEnd("compile")
			return
		error_message = ''
			
		console.log 'saving files and updating manifest'
		for i in source_list
			error_message += "File: #{i.file}\n#{i.err}\n\n" if i.err
		if error_message
			send_update error_message
			console.log error_message
			scheduledUpdate = null
		else
			saved_count = 0
			for i in source_list
				# ensure that the target directories exist

				fs.writeFile 'build/static/' + i.file, i.code, 'utf8', (err) ->
					throw err if err
					saved_count++
					if saved_count is source_list.length
						writeManifest(unihash)
						copyCache()

	copyCache = ->
		wrench.rmdirRecursive 'build/static/cache', (err) ->
			fs.mkdirSync 'build/static/cache'
			wrench.copyDirRecursive 'build/static/font', 'build/static/cache/font', -> 1
			wrench.copyDirRecursive 'build/static/min', 'build/static/cache/min', -> 1
			wrench.copyDirRecursive 'build/static/img', 'build/static/cache/img', -> 1
			wrench.copyDirRecursive 'build/static/sound', 'build/static/cache/sound', -> 1

	writeManifest = (hash) ->
		data = cache_text.replace(/INSERT_DATE.*?\r?\n/, 'INSERT_DATE '+(new Date).toString() + " # #{hash}\n")
		fs.writeFile 'build/static/offline.appcache', data, 'utf8', (err) ->
			throw err if err
			send_update()
			# compile_server()
			scheduledUpdate = null
			# clean up things
			console.timeEnd("compile")

	console.time("compile")
	fs.readFile 'client/protobowl.appcache', 'utf8', (err, data) ->
		cache_text = data

		fs.readFile 'build/static/offline.appcache', 'utf8', (err, data) ->
			timehash = data?.match(/INSERT_DATE (.*?)\n/)?[1]?.split(" # ")?[1]
			
			console.log 'compiling server components'
			compileServer()
			# compileLess()
		

do_update = (force) ->
	unless scheduledUpdate
		scheduledUpdate = setTimeout ->
			updateCache(force)
		, 100	

watcher = (event, filename) ->
	return if filename in ["_compiled.js"] or /tmp$/.test(filename)
	console.log "changed file", filename
	do_update(false)

force_watch = ->
	console.log 'forcing update'
	do_update(true)

console.log 'initializing filesystem listeners'

fs.watch "shared", watcher
fs.watch "client", watcher
fs.watch "client/less", watcher
fs.watch "client/lib", watcher
fs.watch "client/jade", watcher
fs.watch "protobowl.json", force_watch
fs.watch "server", watcher

updateCache()
