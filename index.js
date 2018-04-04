var servidor = require("./server.js");
var router = require("./router.js");
var requestHandlers = require("./requestHandlers");

var handle = {};
handle["/"] = requestHandlers.index;
handle["/index"] = requestHandlers.index;
handle["/subir"] = requestHandlers.subir;

servidor.iniciar(router.route, handle);
