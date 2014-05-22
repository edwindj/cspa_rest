var PORT = 8080;

var restify = require('restify');
var CSPA = require("./service.js")

var server = restify.createServer();
server.pre(restify.pre.userAgentConnection());
server.use(restify.bodyParser());

var lrc = new CSPA.Service("./LRC/service.yaml");
lrc.add_to(server);

var lel = new CSPA.Service("./LEL/service.yaml");
lel.add_to(server);

server.listen(PORT, function() {
  console.log('%s listening at %s', server.name, server.url);
});
