%{

#include <stdio.h>
#include "tabla_tipos.h"
#include "parser.h"

%}

%option noyywrap
%option yylineno
%x COMMENT

id [a-zA-Z_][0-9a-zA-Z_]*

digito [0-9]
entero [1-9]{digito}*|0
decimal {entero}\.{digito}*|entero?\.digito+
exponente [Ee][+-]?digito+
real {decimal}{exponente}?|{entero}{exponente}
flotante {entero}f|{real}

ascii [[:graph:]]|[[:space:]]|[[:cntrl:]]

%%

    /* Comentarios */
"!*"                {BEGIN COMMENT  ;}
<COMMENT>[^*]       {}
<COMMENT>"*"/[^?]   {}
<COMMENT>"*?"       {BEGIN 0        ;}
    /* Palabras reservadas */
    /* Tipos de dato */
"entero"    {return INT     ;}
"real"      {return FLOAT   ;}
"letra"     {return CHAR    ;}
"nada"      {return VOID    ;}
"estruc"    {return STRUCT  ;}
    /* Control de flujo */
"si"        {return IF      ;}
"sino"      {return ELSE    ;}
"mientras"  {return WHILE   ;}
"repetir"   {return DO      ;}
"desde"     {return FOR     ;}
"elegir"    {return SWITCH  ;}
"opcion"    {return CASE    ;}
"otro"      {return DEFAULT ;}
"parar"     {return BREAK   ;}
    /* Funciones */
"funcion"   {return FUNCT   ;}
"devolver"  {return RETURN  ;}
"imprimir"  {return PRINT   ;}
    /* Constantes */
        /* Boleanas */
"cierto"    {return TRUE    ;}
"falso"     {return FALSE   ;}
        /* Caracteres y cadenas */
\'{ascii}?\' {strncpy(yylval.str16, yytext, 16); return CCHAR;}
\"{ascii}*\" {strncpy(yylval.str16, yytext, 16); return STR  ;}
":"         {return DP      ;}
";"         {return PYC     ;}
"{"         {return LI      ;}
"}"         {return LD      ;}
        /* Numeros */
{entero} {
    yylval.num.tipo = TT_INT;
    strncpy(yylval.num.sval, yytext, 16);
    yylval.num.val.i = (int) strtol(yytext, NULL, 0);
    return NUMERO;
}
{flotante} {
    yylval.num.tipo = TT_FLOAT;
    strncpy(yylval.num.sval, yytext, 16);
    yylval.num.val.f = (float) strtod(yytext, NULL);
    return NUMERO;
}
    /* Operadores */
"("     {return PI  ;}
")"     {return PD  ;}
"["     {return CI  ;}
"]"     {return CD  ;}
"."     {return PTO ;}
"no"    {return NOT ;}
"*"     {return MUL ;}
"/"     {return DIV ;}
"%"     {return MOD ;}
"+"     {return MAS ;}
"-"     {return MEN ;}
"<"     {return LT  ;}
"<="    {return LE  ;}
">"     {return GT  ;}
">="    {return GE  ;}
"=="    {return EQ  ;}
"!="    {return NEQ ;}
"y"     {return AND ;}
"o"     {return OR  ;}
"="     {return ASIG;}
","     {return COMA;}
    /* Espacios en blanco */
[ \t\n]+ {}
    /* Identificadores */
{id} { strncpy(yylval.str16, yytext, 16); return ID;}

. {printf("Error lexico en la linea %d\n", yylineno); exit(-1);}

%%


