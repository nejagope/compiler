
%x ML_COMMENT
%x STRING

%%

// ----------------------------------- comentario multilinea -------------------------------------

"/*"                        this.pushState('ML_COMMENT');
<ML_COMMENT>"*/"            this.popState();
<ML_COMMENT>(.|\s)               /* Se ignora */
<ML_COMMENT>\n              /* Se ignora */
<ML_COMMENT><<EOF>>         throw "Final inesperado de archivo (comentario no cerrado)";

// --------------------------------- fin comentario multilinea -----------------------------------

// ----------------------------------- strings -------------------------------------
\"                      { this.pushState('STRING'); return 'comilla'; }
<STRING>\"            	{ this.popState(); return 'comilla'; }
<STRING>(\n|\r)         throw "Cadena no cerrada antes del fin de línea";	
<STRING>[^"\r\n]*		return 'cadenaLit';
<STRING><<EOF>>         throw "Final inesperado de cadena";

// --------------------------------- fin string -----------------------------------


"//".*|<<EOF>>                   /* ignorar comentario de línea */


\s+                         /* skip whitespace */
[0-9]+("."[0-9]+)?\b      	return 'num'
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
"."                         throw 'Illegal character';
<<EOF>>                     return 'eof';


