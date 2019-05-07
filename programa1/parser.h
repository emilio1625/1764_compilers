#ifndef PARSER_H
#define PARSER_H

enum TT {
    EOF,
    ID,
    PI,
    PD,
    MAS,
    MENOS,
    MUL,
    DIV,
    MOD,
};

void E();
void Ep();
void T();
void Tp();
void F();
void error();
void init();

#endif /* end of PARSER_H */
