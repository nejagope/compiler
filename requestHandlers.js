var querystring = require("querystring");
var fs = require("fs");
var compilador = require("./analizador.js");

function index(response, postData) {    
    let data = fs.readFileSync('./index.htm', 'utf8');
    let plantilla = data.split("{%}");
    //console.log(plantilla.length);
    //console.log(plantilla);
    /*
    for (var i = 0; i < 100; i++) {
        plantilla[0] += '<tr><td width="25%">' + i + '</td><td><p class="lineaEditor"> Un texto de prueba</p></td>';
        plantilla[1] += '<tr><td width="25%">' + i + '</td><td><p class="lineaEditor"> Un texto de C4D de prueba</p></td>';
    }
    */
    let html = plantilla[0] + plantilla[1] + plantilla[2]; 
    response.writeHead(200, {"Content-Type": "text/html"});
    response.write(html);            
    response.end();
    
}

function compilar(response, postData) {    
    let dataHtml = fs.readFileSync('./compilar.htm', 'utf8');
    let plantilla = dataHtml.split("{%}");    
    let codigo = querystring.parse(postData)["txtCode0"];

    let codigoIntermedio = compilador.getCodigoIntermedio(codigo);

    codigo = codigo.replace('\t', '  ');
    //plantilla[0] += codigo;

    //plantilla[1] += codigoIntermedio;

    let lineasCodigo = codigo.split('\n');
    lineasCodigo.forEach(function(linea, i){
        plantilla[0] += '<tr><td width="15%">' + (i+1) + '</td><td><p class="lineaEditor">'+ linea +'</p></td>';
    });

    let c4ds = codigoIntermedio.split('|');
    c4ds.forEach(function(c4d){
        if (!c4d)
            return false;
        c4d = c4d.split('#');
        let cantGuiones = 20 - c4d[0].length
        let linea = c4d[0] + ' ';
        if (!c4d[0].startsWith('L') && !c4d[0].startsWith('jmp')){
            for (var i = 0; i< cantGuiones; i++)
                linea += '.';
            plantilla[1] += (linea + ' linea: ' + c4d[1]) + '<br>';     
        }else{
            plantilla[1] += (c4d[0]) + '<br>';     
        }
    });
    /*
    for (var i = 0; i < 100; i++) {
        plantilla[0] += '<tr><td width="25%">' + i + '</td><td><p class="lineaEditor"> Un texto de prueba</p></td>';
        plantilla[1] += '<tr><td width="25%">' + i + '</td><td><p class="lineaEditor"> Un texto de C4D de prueba</p></td>';
    }
    */

    let html = plantilla[0] + plantilla[1] + plantilla[2]; 

    response.writeHead(200, {"Content-Type": "text/html"});    
    response.write(html);    
    //response.write("Tu enviaste: " + querystring.parse(postData)["txtCode0"]);
    response.end(); 
}
/*
function index(response, postData) {	
	console.log("Manipulador de petición 'iniciar' ha sido llamado.");
	var contenido = '<html>'+
    '<head>'+
    '<meta charset=UTF-8" />'+
    '</head>'+
    '<body>'+
    '<form action="/subir" method="post">'+
    '<textarea id="areaTexto" name = "text" rows="20" cols="60"></textarea>'+
    '<input type="submit" value="Enviar texto" />'+
    '</form>'+
    '</body>'+
    '</html>';

    response.writeHead(200, {"Content-Type": "text/html"});
    response.write(contenido);
    response.end();
}
*/

function subir(response, postData) {
	console.log("Manipulador de petición 'subir' fue llamado.");
	response.writeHead(200, {"Content-Type": "text/html"});
	response.write("Tu enviaste: " + querystring.parse(postData)["text"]);
	response.end();	
}

exports.index = index;
exports.subir = subir;
exports.compilar = compilar;
