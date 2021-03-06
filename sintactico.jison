%{
    var nid = 0;
    function addChildren(node, child){
      node.splice(2,1,child); 
      return node;
    }
%}
%locations

%nonassoc asigna masI menosI porI entreI

%left o xor
%left y
%left no

%left igual mayor menor mayorI menorI diferente

%left mas menos
%left por entre
%left potencia
%left inc dec
%left UMINUS

%left pto

%start PROG

%%
PROG : SENTS  {{ return {tipo: 'prog', hijos:[$1] } }}
  | SENTS eof {{ return {tipo: 'prog', hijos:[$1] } }}
;

SENTS 
    : SENTS SENT  {{ var arr = $1.hijos; var arr2 = arr.concat($2); $1.hijos = arr2; $$ = $1;  }}    
    | SENT        {{  $$ = { tipo: 'sents', hijos: [$1] } }}
;     

SENT     
    //bloques
    : CLASE {{ $$ = $1 }}    
    | FUNCION  {{ $$ = $1 }} 
    | EVALUAR_SI {{ $$ = $1 }}
    | SI {{ $$ = $1 }}
    | REPETIR_MIENTRAS {{ $$ = $1 }}    
    | CICLO_DOBLE_CONDICION {{ $$ = $1 }}    
    | REPETIR_CONTANDO {{ $$ = $1 }}
    | ENCICLAR {{ $$ = $1 }}
    | CONTADOR {{ $$ = $1 }}    
    
    //sentencias-bloque terminadas en ptoComa
    | HACER ptoComa {{ $$ = $1 }}
    | REPETIR ptoComa {{ $$ = $1 }}

    //sentencias "sencillas" terminadas en ptoComa
    | DECLARACION ptoComa {{ $$ = $1 }}
    | ASIGNACION ptoComa {{ $$ = $1 }}    
    | CREAR_PUNTERO ptoComa {{ $$ = $1 }}       
    | ESTRUCTURA ptoComa {{ $$ = $1 }}
    | LLAMADA ptoComa {{ $$ = $1 }}    
    | E pto LLAMADA ptoComa  {{ $$ = { tipo:'.',    hijos:[$1, $3],  linea: yylineno+1, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}         
    | retornar E ptoComa {{ $$ = { tipo:'retornar', hijos:[$2], linea:  yylineno+1, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column  } }}       
    | romper ptoComa {{ $$ = { tipo:'romper', val: yytext, linea:  yylineno+1, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column  } }}       
    | continuar ptoComa {{ $$ = { tipo:'continuar', val: yytext, linea:  yylineno+1, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column  } }}       
    | E inc ptoComa        {{ $$ = { tipo:'++',    hijos:[$1],  linea: yylineno+1, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}
    | E dec ptoComa        {{ $$ = { tipo:'--',    hijos:[$1],  linea: yylineno+1, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}            
    | error ptoComa {{ $$ = { tipo:'errorSint', val: yytext, linea: yylineno+1, columna:  @1.first_column} }}    
    | error eof     {{ $$ = { tipo:'errorSint', val: yytext, linea: yylineno+1, columna:  @1.first_column} }}    
;

CREAR_PUNTERO
  : crearPuntero parenA TIPO coma ID parenC
      {{ $$ = { tipo:'puntero', hijos: [$3, $5], linea: yylineno+1, columna:  @1.first_column} }}    
  | crearPuntero parenA ID coma ID parenC
      {{ $$ = { tipo:'puntero', hijos: [$3, $5], linea: yylineno+1, columna:  @1.first_column} }}    
;

CLASE 
  : clase ID hereda_de ID llaveA SENTS llaveC
    {{ $$ = { tipo:'clase', hijos: [$2, $4, $6], linea: yylineno+1, columna:  @1.first_column} }}    
  | clase ID llaveA SENTS llaveC
    {{ $$ = { tipo:'clase', hijos: [$2, $4], linea: yylineno+1, columna:  @1.first_column} }}    
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
      {{ $$ = { tipo:'funcion', hijos: [$1, $2, $4, $7], tipoDato:$1.val,  linea: yylineno+1, columna:  @1.first_column, lineaF:  @8.last_line, columnaF:  @8.last_column } }}        
  | ID  ID parenA PARAMS parenC llaveA SENTS llaveC 
      {{ $$ = { tipo:'funcion', hijos: [$1, $2, $4, $7], tipoDato:$1.val,  linea: yylineno+1, columna:  @1.first_column, lineaF:  @8.last_line, columnaF:  @8.last_column } }}        
  | vacio ID parenA PARAMS parenC llaveA SENTS llaveC  
      {{ $$ = { tipo:'funcion', hijos: [$1, $2, $4, $7], tipoDato:$1,  linea: yylineno+1, columna:  @1.first_column, lineaF:  @8.last_line, columnaF:  @8.last_column } }}          
  | ID parenA PARAMS parenC llaveA SENTS llaveC  
      {{ $$ = { tipo:'funcion', hijos: [null,$1, $3, $6],  linea: yylineno+1, columna:  @1.first_column, lineaF:  @7.last_line, columnaF:  @7.last_column } }}        

  | TIPO ID parenA parenC llaveA SENTS llaveC  
      {{ $$ = { tipo:'funcion', hijos: [$1, $2, $6], tipoDato:$1.val,  linea: yylineno+1, columna:  @1.first_column, lineaF:  @7.last_line, columnaF:  @7.last_column } }}        
  | ID ID parenA parenC llaveA SENTS llaveC 
      {{ $$ = { tipo:'funcion', hijos: [$1, $2, $6], tipoDato:$1.val,  linea: yylineno+1, columna:  @1.first_column, lineaF:  @7.last_line, columnaF:  @7.last_column } }}        
  | vacio ID parenA parenC llaveA SENTS llaveC  
      {{ $$ = { tipo:'funcion', hijos: [$1, $2, $6], tipoDato:$1,  linea: yylineno+1, columna:  @1.first_column, lineaF:  @7.last_line, columnaF:  @7.last_column } }}          
  | ID parenA parenC llaveA SENTS llaveC  
      {{ $$ = { tipo:'funcion', hijos: [null, $1, $5],  linea: yylineno+1, columna:  @1.first_column, lineaF:  @6.last_line, columnaF:  @6.last_column } }}        
;

PARAMS 
    : PARAMS coma PARAM {{ var arr = $1.hijos; $1.hijos = arr.concat($3);  $$ = $1;  }}    
    | PARAM             {{  $$ = { tipo: 'params', hijos: [$1] } }}
;


PARAM
  : TIPO ID {{ $$ = { tipo:'param', hijos: [$1, $2],  linea:  yylineno+1, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}
  | ID ID   {{ $$ = { tipo:'param', hijos: [$1, $2],  linea:  yylineno+1, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}  
;


LLAMADA
  : ID parenA EXPS parenC
      {{ $$ = { tipo:'llamada', hijos: [$1, $3],  linea: yylineno+1, columna:  @1.first_column, lineaF:  @4.last_line, columnaF:  @4.last_column } }}        
  | ID parenA parenC 
    {{ $$ = { tipo:'llamada', hijos: [$1],  linea: yylineno+1, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}        
;


REPETIR_MIENTRAS
    : repetir_mientras parenA E parenC llaveA SENTS llaveC
        {{ $$ = { tipo:'repetir_mientras', hijos: [$3, $6],  linea:  yylineno+1, columna:  @1.first_column, lineaF:  @7.last_line, columnaF:  @7.last_column } }}        
;

HACER
    : hacer llaveA SENTS llaveC mientras parenA E parenC
        {{ $$ = { tipo:'hacer', hijos: [$3, $7],  linea:  yylineno+1, columna:  @1.first_column, lineaF:  @8.last_line, columnaF:  @8.last_column }; }}        
;

CICLO_DOBLE_CONDICION
    : ciclo_doble_condicion parenA E coma E parenC llaveA SENTS llaveC
        {{ $$ = { tipo:'ciclo_doble_condicion', hijos: [$3, $5, $8],  linea:  yylineno+1, columna:  @1.first_column, lineaF:  @7.last_line, columnaF:  @7.last_column } }}        
;

REPETIR
    : repetir llaveA SENTS llaveC hasta_que parenA E parenC
        {{ $$ = { tipo:'repetir', hijos: [$3, $7],  linea:  yylineno+1, columna:  @1.first_column, lineaF:  @8.last_line, columnaF:  @8.last_column }; }}        
;

REPETIR_CONTANDO
    : repetir_contando parenA variable dosPtos ID ptoComa desde dosPtos E ptoComa hasta dosPtos E parenC llaveA SENTS llaveC
        {{ $$ = { tipo:'repetir_contando', hijos: [$5, $9, $13, $16],  linea:  yylineno+1, columna:  @1.first_column, lineaF:  @7.last_line, columnaF:  @7.last_column } }}        
    | repetir_contando parenA variable dosPtos ID ptoComa desde dosPtos E ptoComa hasta dosPtos E parenC SENTS llaveC
        {{ $$ = { tipo:'repetir_contando', hijos: [$5, $9, $13, $15],  linea:  yylineno+1, columna:  @1.first_column, lineaF:  @7.last_line, columnaF:  @7.last_column } }}        
;

ENCICLAR
    : enciclar ID llaveA SENTS llaveC
        {{ $$ = { tipo:'enciclar', hijos: [$2, $4],  linea:  yylineno+1, columna:  @1.first_column, lineaF:  @5.last_line, columnaF:  @5.last_column } }}        
;

CONTADOR
    : contador parenA E parenC llaveA SENTS llaveC
        {{ $$ = { tipo:'contador', hijos: [$3, $6],  linea:  yylineno+1, columna:  @1.first_column, lineaF:  @7.last_line, columnaF:  @7.last_column } }}        
;

SI 
    : si parenA E parenC OPCION_SI fin_si
        {{ $$ = { tipo:'si', hijos: [$3, $5],  linea:  yylineno+1, columna:  @1.first_column, lineaF:  @6.last_line, columnaF:  @6.last_column } }}        
    | si parenA E parenC OPCION_SI OPCION_SI fin_si
        {{ $$ = { tipo:'si', hijos: [$3, $5, $6],  linea:  yylineno+1, columna:  @1.first_column, lineaF:  @7.last_line, columnaF:  @7.last_column } }}        
;

OPCION_SI 
    : VALOR_SI llaveA SENTS llaveC
        {{ $$ = { tipo:$1, hijos: [$3],  linea:  yylineno+1, columna:  @1.first_column, lineaF:  @4.last_line, columnaF:  @4.last_column } }}        
;

VALOR_SI
    : es_verdadero  {{ $$ = yytext.toLowerCase() }}
    | es_falso      {{ $$ = yytext.toLowerCase() }}
;

EVALUAR_SI 
    : evaluar_si parenA E parenC llaveA CASOS llaveC
        {{ $$ = { tipo:'evaluar_si', hijos: [$3, $6],  linea:  yylineno+1, columna:  @1.first_column, lineaF:  @7.last_line, columnaF:  @7.last_column } }}        
;

CASOS
    : CASOS CASO   {{ var arr = $1.hijos; $1.hijos = arr.concat($2);  $$ = $1;  }}    
    | CASO         {{  $$ = { tipo: 'casos', hijos: [$1] } }}
;


CASO 
    : es_igual_a E dosPtos SENTS    {{ $$ = { tipo:'caso', hijos: [$2, $4],  linea:  yylineno+1, columna:  @1.first_column, lineaF:  @4.last_line, columnaF:  @4.last_column } }}        
    | defecto dosPtos SENTS         {{ $$ = { tipo:'caso', hijos: [$3],   linea:  yylineno+1, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}        
;

ESTRUCTURA
    : estructura ID corcheteA SENTS corcheteC //solo debería aceptar declaraciones
        {{ $$ = { tipo:'estructura', hijos: [$2, $4],  linea:  yylineno+1, columna:  @1.first_column, lineaF:  @5.last_line, columnaF:  @5.last_column } }}        
;

/*
DECLARACIONES
    : DECLARACIONES DECLARACION ptoComa   {{ var arr = $1; $$ = arr.concat($2); }}
    | DECLARACION ptoComa                 {{ $$ =  [$1] }}   
;
*/

DECLARACION
  : DECLARA  {{ $$ = $1 }}
  | VISIBILIDAD DECLARA {{ objDec = $2; objDec.visibilidad = $1; $$ = objDec; }}
;

DECLARA 
    : TIPO ID            {{ $$ = { tipo:'decl', hijos:[$1, $2], tipoDato:$1.val,     linea:  yylineno+1, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}        
    | ID ID            {{ $$ = { tipo:'decl', hijos:[$1, $2], tipoDato:$1.val,     linea:  yylineno+1, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}        
    | ID ID asigna E           {{ $$ = { tipo:'decl', hijos:[$1, $2, $4], tipoDato:$1.val,     linea:  yylineno+1, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}        
    | TIPO ID asigna E           {{ $$ = { tipo:'decl', hijos:[$1, $2, $4], tipoDato:$1.val,     linea:  yylineno+1, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}        
;

TIPO 
    : TIPO_NATIVO {{ $$ = { tipo:'tipo', val: $1, linea:  yylineno+1, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column  } }}    
;

TIPO_NATIVO
    : entero    {{ $$ = yytext.toLowerCase() }}
    | decimal   {{ $$ = yytext.toLowerCase() }}
    | booleano  {{ $$ = yytext.toLowerCase() }}
    | caracter  {{ $$ = yytext.toLowerCase() }}
    | cadena    {{ $$ = yytext.toLowerCase() }}
;

ASIGNACION
    : E SIGNO_ASIG E {{ $$ = { tipo:$2, hijos:[$1, $3],  linea:  yylineno+1, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}    
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
    : llaveA EXPS llaveC {{ $$ = { tipo:'array', val:[$2],  linea: yylineno+1, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
;

EXPS 
    : EXPS coma E   {{ var arr = $1.hijos; $1.hijos = arr.concat($3);  $$ = $1;  }}    
    | E             {{  $$ = { tipo: 'exps', hijos: [$1] } }}
;

E 
    : E mas E       {{ $$ = { tipo:'+', hijos:[$1, $3],  linea:  yylineno+1, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E menos E     {{ $$ = { tipo:'-', hijos:[$1, $3],  linea:  yylineno+1, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E por E       {{ $$ = { tipo:'*', hijos:[$1, $3],  linea:  yylineno+1, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E entre E     {{ $$ = { tipo:'/', hijos:[$1, $3],  linea:  yylineno+1, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E potencia E  {{ $$ = { tipo:'^', hijos:[$1, $3],  linea:  yylineno+1, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}

    | E igual E     {{ $$ = { tipo:'==',  hijos:[$1, $3], linea: yylineno+1, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E diferente E {{ $$ = { tipo:'!=',  hijos:[$1, $3], linea: yylineno+1, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E mayor E     {{ $$ = { tipo:'>',   hijos:[$1, $3], linea: yylineno+1, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E menor E     {{ $$ = { tipo:'<',   hijos:[$1, $3], linea: yylineno+1, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E mayorI E    {{ $$ = { tipo:'>=',  hijos:[$1, $3], linea: yylineno+1, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}    
    | E menorI E    {{ $$ = { tipo:'<=',  hijos:[$1, $3], linea: yylineno+1, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}    

    | E o E     {{ $$ = { tipo:'||',    hijos:[$1, $3], linea: yylineno+1, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E xor E   {{ $$ = { tipo:'??',    hijos:[$1, $3], linea: yylineno+1, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | E y E     {{ $$ = { tipo:'&&',    hijos:[$1, $3], linea: yylineno+1, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}
    | no E      {{ $$ = { tipo:'!',     hijos:[$2],     linea: yylineno+1, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}
    | nuevo LLAMADA   {{ $$ = { tipo:'nuevo',     hijos:[$2],     linea: yylineno+1, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}

    | menos E %prec UMINUS
                {{ $$ = { tipo:'-',     hijos:[$2],     linea: yylineno+1, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}

    | E inc         {{ $$ = { tipo:'++',    hijos:[$1],  linea: yylineno+1, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}
    | E dec         {{ $$ = { tipo:'--',    hijos:[$1],  linea: yylineno+1, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}    

    | E pto ID    {{ $$ = { tipo:'.',    hijos:[$1, $3],  linea: yylineno+1, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}    
    | E pto LLAMADA    {{ $$ = { tipo:'.',    hijos:[$1, $3],  linea: yylineno+1, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column } }}    
    | parenA E parenC   {{ $$ = $2 }}    
    | ID POSICIONES {{ $$ = { tipo:'[]',    hijos:[$1, $2],  linea: yylineno+1, columna:  @1.first_column, lineaF:  @2.last_line, columnaF:  @2.last_column } }}    
    
    | booleanoLit   {{ $$ = { tipo:'booleanoLit', val: yytext.toLowerCase() == 'verdadero', linea:  yylineno+1, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column  } }}
    | enteroLit     {{ $$ = { tipo:'enteroLit'  , val: parseInt(yytext)     , linea:  yylineno+1, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column  } }}
    | decimalLit    {{ $$ = { tipo:'decimalLit' , val: parseFloat(yytext)   , linea:  yylineno+1, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column  } }}
    | cadenaLit     {{ $$ = { tipo:'cadenaLit'  , val: yytext               , linea:  yylineno+1, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column  } }}    
    | caracterLit   {{ $$ = { tipo:'caracterLit', val: yytext.charCodeAt(0) , linea:  yylineno+1, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column  } }}    
    | nadaWord      {{ $$ = { tipo:'nada',        val: null                 , linea:  yylineno+1, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column  } }}    
    | llaveA nada llaveC    
                    {{ $$ = { tipo:'nada',        val: null                 , linea:  yylineno+1, columna:  @1.first_column, lineaF:  @3.last_line, columnaF:  @3.last_column  } }}    
    | ID            {{ $$ = $1 }}
    | ARRAY         {{ $$ = $1 }}
    | LLAMADA       {{ $$ = $1 }}
    | CREAR_PUNTERO {{ $$ = $1 }}
    | errorLex      {{ $$ = { tipo:'errorLex'   , val: yytext               , linea:  yylineno+1, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column  } }}       
; 

ID 
    : id {{ $$ = { tipo:'id', val: yytext.toLowerCase(), linea:  yylineno+1, columna:  @1.first_column, lineaF:  @1.last_line, columnaF:  @1.last_column } }} 
;