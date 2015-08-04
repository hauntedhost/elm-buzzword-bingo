var http = require('http');
var httpProxy = require('http-proxy');
var express = require('express');

// create a server
var app = express();
var proxy = httpProxy.createProxyServer({ ws: true });

proxy.on('error', function(err, req, res) {
  console.log('ERROR:', err);
});

// proxy /_reactor
app.get('/_reactor/*', function(req, res) {
  console.log("proxying GET request", req.url);
  proxy.web(req, res, {
    target: 'http://localhost:8000'
  });
});

// proxy websockets
var server = require('http').createServer(app);
server.on('upgrade', function (req, socket, head) {
  console.log("proxying upgrade request", req.url);
  proxy.ws(req, socket, head, {
    target: 'http://localhost:8000'
  });
});

// serve static content
app.use('/', express.static(__dirname));

console.log('Elm Proxy v0.1');
console.log('Listening on http://0.0.0.0:9000/');
console.log('1. Open Elm Reactor at http://localhost:8000')
console.log('2. Open Elm Proxy at http://localhost:9000/debug.html')

server.listen(9000);
