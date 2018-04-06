var http = require("http");
var url = require("url");

function iniciar(route, handle) {
  function onRequest(request, response) {
	
    var pathname = url.parse(request.url).pathname;
    console.log("Petición para " + pathname + " recibida.");	
	
	request.setEncoding("utf8");
	var dataPosteada = "";
	
	request.addListener("data", function(trozoPosteado) {
		console.log("Se ha recibido parte de la info");		
		console.log("Recibido trozo POST '" + trozoPosteado + "'.");		
		dataPosteada += trozoPosteado;
		//aqui es necesario revisar el tamañno del mensaje recibido
		//hay que colocar una cota superior con dataPosteada.length
		});
		
	request.addListener("end", function() {
		console.log("Se ha recibido el post totalmente: " + dataPosteada);		
		route(pathname, handle, response, dataPosteada);
		});
	
  }
  http.createServer(onRequest).listen(8888);
  console.log("Servidor Iniciado.");
}

exports.iniciar = iniciar;