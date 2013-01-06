var http = require('http');
var fs = require('fs');

var log = fs.createWriteStream(__dirname + '/protobowl.log', {'flags': 'a'});

http.createServer(function (req, res) {
	console.log("got request", req.url)
	if(req.url == '/check'){
		var q = http.request({
			host: 'protobowl.com',
			port: 80,
			path: '/zombo-cogito-ergo-sum',
			method: 'GET'
		}, function(r){
			var body = '';
			r.setEncoding('utf8');
			r.on('data', function(chunk){
				body += chunk;
			});
			r.on('end', function(){
				res.writeHead(200, {'Content-Type': 'text/plain'})
				res.write(body);
				res.end()
			})
		});
		q.on('error', function(e){
			console.log('error checking', e);
			res.end('error');
		})
		q.end();
	}else if(req.url == "/log"){
		req.on('data', function (chunk) {
			log.write(chunk)
		})
		res.end()
	}else if(req.url == '/read'){
		res.write(fs.readFileSync(__dirname + '/protobowl.log'))
		res.end()
	}else{
		res.write('404');
		res.end()
	}
	
}).listen(52849, '127.0.0.1');
console.log('Server running at http://127.0.0.1:inception/');