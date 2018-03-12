%option caseless

\s+                   /* skip whitespace */
[0-9]+("."[0-9]+)?\b  	return 'num'
id                          [a-zA-Z][a-zA-Z0-9]*

%%
"//".*                      /* ignore comment */
{id}                        return 'id';
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


