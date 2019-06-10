#include <stdio.h>
#include "tabla_tipos.h"
#include "parser.h"
#include "lexer.h"

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
