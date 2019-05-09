/* Seccion de declaraciones */

%{

#include <stdio.h>
#include <string.h>
#include "list.h"
void yyerror(char * str);
char g_tipo[5];
extern int yylineno;
extern char* yytext;

%}

%union {
    struct {
        int tipo;
        char val[32];
    } num;
    char tipo[5];
    char id[32];
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

%type<tipo> tipo;
%type<id> ID;

%start programa

/* Esquema de traduccion */

%%

programa        : declaraciones funciones
                ;

declaraciones   : declaraciones tipo {strcpy(g_tipo, $2);} lista PYC
                | ;

tipo            : INT {strcpy($$, "int");}
                | FLOAT {strcpy($$, "float");}
                | DOUBLE {strcpy($$, "doubl");}
                | CHAR {strcpy($$, "char");}
                | VOID {strcpy($$, "void");}
                | STRUCT LI declaraciones LD {strcpy($$, "struc");}
                ;

lista           : lista COMA ID {printf("El tipo de %s es %s\n", $3, g_tipo);} arreglo
                | ID {printf("El tipo de %s es %s\n", $1, g_tipo);} arreglo
                ;

arreglo         : CI NUMERO CD arreglo
                | ;

funciones       : FUNCT tipo ID PI argumentos PD LI declaraciones sentencias LD funciones
                | ;

argumentos      : lista_argumentos
                | ;

lista_argumentos: lista_argumentos COMA tipo ID parte_arreglo
                | tipo ID parte_arreglo
                ;

parte_arreglo   : CI CD parte_arreglo
                | ;

sentencias      : sentencias sentencia
                | sentencia
                ;

sentencia       : IF PI condicion PD sentencia
                | IF PI condicion PD sentencia ELSE sentencia
                | WHILE PI condicion PD sentencia
                | DO sentencia WHILE PI condicion PD PYC
                | FOR PI sentencia PYC condicion PYC sentencia PD sentencia
                | SWITCH PI expresion PD LI casos predeterminado LD
                | BREAK PYC
                | LI sentencias LD
                | parte_izquierda ASIG expresion PYC
                | RETURN expresion PYC
                | RETURN PYC
                | PRINT expresion PYC
                ;

casos           : CASE DP NUMERO sentencia predeterminado
                | ;

predeterminado  : DEFAULT DP sentencia
                ;

parte_izquierda : ID
                | var_arreglo
                | ID PTO ID
                | ;

var_arreglo     : ID CI expresion CD
                | var_arreglo CI expresion CD
                ;

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
                | ID PI parametros PD
                ;

parametros      : lista_param
                | ;

lista_param     : lista_param COMA expresion
                | expresion
                ;

condicion       : condicion OR condicion
                | condicion AND condicion
                | NOT condicion
                | PI condicion PD
                | expresion relacional expresion
                | TRUE
                | FALSE
                ;

relacional      : LT
                | LE
                | GT
                | GE
                | EQ
                | NEQ
                ;
%%

void yyerror(char * str) {
    printf("Error: %s en la linea %d, %s\n", str, yylineno, yytext);
}
