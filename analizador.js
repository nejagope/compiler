var parser = require("./parser").parser;
var fs = require("fs");

var ts = [];
var codigo = fs.readFileSync("test.src", "utf8");
var ast = getAST(codigo);
asinarIDs(ast, 0);
console.log(jsonToString(ast));
asignarAmbitos(ast);
llenarTablaSimbolos(ast);
mostrarTablaSimbolos();

function mostrarTablaSimbolos(){
	console.log('\n-------------------------- TABLA DE SÍMBOLOS -------------------------');
	ts.forEach (function(simbolo, i){		
		console.log((i+1) + '-' + jsonToString(simbolo));
	});
	console.log('\n------------------------- FIN TABLA DE SÍMBOLOS ----------------------');
}

function cl(msj){
	console.log('\n' + msj);
}

function exec (input) {
    var res = parser.parse(input);
    console.log( JSON.stringify() );
}

function jsonToString(json){
  return JSON.stringify(json);
}

function getAST(codigoFuente){
	try{
		var res = parser.parse(codigoFuente);    
	    return res;	
	}catch(ex){
		console.log(ex);
		return [];
	}	
}

function llenarTablaSimbolos(ast){
	if (!ast.hijos)
		return false;

	if (ast.tipo == 'decl' || ast.tipo == 'funcion'	|| ast.tipo == 'clase')
	{
		var simbolo = {			
			tipo: ast.tipo == 'decl'? 'var': ast.tipo,
			ambito: ast.ambito,					
		};

		if (ast.tipo == 'decl' || ast.tipo == 'funcion'){
			simbolo.id = ast.hijos[1].val;

			if(ast.tipoDato)
				simbolo.tipoDato = ast.tipoDato;
			
		}
		else if (ast.tipo == 'clase'){
			simbolo.id = ast.hijos[0].val;
		}

		if (ast.tipo == 'funcion'	|| ast.tipo == 'clase')
		{
			var nodoSents = getHijo(ast, 'sents');			
			if (nodoSents != -1){
				simbolo.ambitoContenido = nodoSents.ambito;
			}
		}

		if (ast.tipo == 'funcion')
		{
			var nodoSents = getHijo(ast, 'sents');			
			if (nodoSents != -1){
				simbolo.ambitoContenido = nodoSents.ambito;
			}
		}
	
		ts = ts.concat(simbolo);

	}

	ast.hijos.forEach (function(hijo){		
		llenarTablaSimbolos(hijo);
	});	
}

function asignarAmbitos(ast){
	if (!ast.hijos)
		return false;

	ast.hijos.forEach (function(nodo, i){
		if (nodo.tipo == 'decl' || nodo.tipo == 'funcion' || nodo.tipo == 'clase')
		{
			nodo.ambito = ast.ambito;
		}
		console.log(i + " -> " + jsonToString(nodo));
		console.log('\n-----------------------------------------------------------------------------');
		asignarAmbitos(nodo);
	});
}

function asinarIDs(ast, id){
	ast.nid = id + 1;

	var limSupAmbito = ast.nid;

	if (ast.hijos){		
		ast.hijos.forEach (function(hijo){
			limSupAmbito = asinarIDs(hijo, limSupAmbito);
		});
	}	
	ast.ambito = [ast.nid, limSupAmbito];
	return limSupAmbito;
}


function getHijo(ast, tipo){
	var nodo = -1;
	ast.hijos.forEach (function(hijo){
		if (hijo.tipo == tipo){			
			nodo = hijo;
			return -1; 
		}

	});
	return nodo;
}
