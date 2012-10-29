var http = require('http'),
    httpProxy = require('http-proxy');

httpProxy.createServer(function (req, res, proxy) {
  
  var buffer = httpProxy.buffer(req);

  setTimeout(function () {
    proxy.proxyRequest(req, res, {
      host: 'localhost',
      port: 5555,
      buffer: buffer
    });
  }, 1000 + Math.floor(Math.random() * 1000));
}).listen(8000);
