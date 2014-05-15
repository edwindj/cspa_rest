
function Job(service, name, input, on_end){
	this.name = name;
	this.version = service.version;
	this.input = input;
	this.result = {};
	this.created = new Date();
	this.on_end = on_end;
}

//node.js needed for node.js
exports.Job = Job;