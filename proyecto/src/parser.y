/* Seccion de declaraciones */

%{

#include <stdio.h>
#include <string.h>
#include "list.h"
#include "tabla_tipos.h"
#include "codigo_intermedio.h"
#include "tools.h"

u16 dir_actual, dir_previa;
struct tipo *tipo_g;
struct list_head *tt_stack, *ts_stack, *dir_stack, *code_list, *tt_actual, *ts_actual;

void init();
void destroy();
void yyerror(char * str);

extern int yylineno;
extern char* yytext;
%}

%union {
    struct {
        enum TT tipo;
        char sval[32];
        union {
            int i;
            float f;
        } val;
    } num;
    struct tipo *tipo;
    char str32[32];
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
%token<str32> ID

%type<tipo> tipo lista arreglo

%start programa

/* Esquema de traduccion */

%%

programa        : {
                    init();
                } declaraciones funciones {
                    // TODO: limpiar el desmadre
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
                                dir_stack, &dir_actual);
                } LI declaraciones LD {
                    printf("Tablas de struct\n");
                    tt_imprimir_tabla(tt_actual);
                    ts_imprimir_tabla(ts_actual);

                    dir_previa = dir_actual;
                    ambito_restaurar(tt_stack, &tt_actual,
                                    ts_stack, &ts_actual,
                                    dir_stack, &dir_actual, 1);

                    $$ = tt_insertar_tipo(tt_actual,
                            TT_STRUCT, NULL, 0, dir_previa);
                };

lista           : lista COMA ID arreglo {
                    if (ts_buscar_id(ts_actual, $3) == NULL) {
                        ts_insertar_simbolo(ts_actual,
                            $3, $4, TS_VAR, dir_actual, NULL, 0);
                        dir_actual += $4->tam;
                    } else {
                        yyerror("El simbolo ya existe");
                    }
                }
                | ID arreglo {
                    if (ts_buscar_id(ts_actual, $1) == NULL) {
                        ts_insertar_simbolo(ts_actual,
                            $1, $2, TS_VAR, dir_actual, NULL, 0);
                        dir_actual += $2->tam;
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

funciones       : FUNCT tipo ID PI argumentos PD LI declaraciones sentencias LD funciones
                | ;

argumentos      : lista_argumentos
                | ;

lista_argumentos: lista_argumentos COMA tipo ID parte_arreglo
                | tipo ID parte_arreglo;

parte_arreglo   : CI CD parte_arreglo
                | ;

sentencias      : sentencias sentencia
                | sentencia;

sentencia       : IF PI condicion PD sentencia
                | IF PI condicion PD sentencia ELSE sentencia
                | WHILE PI condicion PD sentencia
                | DO sentencia WHILE PI condicion PD PYC
                | FOR PI sentencia condicion PYC sentencia PD sentencia
                | SWITCH PI expresion PD LI casos predeterminado LD
                | BREAK PYC
                | LI sentencias LD
                | parte_izquierda ASIG expresion PYC
                | RETURN expresion PYC
                | RETURN PYC
                | PRINT expresion PYC
                | expresion PYC;

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

expresion       : expresion MAS expresion
                | expresion MEN expresion
                | expresion MUL expresion
                | expresion DIV expresion
                | expresion MOD expresion
                | var_arreglo
                | NUMERO
                | CCHAR
                | STR
                | ID
                | ID PI parametros PD;

parametros      : lista_param
                | ;

lista_param     : lista_param COMA expresion
                | expresion;

condicion       : condicion OR condicion
                | condicion AND condicion
                | NOT condicion
                | PI condicion PD
                | expresion relacional expresion
                | TRUE
                | FALSE;

relacional      : LT
                | LE
                | GT
                | GE
                | EQ
                | NEQ;
%%

void yyerror(char * str) {
    printf("Error: En la linea %d, simbolo %s: %s\n", yylineno, yytext, str);
}

void init()
{
    /* Creando el stack de tablas de tipos */
    tt_stack = stack_crear();
    /* Creando el stack de tablas de simbolos */
    ts_stack = stack_crear();
    /* Creando el stack de direcciones */
    dir_stack = list_new();
    /* Creando la lista de codigo */
    code_list = list_new();

    if (!tt_stack || !ts_stack || !dir_stack || !code_list) {
        printf("Error creando las estructuras de dato\n");
        exit (-1);
    }
    ambito_crear(tt_stack, &tt_actual, ts_stack, &ts_actual, dir_stack,
                 &dir_actual);
    /* tt_global = tt_actual; */
    /* ts_global = ts_actual; */


    printf("Estructuras de datos inicializadas\n");

    stack_imprimir(tt_stack, tt_imprimir_tabla);
    stack_imprimir(ts_stack, ts_imprimir_tabla);
}

void destroy () {
    stack_eliminar(&tt_stack, tt_eliminar_tabla);
    stack_eliminar(&ts_stack, ts_eliminar_tabla);
    dir_eliminar(&dir_stack);
    code_eliminar(&code_list);
}
