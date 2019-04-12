#ifndef GRAMMAR_H
#define GRAMMAR_H

#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include "list.h"

enum TT {
    ENDOF,
    ID,
    PI,
    PD,
    MAS,
    MENOS,
    MUL,
    DIV,
    MOD,
};

enum ST {
    NT,
    T,
    E,
};

struct sym {
    enum ST type;
    char* name;
    uint8_t pos;
    struct list_head list;
};

struct prod {
    uint8_t head;
    char* body;
    uint8_t num;
};

struct grammar {
    struct sym* syms;
    uint8_t num_syms;
    struct prod* prods;
    uint8_t num_prods;
};

bool sym_equal(const struct sym* lhs, const struct sym* rhs)
{
    return lhs->type == rhs->type && strcmp(lhs->name, rhs->name) == 0 &&
           lhs->pos == rhs->pos;
}

#endif /* end of include guard */
