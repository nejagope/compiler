%{
    var nid = 0;
    function addChildren(node, child){
      node.splice(2,1,child); 
      return node;
    }
%}
%locations

%nonassoc igual mayor menor mayorI menorI diferente
%nonassoc asigna masI menosI porI entreI

%left o xor
%left y
%left no

%left mas menos
%left por entre
%left potencia
%left inc dec
%left UMINUS

%left pto

%start PROG

%%
PROG : SENTS  {{ return $1 }}
  | SENTS eof {{ return $1 }}
;

SENTS 
    : SENTS SENT  {{ var arr = $1; $$ = arr.concat($2); }}    
    | SENT        {{ $$ =  [$1] }}     
;

SENT 
    : ASIGNACION ptoComa {{ $$ = $1 }}
    | CLASE {{ $$ = $1 }}
    | DECLARACION ptoComa {{ $$ = $1 }}
    | ESTRUCTURA ptoComa {{ $$ = $1 }}
    | EVALUAR_SI {{ $$ = $1 }}
    | SI {{ $$ = $1 }}
    | REPETIR_MIENTRAS {{ $$ = $1 }}
    | HACER ptoComa {{ $$ = $1 }}
    | CICLO_DOBLE_CONDICION {{ $$ = $1 }}
    | REPETIR ptoComa {{ $$ = $1 }}
    | REPETIR_CONTANDO {{ $$ = $1 }}
    | ENCICLAR {{ $$ = $1 }}
    | CONTADOR {{ $$ = $1 }}    
    | FUNCION  {{ $$ = $1 }} 
    | LLAMADA ptoComa {{ $$ = $1 }}
    | CREAR_PUNTERO ptoComa {{ $$ = $1 }}       
    | E pto LLAMADA ptoComa  {{ $$ = { nid: nid++, tipo:'.',    hijos:[$1, $3],  linea: yylineno, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}         
    | retornar E ptoComa {{ $$ = { nid: nid++, tipo:'retornar', hijos:[$2], linea:  yylineno, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column  } }}       
    | romper ptoComa {{ $$ = { nid: nid++, tipo:'romper', val: yytext, linea:  yylineno, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column  } }}       
    | continuar ptoComa {{ $$ = { nid: nid++, tipo:'continuar', val: yytext, linea:  yylineno, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column  } }}       
    | E inc ptoComa        {{ $$ = { nid: nid++, tipo:'++',    hijos:[$1],  linea: yylineno, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}
    | E dec ptoComa        {{ $$ = { nid: nid++, tipo:'--',    hijos:[$1],  linea: yylineno, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}            
    | error ptoComa {{ $$ = { nid: nid++, tipo:'errorSint', val: yytext, linea: yylineno, columna:  @1.first_column} }}    
    | error eof     {{ $$ = { nid: nid++, tipo:'errorSint', val: yytext, linea: yylineno, columna:  @1.first_column} }}    
;

CREAR_PUNTERO
  : crearPuntero parenA TIPO coma ID parenC
      {{ $$ = { nid: nid++, tipo:'puntero', hijos: [$3, $5], linea: yylineno, columna:  @1.first_column} }}    
  | crearPuntero parenA ID coma ID parenC
      {{ $$ = { nid: nid++, tipo:'puntero', hijos: [$3, $5], linea: yylineno, columna:  @1.first_column} }}    
;

CLASE 
  : clase ID hereda_de ID llaveA SENTS llaveC
    {{ $$ = { nid: nid++, tipo:'clase', hijos: [$2, $4, $6], linea: yylineno, columna:  @1.first_column} }}    
  | clase ID llaveA SENTS llaveC
    {{ $$ = { nid: nid++, tipo:'clase', hijos: [$2, $4], linea: yylineno, columna:  @1.first_column} }}    
;


VISIBILIDAD
  : publico   {{ $$ = yytext.toLowerCase() }}
  | protegido {{ $$ = yytext.toLowerCase() }}
  | privado   {{ $$ = yytext.toLowerCase() }}  
;

FUNCION
  : VISIBILIDAD FUNC   {{ objFun = $2; objFun.visibilidad = $1; $$ = objFun; }}
  | FUNC               {{ $$ = $1 }}  
;

FUNC 
  : TIPO ID parenA PARAMS parenC llaveA SENTS llaveC  
      {{ $$ = { nid: nid++, tipo:'funcion', hijos: [$1, $2, $4, $7],  linea: yylineno, columna:  @1.first_column, lineaF:  @8.last_line, columnaF:  @8.last_column } }}        
  | ID  ID parenA PARAMS parenC llaveA SENTS llaveC 
      {{ $$ = { nid: nid++, tipo:'funcion', hijos: [$1, $2, $4, $7],  linea: yylineno, columna:  @1.first_column, lineaF:  @8.last_line, columnaF:  @8.last_column } }}        
  | vacio ID parenA PARAMS parenC llaveA SENTS llaveC  
      {{ $$ = { nid: nid++, tipo:'funcion', hijos: [$1, $2, $4, $7],  linea: yylineno, columna:  @1.first_column, lineaF:  @8.last_line, columnaF:  @8.last_column } }}          
  | ID parenA PARAMS parenC llaveA SENTS llaveC  
      {{ $$ = { nid: nid++, tipo:'funcion', hijos: [$1, $3, $6],  linea: yylineno, columna:  @1.first_column, lineaF:  @7.last_line, columnaF:  @7.last_column } }}        

  | TIPO ID parenA parenC llaveA SENTS llaveC  
      {{ $$ = { nid: nid++, tipo:'funcion', hijos: [$1, $2, $6],  linea: yylineno, columna:  @1.first_column, lineaF:  @7.last_line, columnaF:  @7.last_column } }}        
  | ID ID parenA parenC llaveA SENTS llaveC 
      {{ $$ = { nid: nid++, tipo:'funcion', hijos: [$1, $2, $6],  linea: yylineno, columna:  @1.first_column, lineaF:  @7.last_line, columnaF:  @7.last_column } }}        
  | vacio ID parenA parenC llaveA SENTS llaveC  
      {{ $$ = { nid: nid++, tipo:'funcion', hijos: [$1, $2, $6],  linea: yylineno, columna:  @1.first_column, lineaF:  @7.last_line, columnaF:  @7.last_column } }}          
  | ID parenA parenC llaveA SENTS llaveC  
      {{ $$ = { nid: nid++, tipo:'funcion', hijos: [$1, $5],  linea: yylineno, columna:  @1.first_column, lineaF:  @6.last_line, columnaF:  @6.last_column } }}        
;

PARAMS 
    : PARAMS coma PARAM {{ var arr = $1; $$ = arr.concat($3); }}
    | PARAM             {{ $$ =  [$1] }}    
;

PARAM
  : TIPO ID {{ $$ = { nid: nid++, tipo:'param', hijos: [$1, $2],  linea:  yylineno, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}
  | ID ID   {{ $$ = { nid: nid++, tipo:'param', hijos: [$1, $2],  linea:  yylineno, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}  
;


LLAMADA
  : ID parenA EXPS parenC
      {{ $$ = { nid: nid++, tipo:'llamada', hijos: [$1, $2],  linea: yylineno, columna:  @1.first_column, lineaF:  @4.last_line, columnaF:  @4.last_column } }}        
  | ID parenA parenC 
    {{ $$ = { nid: nid++, tipo:'llamada', hijos: [$1],  linea: yylineno, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}        
;


REPETIR_MIENTRAS
    : repetir_mientras parenA E parenC llaveA SENTS llaveC
        {{ $$ = { nid: nid++, tipo:'repetir_mientras', hijos: [$3, $6],  linea:  yylineno, columna:  @1.first_column, lineaF:  @7.last_line, columnaF:  @7.last_column } }}        
;

HACER
    : hacer llaveA SENTS llaveC mientras parenA E parenC
        {{ $$ = { nid: nid++, tipo:'hacer', hijos: [$3, $7],  linea:  yylineno, columna:  @1.first_column, lineaF:  @8.last_line, columnaF:  @8.last_column }; }}        
;

CICLO_DOBLE_CONDICION
    : ciclo_doble_condicion parenA E coma E parenC llaveA SENTS llaveC
        {{ $$ = { nid: nid++, tipo:'ciclo_doble_condicion', hijos: [$3, $5, $8],  linea:  yylineno, columna:  @1.first_column, lineaF:  @7.last_line, columnaF:  @7.last_column } }}        
;

REPETIR
    : repetir llaveA SENTS llaveC hasta_que parenA E parenC
        {{ $$ = { nid: nid++, tipo:'repetir', hijos: [$3, $7],  linea:  yylineno, columna:  @1.first_column, lineaF:  @8.last_line, columnaF:  @8.last_column }; }}        
;

REPETIR_CONTANDO
    : repetir_contando parenA variable dosPtos ID ptoComa desde dosPtos E ptoComa hasta dosPtos E parenC llaveA SENTS llaveC
        {{ $$ = { nid: nid++, tipo:'repetir_contando', hijos: [$5, $9, $13, $16],  linea:  yylineno, columna:  @1.first_column, lineaF:  @7.last_line, columnaF:  @7.last_column } }}        
    | repetir_contando parenA variable dosPtos ID ptoComa desde dosPtos E ptoComa hasta dosPtos E parenC SENTS llaveC
        {{ $$ = { nid: nid++, tipo:'repetir_contando', hijos: [$5, $9, $13, $15],  linea:  yylineno, columna:  @1.first_column, lineaF:  @7.last_line, columnaF:  @7.last_column } }}        
;

ENCICLAR
    : enciclar ID llaveA SENTS llaveC
        {{ $$ = { nid: nid++, tipo:'enciclar', hijos: [$2, $4],  linea:  yylineno, columna:  @1.first_column, lineaF:  @5.last_line, columnaF:  @5.last_column } }}        
;

CONTADOR
    : contador parenA E parenC llaveA SENTS llaveC
        {{ $$ = { nid: nid++, tipo:'contador', hijos: [$3, $6],  linea:  yylineno, columna:  @1.first_column, lineaF:  @7.last_line, columnaF:  @7.last_column } }}        
;

SI 
    : si parenA E parenC OPCION_SI fin_si
        {{ $$ = { nid: nid++, tipo:'si', hijos: [$3, $5],  linea:  yylineno, columna:  @1.first_column, lineaF:  @6.last_line, columnaF:  @6.last_column } }}        
    | si parenA E parenC OPCION_SI OPCION_SI fin_si
        {{ $$ = { nid: nid++, tipo:'si', hijos: [$3, $5, $6],  linea:  yylineno, columna:  @1.first_column, lineaF:  @7.last_line, columnaF:  @7.last_column } }}        
;

OPCION_SI 
    : VALOR_SI llaveA SENTS llaveC
        {{ $$ = { nid: nid++, tipo:$1, hijos: [$3],  linea:  yylineno, columna:  @1.first_column, lineaF:  @4.last_line, columnaF:  @4.last_column } }}        
;

VALOR_SI
    : es_verdadero  {{ $$ = yytext.toLowerCase() }}
    | es_falso      {{ $$ = yytext.toLowerCase() }}
;

EVALUAR_SI 
    : evaluar_si parenA E parenC llaveA CASOS llaveC
        {{ $$ = { nid: nid++, tipo:'evaluar_si', hijos: [$3, $6],  linea:  yylineno, columna:  @1.first_column, lineaF:  @7.last_line, columnaF:  @7.last_column } }}        
;

CASOS
    : CASOS CASO   {{ var arr = $1; $$ = arr.concat($2); }}
    | CASO         {{ $$ =  [$1] }}   
;


CASO 
    : es_igual_a E dosPtos SENTS    {{ $$ = { nid: nid++, tipo:'caso', hijos: [$2, $4],  linea:  yylineno, columna:  @1.first_column, lineaF:  @4.last_line, columnaF:  @4.last_column } }}        
    | defecto dosPtos SENTS         {{ $$ = { nid: nid++, tipo:'defecto', hijos: [$3],   linea:  yylineno, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}        
;

ESTRUCTURA
    : estructura ID corcheteA DECLARACIONES corcheteC
        {{ $$ = { nid: nid++, tipo:'estructura', hijos: [$2, $4],  linea:  yylineno, columna:  @1.first_column, lineaF:  @5.last_line, columnaF:  @5.last_column } }}        
;

DECLARACIONES
    : DECLARACIONES DECLARACION ptoComa   {{ var arr = $1; $$ = arr.concat($2); }}
    | DECLARACION ptoComa                 {{ $$ =  [$1] }}   
;

DECLARACION
  : DECLARA  {{ $$ = $1 }}
  | VISIBILIDAD DECLARA {{ objDec = $2; objDec.visibilidad = $1; $$ = objDec; }}
;

DECLARA 
    : TIPO ID            {{ $$ = { nid: nid++, tipo:'decl', hijos:[$1, $2],     linea:  yylineno, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}        
    | ID ID            {{ $$ = { nid: nid++, tipo:'decl', hijos:[$1, $2],     linea:  yylineno, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}        
    | ID ID asigna E           {{ $$ = { nid: nid++, tipo:'decl', hijos:[$1, $2, $4],     linea:  yylineno, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}        
    | TIPO ID asigna E           {{ $$ = { nid: nid++, tipo:'decl', hijos:[$1, $2, $4],     linea:  yylineno, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}        
;

TIPO 
    : TIPO_NATIVO {{ $$ = { nid: nid++, tipo:'tipo', val: $1, linea:  yylineno, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column  } }}    
;

TIPO_NATIVO
    : entero    {{ $$ = yytext.toLowerCase() }}
    | decimal   {{ $$ = yytext.toLowerCase() }}
    | booleano  {{ $$ = yytext.toLowerCase() }}
    | caracter  {{ $$ = yytext.toLowerCase() }}
    | cadena    {{ $$ = yytext.toLowerCase() }}
;

ASIGNACION
    : E SIGNO_ASIG E {{ $$ = { nid: nid++, tipo:$2, hijos:[$1, $3],  linea:  yylineno, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}    
 ;

SIGNO_ASIG 
    : asigna    {{ $$ = yytext }}
    | masI      {{ $$ = yytext }}
    | menosI    {{ $$ = yytext }}
    | porI      {{ $$ = yytext }}
    | entreI    {{ $$ = yytext }}
;

POSICIONES
    : POSICIONES POSICION   {{ var arr = $1; $$ = arr.concat($2); }}
    | POSICION              {{ $$ =  [$1] }}   
;

POSICION 
    :  corcheteA E corcheteC {{ $$ = $2 }} 
;

ARRAY 
    : llaveA EXPS llaveC {{ $$ = { nid: nid++, tipo:'array', val:[$2],  linea: yylineno, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
;

EXPS 
    : EXPS coma E   {{ var arr = $1; $$ = arr.concat($3); }}
    | E             {{ $$ =  [$1] }}  
;

E 
    : E mas E       {{ $$ = { nid: nid++, tipo:'+', hijos:[$1, $3],  linea:  yylineno, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E menos E     {{ $$ = { nid: nid++, tipo:'-', hijos:[$1, $3],  linea:  yylineno, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E por E       {{ $$ = { nid: nid++, tipo:'*', hijos:[$1, $3],  linea:  yylineno, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E entre E     {{ $$ = { nid: nid++, tipo:'/', hijos:[$1, $3],  linea:  yylineno, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E potencia E  {{ $$ = { nid: nid++, tipo:'^', hijos:[$1, $3],  linea:  yylineno, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}

    | E igual E     {{ $$ = { nid: nid++, tipo:'==',  hijos:[$1, $3], linea: yylineno, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E diferente E {{ $$ = { nid: nid++, tipo:'!=',  hijos:[$1, $3], linea: yylineno, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E mayor E     {{ $$ = { nid: nid++, tipo:'>',   hijos:[$1, $3], linea: yylineno, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E menor E     {{ $$ = { nid: nid++, tipo:'<',   hijos:[$1, $3], linea: yylineno, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E mayorI E    {{ $$ = { nid: nid++, tipo:'>=',  hijos:[$1, $3], linea: yylineno, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}    
    | E menorI E    {{ $$ = { nid: nid++, tipo:'<=',  hijos:[$1, $3], linea: yylineno, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}    

    | E o E     {{ $$ = { nid: nid++, tipo:'||',    hijos:[$1, $3], linea: yylineno, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E xor E   {{ $$ = { nid: nid++, tipo:'??',    hijos:[$1, $3], linea: yylineno, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E y E     {{ $$ = { nid: nid++, tipo:'&&',    hijos:[$1, $3], linea: yylineno, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | no E      {{ $$ = { nid: nid++, tipo:'!',     hijos:[$2],     linea: yylineno, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}
    | nuevo LLAMADA   {{ $$ = { nid: nid++, tipo:'nuevo',     hijos:[$2],     linea: yylineno, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}

    | menos E %prec UMINUS
                {{ $$ = { nid: nid++, tipo:'-',     hijos:[$2],     linea: yylineno, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}

    | E inc         {{ $$ = { nid: nid++, tipo:'++',    hijos:[$1],  linea: yylineno, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}
    | E dec         {{ $$ = { nid: nid++, tipo:'--',    hijos:[$1],  linea: yylineno, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}    

    | E pto ID    {{ $$ = { nid: nid++, tipo:'.',    hijos:[$1, $3],  linea: yylineno, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}    
    | E pto LLAMADA    {{ $$ = { nid: nid++, tipo:'.',    hijos:[$1, $3],  linea: yylineno, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}    
    | parenA E parenC   {{ $$ = $2 }}    
    | ID POSICIONES {{ $$ = { nid: nid++, tipo:'[]',    hijos:[$1, $2],  linea: yylineno, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}    
    
    | booleanoLit   {{ $$ = { nid: nid++, tipo:'booleanoLit', val: yytext.toLowerCase() == 'verdadero', linea:  yylineno, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column  } }}
    | enteroLit     {{ $$ = { nid: nid++, tipo:'enteroLit'  , val: parseInt(yytext)     , linea:  yylineno, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column  } }}
    | decimalLit    {{ $$ = { nid: nid++, tipo:'decimalLit' , val: parseFloat(yytext)   , linea:  yylineno, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column  } }}
    | cadenaLit     {{ $$ = { nid: nid++, tipo:'cadenaLit'  , val: yytext               , linea:  yylineno, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column  } }}    
    | caracterLit   {{ $$ = { nid: nid++, tipo:'caracterLit', val: yytext.charCodeAt(0) , linea:  yylineno, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column  } }}    
    | nadaWord      {{ $$ = { nid: nid++, tipo:'nada',        val: null                 , linea:  yylineno, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column  } }}    
    | llaveA nada llaveC    
                    {{ $$ = { nid: nid++, tipo:'nada',        val: null                 , linea:  yylineno, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column  } }}    
    | ID            {{ $$ = $1 }}
    | ARRAY         {{ $$ = $1 }}
    | LLAMADA       {{ $$ = $1 }}
    | CREAR_PUNTERO {{ $$ = $1 }}
    | errorLex      {{ $$ = { nid: nid++, tipo:'errorLex'   , val: yytext               , linea:  yylineno, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column  } }}       
; 

ID 
    : id {{ $$ = { nid: nid++, tipo:'id', val: yytext.toLowerCase(), linea:  yylineno, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column } }} 
;