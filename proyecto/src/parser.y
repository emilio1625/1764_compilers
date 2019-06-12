/* Seccion de declaraciones */

%{

#include <stdio.h>
#include <string.h>
#include "list.h"
#include "tabla_tipos.h"
#include "codigo_intermedio.h"
#include "tools.h"

u16 dir_g;
struct tipo *tipo_g;
struct list_head *tt_stack, *ts_stack, *dir_stack, *code_list, *tt_actual,
    *ts_actual;

void init();
void destroy();
void yyerror(char *str);

extern int yylineno;
extern char* yytext;
%}

%union {
    struct {
        enum TT tipo;
        char sval[16];
        union {
            int i;
            float f;
        } val;
    } num;
    // apunta a alguna entrada en la tabla de tipos
    struct tipo *tipo;
    struct {
        enum TT tipo;
        // stack de direcciones siguientes
        struct list_head *next;
    } sent;
    struct {
        // Almacena si es cierta (1) o falsa (0)
        u8 val;
        // Almacena un stack de direcciones que almacena el numero de las
        // instrucciones que deben de incluir la etiqueta verdadra o falsa
        struct list_head * true, *false;
    } cond;
    struct {
        enum TT tipo;
         size_t tam;
        char dir[16];
    } expr;
    char str16[16];
}

/* Terminales */
    /* Palabras reservadas */
        /* Tipos de dato */
%token INT FLOAT CHAR VOID STRUCT
        /* Control de flujo */
%token IF ELSE WHILE DO FOR SWITCH CASE BREAK DEFAULT
        /* Funciones */
%token FUNCT RETURN
%token PRINT
    /* Constantes */
        /* Boleanas */
%token TRUE FALSE
        /* Caracter y cadenas */
%token CCHAR STR
        /* Numerica */
%token<num> NUMERO
    /* Otros */
%token DP PYC LI LD
/* Precedencia de operadores */
%left COMA
%right ASIG
%left OR
%left AND
%left EQ NEQ
%left LT LE GT GE
%left MAS MEN
%left MUL DIV MOD
%right NOT
%left PTO CI CD
%nonassoc PI PD
%nonassoc IF
%nonassoc ELSE
/* Identificadores */
%token<str16> ID

%type<tipo> tipo lista arreglo
%type<sent> sentencias sentencia
%type<expr> expresion
%type<cond> condicion
%type<str16> relacional

%start programa

/* Esquema de traduccion */

%%

programa        : {
                    init();
                } declaraciones funciones {
                    code_imprimir(code_list);
                    // TODO: limpiar el desmadre
                    stack_imprimir(ts_stack, ts_imprimir_tabla);
                    stack_imprimir(tt_stack, tt_imprimir_tabla);
                    destroy();
                };

declaraciones   : tipo {tipo_g = $1;} lista PYC declaraciones
                | ;

tipo            : INT {$$ = tt_buscar_id(tt_actual, TT_INT);}
                | FLOAT {$$ = tt_buscar_id(tt_actual, TT_FLOAT);}
                | CHAR {$$ = tt_buscar_id(tt_actual, TT_CHAR);}
                | VOID {$$ = tt_buscar_id(tt_actual, TT_VOID);}
                | STRUCT {
                    ambito_crear(tt_stack, &tt_actual,
                                ts_stack, &ts_actual,
                                dir_stack, &dir_g);
                } LI declaraciones LD {
                    printf("Tablas de struct\n");
                    tt_imprimir_tabla(tt_actual);
                    ts_imprimir_tabla(ts_actual);

                    u16 dir_previa = dir_g;
                    ambito_restaurar(tt_stack, &tt_actual,
                                    ts_stack, &ts_actual,
                                    dir_stack, &dir_g, 1);

                    $$ = tt_insertar_tipo(tt_actual,
                            TT_STRUCT, NULL, 0, dir_previa);
                };

lista           : lista COMA ID arreglo {
                    if (ts_buscar_id(ts_actual, $3) == NULL) {
                        ts_insertar_simbolo(ts_actual,
                            $3, $4, TS_VAR, dir_g, NULL, 0);
                        dir_g += $4->tam;
                    } else {
                        yyerror("El simbolo ya existe");
                    }
                }
                | ID arreglo {
                    if (ts_buscar_id(ts_actual, $1) == NULL) {
                        ts_insertar_simbolo(ts_actual,
                            $1, $2, TS_VAR, dir_g, NULL, 0);
                        dir_g += $2->tam;
                    } else {
                        yyerror("El simbolo ya existe");
                    }
                };

arreglo         : CI NUMERO CD arreglo {
                    if ($2.tipo == TT_INT && $2.val.i > 0) {
                        $$ = tt_insertar_tipo(tt_actual,
                            TT_ARRAY, $4, 0, $2.val.i);
                    } else {
                        yyerror("El indice debe ser entero mayor a 0");
                    }
                }
                | {$$ = tipo_g;};

funciones       : FUNCT tipo ID PI argumentos PD LI declaraciones sentencias {
                    if ($9.tipo != $2->tipo) {
                        yyerror("El tipo no coincide");
                    }
                    u16 inst = code_push(code_list, "label", "", "", "__");
                    dir_push($9.next, inst);
                    code_backpatch(code_list, $9.next, etiqueta_crear());
                } LD funciones
                | ;

argumentos      : lista_argumentos
                | ;

lista_argumentos: lista_argumentos COMA tipo ID parte_arreglo
                | tipo ID parte_arreglo;

parte_arreglo   : CI CD parte_arreglo
                | ;

sentencias      : sentencias {
                    u16 inst = code_push(code_list, "label", "", "", "__");
                    dir_push($1.next, inst);
                } sentencia {
                    code_backpatch(code_list, $1.next, etiqueta_crear());
                    $$ = $3;
                }
                | sentencia {$$ = $1;};

sentencia       : IF PI condicion PD {
                    u16 inst = code_push(code_list, "label", "", "", "__");
                    dir_push($3.true, inst);
                } sentencia {
                    u16 inst = code_push(code_list, "goto", "", "", "__");
                    $<sent>$.next = list_new();
                    dir_push($<sent>$.next, inst);
                } ELSE {
                    u16 inst = code_push(code_list, "label", "", "", "__");
                    dir_push($3.false, inst);
                } sentencia {
                    code_backpatch(code_list, $3.true, etiqueta_crear());
                    code_backpatch(code_list, $3.false, etiqueta_crear());
                    $$.next = combinar($6.next, combinar($<sent>7.next, $10.next));
                }
                | WHILE PI {
                    u16 inst = code_push(code_list, "label", "", "", "__");
                    $<sent>$.next = list_new();
                    dir_push($<sent>$.next, inst);
                } condicion PD {
                    u16 inst = code_push(code_list, "label", "", "", "__");
                    dir_push($4.true, inst);
                }
                sentencia {
                    char *et = etiqueta_crear();
                    $7.next = combinar($7.next, $<sent>3.next);
                    code_backpatch(code_list, $7.next, et);
                    code_backpatch(code_list, $4.true, etiqueta_crear());
                    code_push(code_list, "goto", "", "", et);
                    $$.next = $4.false;
                }
                | DO sentencia WHILE PI condicion PD PYC {}
                | FOR PI sentencia condicion PYC sentencia PD sentencia {}
                | SWITCH PI expresion PD LI casos predeterminado LD {}
                | BREAK PYC {}
                | LI sentencias LD {}
                | parte_izquierda ASIG expresion PYC {
                    // TODO: Comprobar tipos
                    code_push(code_list, "=", $3.dir, "", "placeholder");
                    $$.next = list_new();
                }
                | RETURN expresion PYC {}
                | RETURN PYC {}
                | PRINT expresion PYC {}
                | expresion PYC {};

casos           : CASE NUMERO DP sentencia casos
                | ;

predeterminado  : DEFAULT DP sentencia
                | ;

parte_izquierda : ID
                | var_arreglo
                | ID PTO ID
                | ;

var_arreglo     : ID CI expresion CD
                | var_arreglo CI expresion CD;

expresion       : expresion MAS expresion {
                    char *dir1, *dir2;
                    // TODO: Revisar que los tipos a operar son compatibles
                    $$.tipo = tipo_max($1.tipo, $3.tipo);
                    if ($$.tipo) {
                        strncpy($$.dir, temporal_crear(), 16);
                        dir1 = tipo_ampliar(code_list, $1.dir, $1.tipo, $$.tipo);
                        dir2 = tipo_ampliar(code_list, $3.dir, $3.tipo, $$.tipo);
                        code_push(code_list, "+", dir1, dir2, $$.dir);
                    } else {
                        yyerror("Los tipos no son operables");
                    }
                }
                | expresion MEN expresion {
                    char *dir1, *dir2;
                    // TODO: Revisar que los tipos a operar son compatibles
                    $$.tipo = tipo_max($1.tipo, $3.tipo);
                    if ($$.tipo) {
                        strncpy($$.dir, temporal_crear(), 16);
                        dir1 = tipo_ampliar(code_list, $1.dir, $1.tipo, $$.tipo);
                        dir2 = tipo_ampliar(code_list, $3.dir, $3.tipo, $$.tipo);
                        code_push(code_list, "-", dir1, dir2, $$.dir);
                    } else {
                        yyerror("Los tipos no son operables");
                    }
                }
                | expresion MUL expresion {
                    char *dir1, *dir2;
                    // TODO: Revisar que los tipos a operar son compatibles
                    $$.tipo = tipo_max($1.tipo, $3.tipo);
                    if ($$.tipo) {
                        strncpy($$.dir, temporal_crear(), 16);
                        dir1 = tipo_ampliar(code_list, $1.dir, $1.tipo, $$.tipo);
                        dir2 = tipo_ampliar(code_list, $3.dir, $3.tipo, $$.tipo);
                        code_push(code_list, "*", dir1, dir2, $$.dir);
                    } else {
                        yyerror("Los tipos no son operables");
                    }
                }
                | expresion DIV expresion {
                    char *dir1, *dir2;
                    // TODO: Revisar que los tipos a operar son compatibles
                    $$.tipo = tipo_max($1.tipo, $3.tipo);
                    if ($$.tipo) {
                        strncpy($$.dir, temporal_crear(), 16);
                        dir1 = tipo_ampliar(code_list, $1.dir, $1.tipo, $$.tipo);
                        dir2 = tipo_ampliar(code_list, $3.dir, $3.tipo, $$.tipo);
                        code_push(code_list, "/", dir1, dir2, $$.dir);
                    } else {
                        yyerror("Los tipos no son operables");
                    }
                }
                | expresion MOD expresion {
                    char *dir1, *dir2;
                    // TODO: Revisar que los tipos a operar son compatibles
                    $$.tipo = tipo_max($1.tipo, $3.tipo);
                    if ($$.tipo) {
                        strncpy($$.dir, temporal_crear(), 16);
                        dir1 = tipo_ampliar(code_list, $1.dir, $1.tipo, $$.tipo);
                        dir2 = tipo_ampliar(code_list, $3.dir, $3.tipo, $$.tipo);
                        code_push(code_list, "mod", dir1, dir2, $$.dir);
                    } else {
                        yyerror("Los tipos no son operables");
                    }
                }
                | var_arreglo {}
                | NUMERO {
                    $$.tipo = $1.tipo;
                    strncpy($$.dir, $1.sval, 16);
                }
                | CCHAR {}
                | STR {}
                | ID {
                    struct simbolo *id = ts_buscar_id(ts_actual, $1);
                    if (id != NULL) {
                        $$.tipo = id->tipo->id;
                        strncpy($$.dir, $1, 16);
                    } else {
                        yyerror("El id no existe");
                    }
                }
                | ID PI parametros PD {};

parametros      : lista_param
                | ;

lista_param     : lista_param COMA expresion
                | expresion;

condicion       : condicion OR {
                    u16 inst = code_push(code_list, "label", "", "", "__");
                    dir_push($1.false, inst);
                } condicion {
                    code_backpatch(code_list, $1.false, etiqueta_crear());
                    $$.true = combinar($1.true, $4.true);
                    $$.false = $4.false;
                }
                | condicion AND {
                    u16 inst = code_push(code_list, "label", "", "", "__");
                    dir_push($1.true, inst);
                } condicion {
                    code_backpatch(code_list, $1.true, etiqueta_crear());
                    $$.false = combinar($1.false, $4.false);
                    $$.true = $4.true;
                }
                | NOT condicion {
                    $$.true = $2.false;
                    $$.false = $2.true;
                }
                | PI condicion PD {$$ = $2;}
                | TRUE {
                    u16 inst = code_push(code_list, "goto", "", "", "__");
                    $$.true = list_new();
                    dir_push($$.true, inst);
                }
                | FALSE {
                    u16 inst = code_push(code_list, "goto", "", "", "__");
                    $$.false = list_new();
                    dir_push($$.false, inst);
                }
                | expresion relacional expresion {
                    char *temp = temporal_crear();
                    code_push(code_list, $2, $1.dir, $3.dir, temp);

                    u16 inst = code_push(code_list, "if", temp, "goto", "__");
                    $$.true = list_new();
                    dir_push($$.true, inst);

                    inst = code_push(code_list, "goto", "", "", "__");
                    $$.false = list_new();
                    dir_push($$.false, inst);
                };


relacional      : LT  {strncpy($$, "<" , 3);}
                | LE  {strncpy($$, "<=", 3);}
                | GT  {strncpy($$, ">" , 3);}
                | GE  {strncpy($$, ">=", 3);}
                | EQ  {strncpy($$, "==", 3);}
                | NEQ {strncpy($$, "!=", 3);};
%%

void yyerror(char * str) {
    printf("Error: En la linea %d, simbolo %s: %s\n", yylineno, yytext, str);
}

void init()
{
    /* Creando el stack de tablas de tipos */
    tt_stack  = stack_crear();
    tt_actual = tt_crear_tabla();
    /* Creando el stack de tablas de simbolos */
    ts_stack  = stack_crear();
    ts_actual = ts_crear_tabla();
    /* Creando el stack de direcciones */
    dir_stack = list_new();
    /* Creando la lista de codigo */
    code_list = list_new();

    if (!tt_stack || !ts_stack || !dir_stack || !code_list || !tt_actual ||
        !ts_actual) {
        printf("Error creando las estructuras de datos\n");
        exit(-1);
    }

    printf("Estructuras de datos inicializadas\n");

    stack_imprimir(tt_stack, tt_imprimir_tabla);
    stack_imprimir(ts_stack, ts_imprimir_tabla);
}

void destroy()
{
    stack_eliminar(&tt_stack, tt_eliminar_tabla);
    stack_eliminar(&ts_stack, ts_eliminar_tabla);
    dir_eliminar(&dir_stack);
    code_eliminar(&code_list);
}
