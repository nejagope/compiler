var parser = require("./parser").parser;
var fs = require("fs");

var codigo = fs.readFileSync("test.src", "utf8");
const AMBITO_GLOBAL = [0, 1000000];
var ts = [];
var ast = getAST(codigo);
asinarIDs(ast, 0);
console.log(jsonToString(ast));
asignarAmbitos(ast);
llenarTablaSimbolos(ast);
mostrarTablaSimbolos();

var sp = 0;	//stackpointer
var st = 0;
var l = 0;
var t = 0;
var c4d = '';
var c4ds = [];

generarCuadruplos(ast);
mostrarC4Ds();

function mostrarTablaSimbolos(){
	console.log('\n-------------------------- TABLA DE SÍMBOLOS -------------------------');
	ts.forEach (function(simbolo, i){		
		console.log((i+1) + '-' + jsonToString(simbolo) + '\n');
	});
	console.log('\n------------------------- FIN TABLA DE SÍMBOLOS ----------------------');
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
	if (!ast)
		return;

	if (!ast.hijos)
		return false;

	if (ast.tipo == 'prog'){
				
		ast.hijos[0].hijos.forEach(function(nodo){ //se examinan las sentencias del programa
			if (nodo.tipo == 'clase' || nodo.tipo == 'estructura')
			{
				var simbolo = {			
					tipo: nodo.tipo == 'decl'? 'var': nodo.tipo,
					ambito: AMBITO_GLOBAL,								
					id: nodo.hijos[0].val
				};

				var nodoSents = getHijo(nodo, 'sents');			
				if (nodoSents != -1){
					simbolo.ambitoContenido = nodoSents.ambito;
				}
				simbolo.tamanio = 0;
				
				agregarTS(simbolo);				
				llenarTablaSimbolos(nodo.hijos[1]);	//se examinan las sentencias de la clase o estructura
			}//if (nodo.tipo == 'clase' || nodo.tipo == 'estructura')			
		});		
		
	} //if (ast.tipo == 'prog')
	else{
		if (ast.tipo == 'decl' || ast.tipo == 'funcion' || ast.tipo == 'estructura')
		{
			var postAddSim = [];

			var simbolo = {			
				tipo: ast.tipo == 'decl'? 'var': ast.tipo,
				ambito: ast.ambito,								
			};

			if (ast.tipo == 'decl' || ast.tipo == 'funcion'){
				simbolo.id = ast.hijos[1].val;

				if(ast.tipoDato)
					simbolo.tipoDato = ast.tipoDato;
				
			}
			else if (ast.tipo == 'clase' || ast.tipo == 'estructura'){
				simbolo.id = ast.hijos[0].val;
			}

			if (ast.tipo == 'funcion'	|| ast.tipo == 'clase' || ast.tipo == 'estructura')
			{
				var astSents = getHijo(ast, 'sents');			
				if (astSents != -1){
					simbolo.ambitoContenido = astSents.ambito;
				}
				simbolo.tamanio = 0;
			}

			if (ast.tipo == 'funcion')
			{
				simbolo.tamanio = 1; //retorno
				simbolo.nodo = ast;
				var astSents = getHijo(ast, 'sents');			
				if (astSents != -1){
					simbolo.ambitoContenido = astSents.ambito;
				}

				var astParams = getHijo(ast, 'params');			
				if (astParams != -1){
					astParams.hijos.forEach (function(param){		
						var simParam = {			
							tipo: 'param',
							ambito: simbolo.ambitoContenido,					
							id : param.hijos[1].val,
							tipoDato: param.hijos[0].val
						};	
						postAddSim = postAddSim.concat(simParam);											
					});	
				}
			}

			agregarTS(simbolo);
			postAddSim.forEach(function(postSim){
				agregarTS(postSim);
			});
		}//if (ast.tipo == 'decl' || ast.tipo == 'funcion'	|| ast.tipo == 'clase' || ast.tipo == 'estructura')

		ast.hijos.forEach (function(hijo){
			llenarTablaSimbolos(hijo);	
		});	

	} //if (ast.tipo = 'prog')... else 	
}


function agregarTS(simbolo){
	if (simbolo.tipo == 'var' || simbolo.tipo == 'param'){
		var ambito = simbolo.ambito;	
		//se asigna la posición del símbolo dentro del bloque
		var posicion = 0;
		ts.forEach (function(sim){
			if (ambito == sim.ambito){
				posicion++;
			}

			if (ambito == sim.ambitoContenido){
				sim.tamanio ++;
			}
		});
		
		
		simbolo.posicion = posicion;
	}
	
	ts = ts.concat(simbolo);
}

function getSimbolo(id, tipo, nodo = false){
	var simbolo = -1;
	ts.forEach(function(sim){
		if (sim.id == id && sim.tipo == tipo){
			if (sim.ambito[0] >= nodo.nid && sim.ambito[1] <= nodo.nid)
				simbolo = sim;
			else
				simbolo = sim;
			return false;
		}
	});
	return simbolo;
}

function asignarAmbitos(ast){	
	if (!ast.hijos)
		return false;

	ast.hijos.forEach (function(nodo, i){
		if (!nodo)
			return false;
		if (nodo.tipo == 'decl' || nodo.tipo == 'funcion' || nodo.tipo == 'clase' || nodo.tipo == 'estructura')
		{
			nodo.ambito = ast.ambito;
		}
		console.log('\n-----------------------------------------------------------------------------');
		console.log(i + " -> " + jsonToString(nodo));
		console.log('\n-----------------------------------------------------------------------------');
		asignarAmbitos(nodo);
	});
}

/**Asigna ids enteros a los nodos del ast iniciando con @id*/
function asinarIDs(ast, id){	
	ast.nid = id + 1;

	var limSupAmbito = ast.nid;

	if (ast.hijos){		
		ast.hijos.forEach (function(hijo){
			if (hijo)
				limSupAmbito = asinarIDs(hijo, limSupAmbito);
		});
	}	
	ast.ambito = [ast.nid, limSupAmbito];
	return limSupAmbito;
}


/** Obtiene el primer hijo del @tipo de un árbol ast*/
function getHijo(ast, tipo){
	var nodo = -1;
	ast.hijos.forEach (function(hijo){		
		if (hijo && hijo.tipo == tipo){			
			nodo = hijo;
			return -1; 
		}

	});
	return nodo;
}

function generarCuadruplos(ast){
	c4d = ''; //código de 4 direcciones
	l = 0; //indice etiquetas
	t  = 0; //indice temporales
	sp = 0; //stack pointer
	st = 0; //stack top
	c4ds = []; //líneas de c4d asociadas a una linea de código fuente
	var main = getSimbolo('principal', 'funcion');	
	if (main != -1){
		st += main.tamanio;		
		var nodoSents = getHijo(main.nodo,'sents');		
		cuadruplos(nodoSents);		
	}			
}

function mostrarC4Ds(){
	c4ds = c4d.split('|');
	c4ds.forEach(function(c4d){
		c4d = c4d.split('#');
		console.log(c4d[0] + ' --------------- linea: ' + c4d[1]);		
	});
}

function cuadruplos(ast, etIni = null, etFin = null, etRet = null){	
	switch(ast.tipo){
		case 'sents':					
			let c4dSents = '';
			for (var i = 0; i < ast.hijos.length; i++) {								
				let resSent = cuadruplos(ast.hijos[i], etIni, etFin, etRet);
				if (resSent && resSent.c4d){					
					c4dSents += resSent.c4d;					
				}
			}
			return { c4d: c4dSents };

		case 'decl':
			if (ast.hijos.length < 3){ //declaración sin asignación
				break;
			}			
		case '=':			
			var asignando = ast.hijos[0];
			if (ast.tipo == 'decl')
				asignando = ast.hijos[1];
			
			var asignante = ast.hijos[1];
			if (ast.tipo == 'decl')
				asignante = ast.hijos[2];

			if (asignando.tipo == 'id'){
				var sim = getSimbolo(asignando.val, 'param', ast);
				if (sim == -1){
					sim = getSimbolo(asignando.val, 'var', ast);
				}
				if (sim != -1){					
					var pos = sim.posicion;										
					var tAsignante = cuadruplos(asignante);
					c4d = tAsignante.c4d;
					c4d += '+' + ',' + (sp) + ',' + (pos) + ',' + 't' + (++t) + '#' + ast.linea + '|';					
					c4d += '<=' + ',' + ('t'+ t) + ',' + (tAsignante.t) + ',' + 'stack' + '#' + ast.linea + '|';					
					return { c4d: c4d };
				}
			}
			return {};

		case 'si':
			let condSi = cuadruplos(ast.hijos[0]);
			c4d = condSi.c4d;			

			var nodoVSi = getHijo(ast, 'es_verdadero');					
			var nodoFSi = getHijo(ast, 'es_falso');	

			let etFinSi = genEt();		
			
			c4d += etsToC4D(condSi.etsV, ast.linea);
			if (nodoVSi != -1){				
				c4d += cuadruplos(nodoVSi.hijos[0], etIni, etFin, etRet).c4d;				
				c4d += 'jmp,,,' + etFinSi + "#" + ast.linea + '|';	
			}			
			
			c4d += etsToC4D(condSi.etsF, ast.linea);
			if (nodoFSi != -1){
				c4d += cuadruplos(nodoFSi.hijos[0], etIni, etFin, etRet).c4d;
				c4d += 'jmp,,,' + etFinSi + "#" + ast.linea + '|';				
			}
			c4d += etFinSi + ":#" + ast.linea + '|';
			return { c4d : c4d };

		case 'repetir_mientras':
			let etIniRM = genEt();
			let etVRM = genEt();
			let etFRM = genEt();

			pushC4D(etIniRM + ':', ast.hijos[0].linea);			
			c4d = 'je' + ',' + (cuadruplos(ast.hijos[0])) + ',' + (1) + ',' + (etVRM);
			pushC4D(c4d, ast.hijos[0].linea);
			pushC4D('jmp,,,' + etFRM, ast.hijos[0].linea);	
			pushC4D(etVRM + ':', ast.hijos[0].linea);
			cuadruplos(ast.hijos[1], etIniRM, etFRM, etRet);
			pushC4D('jmp,,,' + etIniRM, ast.hijos[0].linea);	
			pushC4D(etFRM + ':', ast.hijos[0].linea);
			return;
			/*
			let etIniRM = 'L' + (++l) + ':';
			c4ds = c4ds.concat({c4d: etIniRM , linea: ast.hijos[0].linea});
			c4ds = c4ds.concat({c4d: 'L' + l + ':', linea: ast.linea});			
			let etVRM = 'L' + (cuadruplos(ast.hijos[0], etIni, etFin, etRet)) + ':';
			let etFRM = 'L' + (++l) + ':';
			c4ds = c4ds.concat({c4d: 'jmp,,,' + etFRM , linea: ast.hijos[0].linea});	
			c4ds = c4ds.concat({c4d: etVRM , linea: ast.hijos[0].linea});						
			cuadruplos(ast.hijos[1], etIniRM, etFRM, etRet);
			c4ds = c4ds.concat({c4d: 'jmp,,,' + etIniRM , linea: ast.hijos[0].linea});	
			c4ds = c4ds.concat({c4d: etFRM , linea: ast.hijos[0].linea});
			return;
			*/
		case 'hacer':
			let etVHacer = genEt();
			let etFHacer = genEt();
			let etIniHacer = genEt();			
			pushC4D(etVHacer, ast.hijos[0].linea);
			cuadruplos(ast.hijos[0], etIniHacer, etFHacer, etRet);
			pushC4D(etIniHacer, ast.hijos[1].linea);
			c4d = 'je' + ',' + (cuadruplos(ast.hijos[1])) + ',' + (1) + ',' + (etVHacer);
			pushC4D(etFHacer, ast.hijos[1].linea);
			/*
			let etVHacer = {c4d: '', linea: ast.hijos[0].linea};
			c4ds = c4ds.concat(etVHacer);
			cuadruplos(ast.hijos[0], etIni, etFin, etRet);
			etVHacer.c4d = 'L' + (cuadruplos(ast.hijos[1], etIni, etFin, etRet)) + ':';												
			return;
			*/
		case 'ciclo_doble_condicion':
			/*
			let etIniCDC = 'L' + (++l) + ':';
			c4ds = c4ds.concat({c4d: etIniCDC , linea: ast.hijos[0].linea});						
			let etVCDC1 = 'L' + (cuadruplos(ast.hijos[0], etIni, etFin, etRet)) + ':';			
			let etFCDC = 'L' + (++l) + ':';
			c4ds = c4ds.concat({c4d: 'jmp,,,' + etFCDC , linea: ast.hijos[0].linea});
			c4ds = c4ds.concat({c4d: etVCDC1 , linea: ast.hijos[0].linea});						
			let etVCDC2 = 'L' + (cuadruplos(ast.hijos[1], etIni, etFin, etRet)) + ':';			
			c4ds = c4ds.concat({c4d: 'jmp,,,' + etFCDC , linea: ast.hijos[0].linea});
			c4ds = c4ds.concat({c4d: etVCDC2 , linea: ast.hijos[0].linea});									
			cuadruplos(ast.hijos[2], etIni, etFin, etRet);
			c4ds = c4ds.concat({c4d: 'jmp,,,' + etIniCDC , linea: ast.hijos[0].linea});
			c4ds = c4ds.concat({c4d: etFCDC , linea: ast.hijos[0].linea});
			*/
			return;

		case 'repetir':
			/*
			let etIniRep = 'L' + (++l) + ':';
			c4ds = c4ds.concat({c4d: etIniRep , linea: ast.hijos[0].linea});
			cuadruplos(ast.hijos[0], etIni, etFin, etRet);
			let etFinRep = 'L' + (cuadruplos(ast.hijos[1], etIni, etFin, etRet)) + ':';		
			c4ds = c4ds.concat({c4d: 'jmp,,,' + etIniRep , linea: ast.hijos[1].linea});										
			c4ds = c4ds.concat({c4d: etFinRep , linea: ast.hijos[1].linea});	
			*/									
			return;

		case 'retornar':
			//todo setear el valor en el stack
			c4ds = c4ds.concat({c4d: 'jmp,,,' + etRet , linea: ast.linea});										
			return;
		case 'romper':			
			c4ds = c4ds.concat({c4d: 'jmp,,,' + etFin , linea: ast.linea});										
			return;
		case 'continuar':			
			c4ds = c4ds.concat({c4d: 'jmp,,,' + etIni , linea: ast.linea});										
			return;

		case '+':
		case '-':
		case '*':
		case '/':		
			 c4d = ast.tipo + ',' + (cuadruplos(ast.hijos[0])) + ',' + (cuadruplos(ast.hijos[1])) + ',' + ('t'+ (++t));
			 c4ds = c4ds.concat({c4d: c4d, linea: ast.linea});
			 return 't' + t;
		
		case '==':			
		case '!=':			
		case '>=':			
		case '<=':			
		case '>':			
		case '<':			
			let etVComp = genEt();			
			let etFComp = genEt();
			
			let opComp = 'je';
			if (ast.tipo == '!=')
				opComp = 'jne';
			else if (ast.tipo == '>=')
				opComp = 'jge';
			else if (ast.tipo == '<=')
				opComp = 'jle';
			else if (ast.tipo == '>')
				opComp = 'jg';
			else if (ast.tipo == '<')
				opComp = 'jl';

			let comp1 = cuadruplos(ast.hijos[0]);			
			let comp2 = cuadruplos(ast.hijos[1]);

			c4d = comp1.c4d + comp2.c4d;
			c4d += opComp + ',' + (comp1.t) + ',' + (comp2.t) + ',' + (etVComp) + '#' + ast.linea + '|';
			c4d += 	'jmp,,,' + (etFComp) + '#' + ast.linea + '|';
															
			return {etsV: [etVComp], etsF: [etFComp], c4d: c4d};

		case '||':			
			let Or1 = cuadruplos(ast.hijos[0]);
			let Or2 = cuadruplos(ast.hijos[1]);

			c4d = Or1.c4d;			
			c4d += etsToC4D(Or1.etsF, ast.linea);
			c4d += Or2.c4d;
			
			return {etsF: [], etsV: Or1.etsV.concat(Or2.etsV), c4d: c4d };

		case 'id':
			var sim = getSimbolo(ast.val, 'param', ast);
			if (sim == -1){
				var sim = getSimbolo(ast.val, 'var', ast);
			}
			if (sim != -1){					
				var pos = sim.posicion;														
				c4d = '+' + ',' + (sp) + ',' + (pos) + ',' + 't'+(++t)+ '#' + ast.linea + '|';				
				c4d += '=>' + ',' + ('t'+ t) + ',' + 't'+(++t) + ',' + 'stack'+ '#' + ast.linea + '|';			
				return {t: 't' + t, c4d: c4d };
			}
		case 'enteroLit':
			c4d = '=' + ',' + (ast.val) + ',' + '' + ',' + ('t'+(++t)) + '#' + ast.linea + '|';								
			return {t: 't' + t, c4d: c4d };

		case 'booleanoLit':
			c4d = '=' + ',' + (ast.val) + ',' + '' + ',' + ('t'+(++t)) + '#' + ast.linea + '|';
			return {t: 't' + t, c4d: c4d };
	}
}

function pushC4D(sent, linea){
	c4ds = c4ds.concat({c4d: sent, linea: linea});
}

function getSentEt(et){
	return et + ':';
}

function genEt(){
	return 'L' + (++l);
}

function genTemp(){
	return 't' + (++t);
}

function etsToC4D(ets, linea){
	let etsC4d = '';
	ets.forEach(function(et){
		etsC4d += et + ':#' + linea + '|';
	});
	return etsC4d;
}
