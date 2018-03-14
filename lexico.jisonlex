
%x ML_COMMENT
%x STRING

%%

// ----------------------------------- comentario multilinea -------------------------------------

"/*"                        this.pushState('ML_COMMENT');
<ML_COMMENT>"*/"            this.popState();
<ML_COMMENT>\s+             /* se ignora whitespace */
<ML_COMMENT>.               /* Se ignora */
<ML_COMMENT>\n              /* Se ignora */
<ML_COMMENT><<EOF>>         throw "Final inesperado de archivo (comentario no cerrado)";

// --------------------------------- fin comentario multilinea -----------------------------------

// ----------------------------------- strings -------------------------------------
var string = "";
\"                      { this.pushState('STRING'); string = ""; }
<STRING>.*\"            { this.popState(); return 'cadenaLit'; }
<STRING>\n              { this.popState(); return 'errorLex'; }
<STRING><<EOF>>         throw "Final inesperado de cadena";

// --------------------------------- fin string -----------------------------------


"//"(.|<<EOF>>)*                   /* ignorar comentario de línea */


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


