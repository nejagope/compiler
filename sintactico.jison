%{
    function addChildren(node, child){
      node.splice(2,1,child); 
      return node;
    }
%}

%nonassoc igual mayor menor mayorI menorI diferente
%nonassoc asigna masI menosI porI entreI

%left o xor
%left y
%left no

%left mas menos
%left por entre
%left potencia
%left inc dec

%left pto

%start PROG

%%
PROG : SENTS {{ return $1 }}
;

SENTS 
    : SENTS SENT  {{ var arr = $1; $$ = arr.concat($2); }}
    | SENTS eof   {{ $$ = $1 }}
    | SENT        {{ $$ =  [$1] }}     
;

SENT 
    : ASIGNA {{ $$ = $1 }}
    
;

ASIGNA 
    : ASIGNABLE SIGNO_ASIG E ptoComa {{ $$ = { tipo:$2, hijos:[$1, $3],  linea:  @1.first_line, columna:  @1.first_column, lineaF:  @4.last_line, columnaF:  @4.last_column } }}    
 ;

SIGNO_ASIG 
    : asigna {{ $$ = yytext }}
    | masI {{ $$ = yytext }}
;

ASIGNABLE :
      id {{ $$ = $1 }}
;

E 
    : E mas E       {{ $$ = { tipo:'+', hijos:[$1, $3],  linea:  @1.first_line, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E menos E     {{ $$ = { tipo:'-', hijos:[$1, $3],  linea:  @1.first_line, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E por E       {{ $$ = { tipo:'*', hijos:[$1, $3],  linea:  @1.first_line, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E entre E     {{ $$ = { tipo:'/', hijos:[$1, $3],  linea:  @1.first_line, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E potencia E  {{ $$ = { tipo:'^', hijos:[$1, $3],  linea:  @1.first_line, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}

    | E igual E     {{ $$ = { tipo:'==',  hijos:[$1, $3], linea: @1.first_line, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E diferente E {{ $$ = { tipo:'!=',  hijos:[$1, $3], linea: @1.first_line, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E mayor E     {{ $$ = { tipo:'>',   hijos:[$1, $3], linea: @1.first_line, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E menor E     {{ $$ = { tipo:'<',   hijos:[$1, $3], linea: @1.first_line, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E mayorI E    {{ $$ = { tipo:'>=',  hijos:[$1, $3], linea: @1.first_line, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}    
    | E menorI E    {{ $$ = { tipo:'<=',  hijos:[$1, $3], linea: @1.first_line, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}    

    | E o E     {{ $$ = { tipo:'||',    hijos:[$1, $3], linea: @1.first_line, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E xor E   {{ $$ = { tipo:'??',    hijos:[$1, $3], linea: @1.first_line, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E y E     {{ $$ = { tipo:'&&',    hijos:[$1, $3], linea: @1.first_line, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | no E      {{ $$ = { tipo:'!',     hijos:[$2],     linea: @1.first_line, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}

    | E inc   {{ $$ = { tipo:'++',      hijos:[$1],  linea: @1.first_line, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}
    | E dec   {{ $$ = { tipo:'--',      hijos:[$1],  linea: @1.first_line, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}

    | E pto E    {{ $$ = { tipo:'.',    hijos:[$1, $3],  linea: @1.first_line, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}    
    | parenA E parenC   {{ $$ = $2 }}    
    
    | booleanoLit   {{ $$ = { tipo:'booleanoLit', val: yytext.toLowerCase() == 'verdadero', linea:  @1.first_line, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column  } }}
    | enteroLit     {{ $$ = { tipo:'enteroLit'  , val: parseInt(yytext)     , linea:  @1.first_line, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column  } }}
    | decimalLit    {{ $$ = { tipo:'decimalLit' , val: parseFloat(yytext)   , linea:  @1.first_line, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column  } }}
    | cadenaLit     {{ $$ = { tipo:'cadenaLit'  , val: yytext               , linea:  @1.first_line, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column  } }}    
    | caracterLit   {{ $$ = { tipo:'caracterLit', val: yytext.charCodeAt(0) , linea:  @1.first_line, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column  } }}    
    | id            {{ $$ = { tipo:'id'         , val: yytext               , linea:  @1.first_line, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column } }}
    | errorLex      {{ $$ = { tipo:'errorLex'   , val: yytext               , linea:  @1.first_line, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column  } }}       
; 
