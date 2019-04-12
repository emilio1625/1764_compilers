%{
#include <stdio.h>
#include "grammar.h"

%}

%option noyywrap
%option yylineno

id [a-zA-Z_][0-9a-zA-Z_]*

%%
{id} {return ID;}
"(" {return PI;}
")" {return PD;}
"+" {return MAS;}
"-" {return MENOS;}
"*" {return MUL;}
"/" {return DIV;}
"%" {return MOD;}
[ \t\n]+ {}
. {printf("Error lexico en la linea %d: %s\n", yylineno, yytext);exit(-1);}
%%
