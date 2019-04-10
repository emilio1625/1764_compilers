#include <stdlib.h>
#include <stdio.h>
#include "parser.h"

extern int yylineno;
extern int yylex();
extern char* yytext;

int token;

void E()
{
    T();
    Ep();
}

void Ep()
{
    while (token == MAS) {
        token = yylex();
        T();
    }
}

void T()
{
    F();
    Tp();
}

void Tp()
{
    while (token == MUL) {
        token = yylex();
        F();
    }
}

void F()
{
    switch (token) {
        case PI:
            token = yylex();
            E();
            if (token == PD) {
                token = yylex();
            } else {
                error();
            }
            break;
        case ID:
            token = yylex();
            break;
        default:
            error();
            break;
    }
}

void error()
{
    printf("Error en la linea %d\n", yylineno);
    printf("token: %s %d\n", yytext, token);
    exit(1);
}

void init()
{
    token = yylex();
    E();
    if (token == 0) {
        printf("Fin del analisis\n");
    } else {
        error();
    }
}
