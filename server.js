// to support iisnode
var PORT = process.env.PORT || 8080;
var VPATH = process.env.VPATH || "";

// initialise server
var restify = require('restify');
var server = restify.createServer();
server.pre(restify.pre.userAgentConnection());
server.use(restify.bodyParser());

var cspa = require("./libs/service.js");

// serve bootstrap and jQuery
server.get(/^\/external.*/, restify.serveStatic({
    directory: __dirname
}));	

server.listen(PORT, "127.0.0.1", function() {
  console.log("Service started.");
  // create service
  var lrc  = cspa(server, __dirname + "/LRC", VPATH);
  var lel  = cspa(server, __dirname + "/LEL", VPATH);
  var lec  = cspa(server, __dirname + "/LEC", VPATH);
});


