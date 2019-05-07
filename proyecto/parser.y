/* Seccion de declaraciones */

%{
#include <stdio.h>
void yyerror(char * str);
%}

/* Terminales */
/* Palabras reservadas */
%token INT FLOAT DOUBLE CHAR VOID STRUCT
%token IF ELSE WHILE DO FOR SWITCH CASE BREAK DEFAULT
%token FUNCT RETURN
%token TRUE FALSE
%token PYC
/* Constantes numericas */
%token NUM
/* Identificadores */
%token ID
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
%left PTO LI LD
%nonassoc PI PD

%start program

/* Esquema de traduccion */

%%

program : decl sent;

decl: decl type list PYC | ;

type: INT | FLOAT;

list: list COMA ID | ID;

sent: ID ASIG exp PYC |
    IF PI ebool PD sent;

ebool: exp GT exp;

exp: exp MAS exp |
    exp MUL exp |
    PI exp PD |
    ID | NUM;

%%

void yyerror(char * str) {
    printf("Error: %s\n", str);
}
