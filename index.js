
var PORT = 8080;

// initialise server
var restify = require('restify');
var server = restify.createServer();
server.pre(restify.pre.userAgentConnection());
server.use(restify.bodyParser());

server.listen(PORT, function() {
  console.log("Service started.");
});

// create service
var cspa = require("./libs/service.js");
var lrc  = cspa(server, __dirname + "/LRC");

