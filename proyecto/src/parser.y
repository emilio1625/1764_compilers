/* Seccion de declaraciones */

%{

#include <stdio.h>
#include <string.h>
#include "list.h"
#include "tabla_tipos.h"
#include "tools.h"

char g_tipo[5];
u16 dir_actual;
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
    char str32[32];
}

/* Terminales */
    /* Palabras reservadas */
        /* Tipos de dato */
%token INT FLOAT DOUBLE CHAR VOID STRUCT
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
%token NUMERO
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
%token ID

%start programa

/* Esquema de traduccion */

%%

programa        : {
                    init();
                } declaraciones funciones {
                    // TODO: limpiar el desmadre
                    destroy();
                };

declaraciones   : tipo lista PYC declaraciones
                | ;

tipo            : INT
                | FLOAT
                | DOUBLE
                | CHAR
                | VOID
                | STRUCT LI declaraciones LD ;

lista           : lista COMA ID arreglo
                | ID arreglo;

arreglo         : CI NUMERO CD arreglo
                | ;

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
    printf("Error: %s en la linea %d, %s\n", str, yylineno, yytext);
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
