%{
#include <stdio.h>
#include "parser.h"
%}

%option noyywrap
%option yylineno

id [a-zA-Z_][0-9a-zA-Z_]*

%%
{id} {return ID;}
"*" {return MUL;}
"+" {return MAS;}
"(" {return PI;}
")" {return PD;}
[ \t\n]+ {}
. {printf("Error lexico en la linea %d\n", yylineno);}
%%

