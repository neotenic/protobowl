var http = require('http');
var fs = require('fs');

http.createServer(function (req, res) {
	console.log("got request", req.url)
	if(req.url == "/log"){
		req.on('data', function (chunk) {
			console.log(fs.appendFileSync(__dirname + "/../protobowl.log", chunk))
		})
	}
	res.end()
}).listen(52849, '127.0.0.1');
console.log('Server running at http://127.0.0.1:inception/');