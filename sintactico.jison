%{
    function addChildren(node, child){
      node.splice(2,1,child); 
      return node;
    }
%}

%token num, id, cadenaLit
%token asigna, mas, menos, por, mayor, o, pto
%token llaveA, llaveC, parenA, parenC, ptoComa
%token eof

%right asigna
%left o
%nonassoc igual mayor
%left mas menos
%left por
%right no
%left pto

%start PROG

%%
PROG : EXPS {{ return $1 }}
;

EXPS
    : EXPS E    {{ var arr = $1; $$ = arr.concat($2); }}     
    | EXPS eof  {{ $$ = $1 }}
    | E         {{ $$ =  [$1] }}     
;

E 
    : E mas E   {{ $$ = { tipo:'mas', hijos:[$1, $3] } }}
    | E menos E {{ $$ = { tipo:'menos', hijos:[$1, $3] } }}
    | E por E   {{ $$ = { tipo:'por', hijos:[$1, $3] } }}
    | num       {{ $$ = { tipo:'num', val: Number(yytext) } }}
    | cadenaLit {{ $$ = { tipo:'cadenaLit', val: yytext } }}
    | id        {{ $$ = { tipo:'id', val: yytext, linea:  @1.first_line, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column } }}
; 
