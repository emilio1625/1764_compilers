#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "grammar.h"
#include "lex.yy.c"
#include "list.h"

enum TT token;
extern FILE* yyin;

const struct grammar G = {
    .syms =
        (struct sym[13]){
            {NT, "E", 0},     // 0
            {NT, "F", 1},     // 1
            {NT, "G", 2},     // 2
            {T, "$", ENDOF},  // 3
            {T, "id", ID},    // 4
            {T, "(", PI},     // 5
            {T, ")", PD},     // 6
            {T, "+", MAS},    // 7
            {T, "-", MENOS},  // 8
            {T, "*", MUL},    // 9
            {T, "/", DIV},    // 10
            {T, "%", MOD},    // 11
            {E, "", 0},       // 12
        },
    .num_syms = 7,
    .prods =
        (struct prod[9]){
            {0, "4/1", 2},      // 0
            {0, "5/0/6/1", 4},  // 1
            {1, "2/1", 2},      // 2
            {1, "12", 0},       // 3
            {2, "7/0", 2},      // 4
            {2, "8/0", 2},      // 5
            {2, "9/0", 2},      // 6
            {2, "10/0", 2},     // 7
            {2, "11/0", 2},     // 8
        },
    .num_prods = 9,
};

const int8_t M[][9] = {
    //$  id   (   )   +   -   *   /   %
    {-1,  0,  1, -1, -1, -1, -1, -1, -1},  // E
    { 3, -1, -1,  3,  2,  2,  2,  2,  2},  // F
    {-1, -1, -1, -1,  4,  5,  6,  7,  8},  // G
};

// Stack
LIST_HEAD(stack);

void ASLL1();
void error(const char* s);
void accept();
void print_stack();

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

    ASLL1();

    fclose(f);
    return 0;
}

void ASLL1()
{
    int8_t prod_idx;           // indice de la produccion en la gramatica
    struct prod* prod = NULL;  // almacena una produccion
    struct sym* top = NULL;    // almacena el resultado del ultimo pop()
    struct sym* const $ = &(G.syms[3]);              // sin de archivo
    struct sym* const S = G.syms;                    // simbolo inicial
    struct sym* entry = malloc(sizeof(struct sym));  // nuevo simbolo en la pila
    struct list_head* cursor;  // axiliar para insertar en el orden adecuado

    list_add(&($->list), &stack);  // push($)
    memcpy(entry, S, sizeof(struct sym));
    list_add(&(entry->list), &stack);  // push(S)

    token = yylex();  // primer token

    printf("Token: %s\n", yytext);
    print_stack();
    printf("\n");

    printf("Inicio algoritmo\n\n");

    while (!sym_equal(top = list_first_entry(&stack, struct sym, list), $)) {
        printf("Token: %s\n", yytext);
        print_stack();
        printf("\n");
        struct list_head * s = stack.next;

        if (top->type == NT) {
            if ((prod_idx = M[top->pos][token]) != -1) {
                list_del(&(top->list));           // pop()
                prod = &(G.prods[prod_idx]);      // M[S][token] = A -> Y_1 ...
                char* body = strdup(prod->body);  // strdup aloja memoria
                char* Y = strtok(body, "/");      // A -> Y_1 ... Y_k
                cursor = &stack;
                // Stack: X Y Z $
                //       ^ cursor
                for (int8_t i = 1; i <= prod->num; i++) {  // i = 1 ... k
                    prod_idx = strtol(Y, NULL, 10);        // cadena a numero
                    entry = malloc(sizeof(struct sym));
                    memcpy(entry, (S + prod_idx), sizeof(struct sym));
                    list_add(&(entry->list), cursor);  // push(Y_i)
                    cursor = cursor->next;  // insertando detras de Y_i
                    // Y_1 X Y Z $
                    //    ^ cursor
                    Y = strtok(NULL, "/");  // Y = Y_(i + 1)
                }
                // Y_1 ... Y_k X Y Z $
                free(body);  // libera la memoria alojada por strdup
            } else {
                printf("Token: %s\n", yytext);
                print_stack();
                free(top);
                error("1");
            }
        } else if (top->type == T) {
            list_del(&(top->list));  // pop()
            token = yylex();         // siguiente token
        } else {
            printf("Token: %s\n", yytext);
            print_stack();
            free(top);
            error("2");
        }
        free(top);
    }

    if (token == ENDOF) {  // token == $
        printf("Token: %s\n", yytext);
        print_stack();
        accept();
        printf("\n");
    } else {
        printf("Token: %s\n", yytext);
        print_stack();
        error("3");
    }
}

void error(const char* s)
{
    struct sym *pos, *tmp;  // temporal para almacenar elementos de la pila
    list_for_each_entry_safe(pos, tmp, &stack, list)
    {
        if (pos->type != T || pos->pos != ENDOF) {
            list_del(&(pos->list));
            free(pos);
        }
    }
    fclose(yyin);
    printf("Error D; %s\n", s);
    exit(-1);
}

void accept()
{
    printf("Aceptar :D\n");
}

void print_stack()
{
    int i = 0;
    printf("Stack: ");
    struct sym* entry;  // temporal para almacenar elementos de la pila
    list_for_each_entry(entry, &stack, list)  // despliega la pila
    {
        i++;
        printf("%s ", entry->name);
        if (i > 30)
            break;
    }
    printf("\n");
}
