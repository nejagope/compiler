%options case-insensitive

%x ML_COMMENT
%x STRING
%x CHAR

%%

// ----------------------------------- comentario multilinea -------------------------------------

"/*"                        this.pushState('ML_COMMENT');
<ML_COMMENT>"*/"            this.popState();
<ML_COMMENT>(.|\s)          /* Se ignora */
<ML_COMMENT>\n              /* Se ignora */
<ML_COMMENT><<EOF>>         throw "Final inesperado de archivo (comentario no cerrado)";

// --------------------------------- fin comentario multilinea -----------------------------------

// ----------------------------------- strings -------------------------------------

\"                      { this.pushState('STRING'); limpiarString(); }
<STRING>\"            	{ 
							this.popState(); 
							yytext=getString(); 

							if (yytext == "\\0")
                          		return 'nada';
							
							return 'cadenaLit'; 
						}
/* <STRING>(\n|\r)      { appendString(yytext); yytext=getString(); return 'errorLex'; }	*/
<STRING>(\n|\r)         { appendString(yytext); }
<STRING>[^"\r\n]        { appendString(yytext); }
<STRING><<EOF>>         { appendString(yytext); yytext=getString(); return 'errorLex'; }

// --------------------------------- fin string -----------------------------------


// ----------------------------------- chars -------------------------------------

\'                      { this.pushState('CHAR'); limpiarString(); }
<CHAR>\'                { 
                          this.popState(); 
                          yytext=getString();
                          if (yytext.length == 2 && yytext.startsWith('\\')){
                          	if (yytext == "\\0")
                          		return 'nada';
                          	else if (yytext == "\\n"){
                          		yytext = '\n';
                          		return 'caracterLit'
                          	}
                          	else if (yytext == "\\t"){
                          		yytext = '\t';
                          		return 'caracterLit'
                          	}
                          	return 'errorLex' //secuencia de escape no válida
                          }
                          else if (yytext.length == 1)
                            return 'caracterLit';
                          else
                            return 'errorLex'; 
                        }
<CHAR>(\n|\r)           { appendString(yytext); }
<CHAR>[^'\r\n]          { appendString(yytext); }
<CHAR><<EOF>>           { appendString(yytext); yytext=getString(); return 'errorLex'; }

// --------------------------------- fin string -----------------------------------

"//"(.|<<EOF>>)*                   /* ignorar comentario de línea */


\s+                         /* skip whitespace */
[0-9]+("."[0-9]+)\b         return 'decimalLit'
[0-9]+                      return 'enteroLit'

/*-------------------------------------------- PALABRAS RESERVADAS ----------------------------------*/

"verdadero"               return 'booleanoLit'
"falso"                   return 'booleanoLit'

"booleano"	             	return 'booleano'
"entero"					        return 'entero'
"decimal"					        return 'decimal'
"caracter"					      return 'caracter'
"cadena"					        return 'cadena'
"vacio"                   return 'vacio'

"nada"						        return 'nadaWord'

"romper"					        return 'romper'
"continuar"					      return 'continuar'
"retornar"                return 'retornar'

"estructura"				      return 'estructura'

"si"						          return 'si'
"fin-si"					        return 'fin_si'
"es_verdadero"				    return 'es_verdadero'
"es_falso"					      return 'es_falso'
"repetir_mientras"			  return 'repetir_mientras'
"mientras"					      return 'mientras'
"hacer"						        return 'hacer'
"repetir"					        return 'repetir'
"repetir_contando"			  return 'repetir_contando'
"hasta_que"					      return 'hasta_que'
"ciclo_doble_condicion"		return 'ciclo_doble_condicion'
"desde"						        return 'desde'
"hasta"						        return 'hasta'
"variable"					      return 'variable'
"enciclar"					      return 'enciclar'
"contador"					      return 'contador'

"evaluar_si"				      return 'evaluar_si'
"es_igual_a"				      return 'es_igual_a'
"defecto"					        return 'defecto'

"publico"                 return 'publico'
"privado"                 return 'privado'
"protegido"               return 'protegido'

"@sobrescribir"           return 'sobrescribir'

/*-------------------------------------------- FIN PALABRAS RESERVADAS ------------------------------*/

[a-zA-Z][a-zA-Z0-9]*        return 'id';


"++"                         return 'inc';
"--"                         return 'dec';

"+="                         return 'masI';
"*="                         return 'porI';
"-="                         return 'menosI';
"/="                         return 'entreI';

">="                         return 'mayorI';
"<="                         return 'menorI';
">"                         return 'mayor';
"<"                         return 'menor';
"!="                        return 'diferente';
"=="                        return 'igual';


"||"                        return 'o';
"??"                        return 'xor';
"&&"                        return 'y';
"!"                         return 'no';

"="                         return 'asigna';

"+"                         return 'mas';
"-"                         return 'menos';
"*"                         return 'por';
"/"                         return 'entre';
"^"                         return 'potencia';

"."                         return 'pto';

"{"                         return 'llaveA';
"}"                         return 'llaveC';
"("                         return 'parenA';
")"                         return 'parenC';
"["                         return 'corcheteA';
"]"                         return 'corcheteC';

","                         return 'coma';
";"                         return 'ptoComa';
":"                         return 'dosPtos';

.+\s                        return 'errorLex'
.+<<EOF>>                   return 'errorLex'
<<EOF>>                     return 'eof';


%%

var string = "";
function limpiarString(){
  string="";
}
function appendString(char){
  string = string + char;
}
function getString(){
  return string;
}
