#include <stdio.h>
#include "parser.h"

extern FILE *yyin;

int main(int argc, const char *argv[])
{
    FILE *f;
    if (argc < 2) {
        return -1;
    }

    f = fopen(argv[1], "r");

    if (f == NULL) {
        return -1;
    }

    yyin = f;

    init();

    fclose(f);
    return 0;
}

