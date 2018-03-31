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
var st = 0; //stacktop
var hp = 0; //heappointer
var ht = 0;
var l = 0;
var t = 0;
var c4d = '';
var c4ds = [];

var resCuadruplosProg = generarCuadruplos(ast);
mostrarC4Ds(resCuadruplosProg.c4d);

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
		if (ast.tipo == 'repetir_contando')
		{
			var astSents = getHijo(ast, 'sents');
			var simbolo = {			
				tipo: 'var',
				ambito: astSents.ambito,
				id : ast.hijos[0].val,
				tipoDato: 'entero',								
			};
			agregarTS(simbolo);
		}
		else if (ast.tipo == 'decl' || ast.tipo == 'funcion' || ast.tipo == 'estructura')
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

function esTipoNativo(tipo){
	return tipo == 'entero'
		|| tipo == 'caracter'
		|| tipo == 'booleano'
		|| tipo == 'decimal'
		|| tipo == 'cadena';
}


function agregarTS(simbolo){
	if (simbolo.tipo == 'var' || simbolo.tipo == 'param'){
		var ambito = simbolo.ambito;	
		
		var ambitoPadreHallado = false;
		
		ts.forEach (function(sim){
			if (ambito == sim.ambitoContenido){
				if (sim.tipo == 'funcion')
					simbolo.posicion = sim.tamanio - 1;
				else
					simbolo.posicion = sim.tamanio;
				
				sim.tamanio ++;
				simbolo.ambitoPertenece = sim.ambitoContenido;
				ambitoPadreHallado = true;
				return false;
			}
		});
		
		if (!ambitoPadreHallado){
			//es probable que la declaración esté en un ambito contenido por el símbolo padre
			//debe buscarse el simbolo superior que lo contiene
			var simboloPadre = null;

			ts.forEach (function(sim){
				if (sim.tipo == 'funcion' && sim.ambitoContenido[0] <= ambito[0] && sim.ambitoContenido[1] >= ambito[1]){					
					simbolo.posicion = sim.tamanio - 1;
					sim.tamanio ++;
					simbolo.ambitoPertenece = sim.ambitoContenido;
					return false;
				}
			});
		}
				
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
		return cuadruplos(nodoSents);		
	}			
}

function mostrarC4Ds(c4d){
	console.log('-------------------- CUÁDRUPLOS ------------------')	
	c4ds = c4d.split('|');
	c4ds.forEach(function(c4d){
		if (!c4d)
			return false;
		c4d = c4d.split('#');
		let cantGuiones = 20 - c4d[0].length
		let linea = c4d[0] + ' ';
		if (!c4d[0].startsWith('L') && !c4d[0].startsWith('jmp')){
			for (var i = 0; i< cantGuiones; i++)
				linea += '.';
			console.log(linea + ' linea: ' + c4d[1]);		
		}else{
			console.log(c4d[0]);
		}
	});
	console.log('------------------ FIN - CUÁDRUPLOS ----------------')
}


function cuadruplos(ast, etIni = null, etFin = null, etRet = null){	

	switch(ast.tipo){
		case 'sents':										
			var c4dSents = '';
			for (var i = 0; i < ast.hijos.length; i++) {		
				//console.log(ast.hijos[i].tipo);						
				let resSent = cuadruplos(ast.hijos[i], etIni, etFin, etRet);
				//console.log(resSent);
				if (resSent && resSent.c4d){					
					c4dSents += resSent.c4d;					
				}
			}
			//console.log('ret ' + c4dSents)
			return { c4d: c4dSents };

		case 'decl':
			if (ast.hijos.length < 3){ //declaración sin asignación
				let nodoTipoDecl = ast.hijos[0];
				if (nodoTipoDecl.tipo == 'id'){
					let simEstrucDecl = getSimbolo(nodoTipoDecl.val, 'estructura', nodoTipoDecl);
					//console.log(simEstrucDecl);					
					//todo
				}
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

		case 'contador':
			let etIniCon = genEt();
			let etFinCon = genEt();
			let tContCon = genTemp();
			let resLimCon = cuadruplos(ast.hijos[0]);
			let resSentsCon = cuadruplos(ast.hijos[1], etIniCon, etFinCon, etRet);
			//contado = 0
			c4d = '=' + ',' + (0) + ',' + '' + ',' + (tContCon) + '#' + ast.hijos[0].linea + '|';
			//obtener la cantidad de iteraciones			
			c4d += resLimCon.c4d;
			//inicio del ciclo
			c4d += etIniCon + ':' + '#' + ast.hijos[0].linea + '|';	
			//comparar el contador al límite
			c4d += 'jge' + ',' + (tContCon) + ',' + (resLimCon.t) + ',' + (etFinCon) + '#' + ast.hijos[0].linea + '|';
			//sentencias			
			c4d += resSentsCon.c4d;
			//incrementar el contador
			c4d += '+' + ',' + (tContCon) + ',' + (1) + ',' + (tContCon) + '#' + ast.hijos[0].linea + '|';	
			//reiniciar ciclo
			c4d += 'jmp,,,' + etIniCon + '#' + ast.hijos[1].linea + '|';	
			c4d += etFinCon + ':' + '#' + ast.hijos[1].linea + '|'; //salida del ciclo				
			return { c4d: c4d };

		case 'enciclar':

			let etIniEn = genEt();
			let etFinEn = genEt();
			let resSentsEn = cuadruplos(ast.hijos[1], etIniEn, etFinEn, etRet);
			c4d = etIniEn + ':' + '#' + ast.hijos[0].linea + '|';
			c4d += resSentsEn.c4d;
			c4d += 'jmp,,,' + etIniEn + '#' + ast.hijos[0].linea + '|';
			c4d += etFinEn + ':' + '#' + ast.hijos[0].linea + '|'; //salida del ciclo	
			return { c4d: c4d };

		case 'repetir_contando':

			let etIniRC = genEt();
			let etFinRC = genEt();

			let idRC = ast.hijos[0];
			let simIdRC = getSimbolo(idRC.val, 'var', ast.hijos[2]);

			//valor desde y hasta
			let resDesdeRC = cuadruplos(ast.hijos[1]);		
			let resHastaRC = cuadruplos(ast.hijos[2]);	

			c4d = resDesdeRC.c4d;
			c4d += resHastaRC.c4d;

			//posición en stack de la variable contador
			let tPosContadorRC = genTemp();	
			//se asigna el valor inicial a la variable contador
			c4d += '+' + ',' + (sp) + ',' + (simIdRC.posicion) + ',' + (tPosContadorRC) + '#' + ast.hijos[1].linea + '|';					
			c4d += '<=' + ',' + (tPosContadorRC) + ',' + (resDesdeRC.t) + ',' + 'stack' + '#' + ast.hijos[1].linea + '|';					

			//se decide si el contador crecerá o decrecerá, paso = 1 o -1
			let etAscRC = genEt();
			let pasoRC = genTemp();	
			c4d += 'jle' + ',' + (resDesdeRC.t) + ',' + (resHastaRC.t) + ',' + (etAscRC) + '#' + ast.hijos[1].linea + '|';
			c4d += '=' + ',' + (-1) + ',' + '' + ',' + (pasoRC) + '#' + ast.hijos[1].linea + '|';
			c4d += 'jmp,,,' + etIniRC + '#' + ast.hijos[1].linea + '|';
			c4d += etAscRC + ':' + '#' + ast.hijos[1].linea + '|';
			c4d += '=' + ',' + (1) + ',' + '' + ',' + (pasoRC) + '#' + ast.hijos[1].linea + '|';
			
			//inicio del ciclo como tal
			c4d += etIniRC + ':' + '#' + ast.hijos[1].linea + '|';
			//obtener el valor del contador
			c4d += '=>' + ',' + (tPosContadorRC) + ',' + 't'+(++t) + ',' + 'stack'+ '#' + ast.hijos[1].linea + '|';	
			//comparar el valor del contador con el hasta
			c4d += 'je' + ',' + ('t'+ t) + ',' + (resHastaRC.t) + ',' + (etFinRC) + '#' + ast.hijos[1].linea + '|';
			//sentencias
			c4d += cuadruplos(ast.hijos[3], etIniRC, etFinRC, etRet).c4d;
			//aumentar o decrementar contador
			c4d += '=>' + ',' + (tPosContadorRC) + ',' + 't'+(++t) + ',' + 'stack'+ '#' + ast.hijos[1].linea + '|';	
			c4d += '+' + ',' + ('t' + t) + ',' + (pasoRC) + ',' + ('t'+ (++t)) + '#' + ast.hijos[1].linea + '|';	
			c4d += '<=' + ',' + (tPosContadorRC) + ',' + ('t' + t) + ',' + 'stack' + '#' + ast.hijos[1].linea + '|';	
			//reiniciar ciclo
			c4d += 'jmp,,,' + etIniRC + '#' + ast.linea + '|';
			c4d += etFinRC + ':' + '#' + ast.linea + '|'; //salida del ciclo			
			return { c4d: c4d };

		case 'repetir_mientras':
			let etIniRM = genEt();
			let etFinRM = genEt();

			let resCondRM = cuadruplos(ast.hijos[0]);
			let resSentsRM = cuadruplos(ast.hijos[1], etIniRM, etFinRM, etRet);

			c4d = etIniRM + ':#' + ast.hijos[0].linea + '|';
			c4d += resCondRM.c4d;			
			c4d += etsToC4D(resCondRM.etsV, ast.hijos[0].linea);			
			c4d += resSentsRM.c4d;
			c4d += 'jmp,,,' + etIniRM + '#' + ast.hijos[0].linea + '|';
			c4d += etsToC4D(resCondRM.etsF, ast.hijos[0].linea);	
			c4d += etFinRM + ':#' + ast.hijos[0].linea + '|';
			return { c4d : c4d };
			
		case 'hacer':			//hacer... mientras
			let etIniHacer = genEt();	
			let etFinHacer = genEt();
			
			let resSentsHacer = cuadruplos(ast.hijos[0], etIniHacer, etFinHacer, etRet);
			let resCondHacer = cuadruplos(ast.hijos[1]);

			c4d = etsToC4D(resCondHacer.etsV, ast.hijos[1].linea);			
			c4d += resSentsHacer.c4d;
			c4d += etIniHacer + ':#' + ast.hijos[1].linea + '|';
			c4d += resCondHacer.c4d;
			c4d += etsToC4D(resCondHacer.etsF, ast.hijos[1].linea);	
			c4d += etFinHacer + ':#' + ast.hijos[1].linea + '|';
			return { c4d : c4d };

		case 'ciclo_doble_condicion':
			let etIniCdc = genEt();
			let etFinCdc = genEt();
			let etSentsCdc = genEt();
			
			let resFirstCondCdc1 = cuadruplos(ast.hijos[0]);
			let resFirstCondCdc2 = cuadruplos(ast.hijos[1]);

			let resCondCdc1 = cuadruplos(ast.hijos[0]);
			let resCondCdc2 = cuadruplos(ast.hijos[1]);
			let resSentsCdc = cuadruplos(ast.hijos[2], etIniCdc, etFinCdc, etRet);

			c4d = resFirstCondCdc1.c4d;		
			c4d += etsToC4D(resFirstCondCdc1.etsV, ast.hijos[0].linea);		
			c4d += 'jmp,,,' + etSentsCdc + '#' + ast.hijos[0].linea + '|';	
			c4d += etsToC4D(resFirstCondCdc1.etsF, ast.hijos[0].linea);		
			c4d += resFirstCondCdc2.c4d;		
			c4d += etsToC4D(resFirstCondCdc2.etsV, ast.hijos[0].linea);		
			c4d += 'jmp,,,' + etSentsCdc + '#' + ast.hijos[0].linea + '|';	
			c4d += etsToC4D(resFirstCondCdc2.etsF, ast.hijos[0].linea);	
			c4d += 'jmp,,,' + etFinCdc + '#' + ast.hijos[0].linea + '|';	
			
			c4d += etIniCdc + ':#' + ast.hijos[0].linea + '|';
			c4d += resCondCdc1.c4d;			
			c4d += etsToC4D(resCondCdc1.etsV, ast.hijos[0].linea);			
			c4d += resCondCdc2.c4d;			
			c4d += etsToC4D(resCondCdc2.etsV, ast.hijos[1].linea);
			c4d += etSentsCdc + ':' + '#' + ast.hijos[2].linea + '|';			
			c4d += resSentsCdc.c4d;
			c4d += 'jmp,,,' + etIniCdc + '#' + ast.hijos[0].linea + '|';
			c4d += etsToC4D(resCondCdc1.etsF, ast.hijos[0].linea);	
			c4d += etsToC4D(resCondCdc2.etsF, ast.hijos[1].linea);	
			c4d += etFinCdc + ':#' + ast.hijos[0].linea + '|';
			return { c4d : c4d };			

		case 'repetir': //repetir .... hasta que
			let etIniRep = genEt();	
			let etFinRep = genEt();
			
			let resSentsRep = cuadruplos(ast.hijos[0], etIniRep, etFinRep, etRet);
			let resCondRep = cuadruplos(ast.hijos[1]);

			c4d = etsToC4D(resCondRep.etsF, ast.hijos[1].linea);			
			c4d += resSentsRep.c4d;
			c4d += etIniRep + ':#' + ast.hijos[1].linea + '|';
			c4d += resCondRep.c4d;
			c4d += etsToC4D(resCondRep.etsV, ast.hijos[1].linea);	
			c4d += etFinRep + ':#' + ast.hijos[1].linea + '|';
			return { c4d : c4d };

		case 'retornar':
			//todo setear el valor en el stack			
			return {c4d: 'jmp,,,' + etRet + '#' + ast.linea + '|'};			

		case 'romper':																
			return {c4d: 'jmp,,,' + etFin + '#' + ast.linea + '|'};			
		
		case 'continuar':			
			return {c4d: 'jmp,,,' + etIni + '#' + ast.linea + '|'};													

		case '+':
		case '-':
		case '*':
		case '/':		
			let opArit1 = cuadruplos(ast.hijos[0]);
			let opArit2 = cuadruplos(ast.hijos[1]);
			c4d = opArit1.c4d;
			c4d += opArit2.c4d;
			c4d += ast.tipo + ',' + (opArit1.t) + ',' + (opArit2.t) + ',' + ('t'+ (++t)) + '#' + ast.linea + '|';			
			return {t: 't' + t, c4d: c4d };
		
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
			
			return {etsF: Or2.etsF, etsV: Or1.etsV.concat(Or2.etsV), c4d: c4d };

		case '&&':			
			let And1 = cuadruplos(ast.hijos[0]);
			let And2 = cuadruplos(ast.hijos[1]);

			c4d = And1.c4d;			
			c4d += etsToC4D(And1.etsV, ast.linea);
			c4d += And2.c4d;
			
			return {etsF: And1.etsF.concat(And2.etsF), etsV: And2.etsV, c4d: c4d };


		case '??':						
			let Xor1 = cuadruplos(ast.hijos[0]);
			let Xor2 = cuadruplos(ast.hijos[1]);
			let Xor3 = cuadruplos(ast.hijos[1]);

			c4d = Xor1.c4d;	
			c4d += etsToC4D(Xor1.etsF, ast.linea);								
			c4d += Xor2.c4d;
			c4d += etsToC4D(Xor1.etsV, ast.linea);	
			c4d += Xor3.c4d;
			
			return {etsV: Xor2.etsV.concat(Xor3.etsF), etsF: Xor2.etsF.concat(Xor3.etsV), c4d: c4d };

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
