%{
#include <stdio.h>

#include "y.tab.h"
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
"doble"     {return DOUBLE  ;}
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
\'{ascii}?\' {return CCHAR   ;}
\"{ascii}*\" {return STR    ;}
":"         {return DP      ;}
";"         {return PYC     ;}
"{"         {return LI      ;}
"}"         {return LD      ;}
        /* Numeros */
{entero} {
    yylval.num.tipo = INT;
    strcpy(yylval.num.val, yytext);
    return NUMERO;
}
{flotante} {
    yylval.num.tipo = FLOAT;
    strcpy(yylval.num.val, yytext);
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
    /* Identificadores */
{id} { strcpy(yylval.id, yytext); return ID;}
    /* Espacios en blanco */
[ \t\n]+ {}
. {printf("Error lexico en la linea %d\n", yylineno);}

%%

extern int yyparse();
int main(int argc, const char* argv[])
{
    FILE* f;
    if (argc < 2) {
        return -1;
    }

    f = fopen(argv[1], "r");

    if (f == NULL) {
        return -1;
    }

    yyin = f;

    /* while ((token = yylex()) != 0) { */
        /* printf("Token: %s, %d\n", yytext, token); */
    /* } */
    yyparse();

    fclose(f);
    return 0;
}
