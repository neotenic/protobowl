fs = require 'fs'
CoffeeScript = require 'coffee-script'
UglifyJS = require 'uglify-js'
SourceMap = require 'source-map'

filename = 'test.coffee'

nodes = []

for filename in ['test.coffee', 'test2.coffee']
	data = fs.readFileSync filename, 'utf8'

	{js, sourceMap, v3SourceMap} = CoffeeScript.compile data, {
		sourceMap: true,
		bare: true,
		generatedFile: filename + '.map',
		sourceFiles: [filename],
		filename: filename
	}
	console.log js, v3SourceMap

	# fs.writeFileSync filename + '.js', js, 'utf8'
	# fs.writeFileSync filename + '.map', v3SourceMap, 'utf8'
	toplevel = UglifyJS.parse js, {
		filename: filename + '.js'
	}
	
	toplevel.figure_out_scope()
	compressor = UglifyJS.Compressor {

	}
	# toplevel = toplevel.transform(compressor)
	toplevel.figure_out_scope()
	toplevel.compute_char_frequency()
	toplevel.mangle_names()
	source_map = UglifyJS.SourceMap {
		file: filename + '.min.js',
		root: '',
		orig: v3SourceMap
	}
	stream = UglifyJS.OutputStream {
		source_map: source_map,
		beautify: true,
		comments: true
	}
	toplevel.print(stream)
	console.log 

	# result = UglifyJS.minify js, {
	# 	inSourceMap: filename + '.js.map',
	# 	outSourceMap: filename + '.map',
	# 	output: {
	# 		beautify: true
	# 	},
	# 	fromString: true
	# }

	# console.log result


	consumer = new SourceMap.SourceMapConsumer(source_map.toString())

	node = SourceMap.SourceNode.fromStringWithSourceMap(stream.toString(), consumer)

	nodes.push node


combined = new SourceMap.SourceNode(null, null, null, nodes)

outname = 'magicponies.js'

combined.prepend "//@ sourceMappingURL=#{outname}.map\n"

out = combined.toStringWithSourceMap { file: outname, sourceRoot: '' }

fs.writeFileSync outname, out.code, 'utf8'

fs.writeFileSync outname + '.map', out.map.toString(), 'utf8'