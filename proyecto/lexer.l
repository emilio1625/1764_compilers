%{
#include <stdio.h>

enum TOKEN {
    /* Palabras reservadas */
    INT = 1,
    FLOAT,
    DOUBLE,
    CHAR,
    VOID,
    STRUCT,

    IF,
    ELSE,
    WHILE,
    DO,
    FOR,
    SWITCH,
    BREAK,
    CASE,
    DEFAULT,

    FUNCT,
    RETURN,

    TRUE,
    FALSE,

    PYC,
    /* Numeros */
    NUMERO,
    /* Operadores unarios */
    NOT,
    /* Operadores binarios */
    CI,
    CD,
    PTO,
    MUL,
    DIV,
    MOD,
    MAS,
    MEN,
    LT,
    LE,
    GT,
    GE,
    EQ,
    NEQ,
    OR,
    AND,
    ASIG,
    COMA,
    /* Otros */
    PI,
    PD,
    LI,
    LD,
    /* Caracteres y cadenas */
    CCHAR,
    STR,
    /* Identificadores */
    ID,
};
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
numero {entero}|{real}

ascii [[:graph:]]|[[:space:]]|[[:cntrl:]]

%%

    /* Comentarios */
"!*"                {BEGIN COMMENT  ;}
<COMMENT>[^*]       {}
<COMMENT>"*"/[^?]   {}
<COMMENT>"*?"       {BEGIN 0        ;}
    /* Palabras reservadas */
"entero"    {return INT     ;}
"real"      {return FLOAT   ;}
"doble"     {return DOUBLE  ;}
"letra"     {return CHAR    ;}
"nada"      {return VOID    ;}
"estruc"    {return STRUCT  ;}
"si"        {return IF      ;}
"sino"      {return ELSE    ;}
"mientras"  {return WHILE   ;}
"repetir"   {return DO      ;}
"desde"     {return FOR     ;}
"elegir"    {return SWITCH  ;}
"parar"     {return BREAK   ;}
"funcion"   {return FUNCT   ;}
"devolver"  {return RETURN  ;}
"opcion"    {return CASE    ;}
"otro"      {return DEFAULT ;}
"cierto"    {return TRUE    ;}
"falso"     {return FALSE   ;}
";"         {return PYC     ;}
"("         {return PI      ;}
")"         {return PD      ;}
"{"         {return LI      ;}
"}"         {return LD      ;}
    /* Numeros */
{numero} {return NUMERO;}
    /* Operadores unarios */
"no"    {return NOT ;}
    /* Operadores binarios */
"["     {return CI  ;}
"]"     {return CD  ;}
"."     {return PTO ;}
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
"o"     {return OR  ;}
"y"     {return AND ;}
"="     {return ASIG;}
","     {return COMA;}
    /* Caracteres y cadenas */
\'{ascii}?\' {return CCHAR   ;}
\"{ascii}*\" {return STR    ;}
    /* Identificadores */
{id} {return ID;}
    /* Espacios en blanco */
[ \t\n]+ {}
. {printf("Error lexico en la linea %d\n", yylineno);}
%%

int main(int argc, const char* argv[])
{
    enum TOKEN token;
    FILE* f;
    if (argc < 2) {
        return -1;
    }

    f = fopen(argv[1], "r");

    if (f == NULL) {
        return -1;
    }

    yyin = f;

    while ((token = yylex()) != 0) {
        printf("Token: %s, %d\n", yytext, token);
    }

    fclose(f);
    return 0;
}
