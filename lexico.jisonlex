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
<STRING>\"            	{ this.popState(); yytext=getString(); return 'cadenaLit'; }
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
                          if (yytext.length == 1)
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

"verdadero"                 return 'booleanoLit'
"falso"                     return 'booleanoLit'

/*-------------------------------------------- FIN PALABRAS RESERVADAS ------------------------------*/

[a-zA-Z][a-zA-Z0-9]*        return 'id';

"=="                        return 'igual';
"="                         return 'asigna';
"+"                         return 'mas';
"-"                         return 'menos';
"*"                         return 'por';
">"                         return 'mayor';
"||"                        return 'o';
"!"                         return 'no';
"."                         return 'pto';
"{"                         return 'llaveA';
"}"                         return 'llaveC';
"("                         return 'parenA';
")"                         return 'parenC';
";"                         return 'ptoComa';

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
