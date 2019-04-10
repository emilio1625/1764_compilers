#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "grammar.h"
#include "list.h"

struct grammar G = {
    .syms =
        (struct sym[7]){
            {NT, "A", 0},
            {NT, "B", 1},
            {NT, "C", 2},
            {T, "x", 0},
            {T, "y", 1},
            {T, "$", 2},
            {E, "", 0},
        },
    .num_syms = 7,
    .prods =
        (struct prod[5]){
            {0, "1/2", 2},
            {1, "3", 1},
            {1, "6", 0},
            {2, "4", 1},
            {1, "6", 0},
        },
    .num_prods = 5,
};

int8_t M[][3] = {
    {0, 0, 0},
    {1, 2, 2},
    {-1, 3, 4},
};

// Stack
struct sym eof = {
    .type = T,
    .name = "$",
    .pos = 2,
    .list = LIST_HEAD_INIT(eof.list),
};

LIST_HEAD(stack);

uint8_t token;

void error(const char* s);
void accept();
void print_stack();
char* strrev(char* s);

int8_t yylex()
{
    uint8_t input[] = {0, 1, 2};  // entrada = "xy$"
    static uint8_t i = 0;
    return input[i++];
}

int main(void)
{
    int8_t prod_num;    // indice de la produccion en la gramatica
    struct prod* prod;  // almacena una produccion
    struct sym* top;    // almacena el resultado del ultimo pop() a la pila

    list_add(&(eof.list), &stack);        // push($)
    list_add(&(G.syms[0].list), &stack);  // push(S)

    token = yylex();  // deberia de ser el generador de tokens

    printf("token: %d\n", token);
    print_stack();
    printf("\n");

    printf("Inicio algoritmo\n\n");

    while (!sym_equal(top = list_first_entry(&stack, struct sym, list), &eof)) {
        printf("cima: %s\n", top->name);
        printf("token: %s\n", G.syms[3 + token].name);
        print_stack();
        printf("\n");

        list_del(&(top->list));  // pop()
        if (top->type == NT) {
            if ((prod_num = M[top->pos][token]) != -1) {
                prod = &(G.prods[prod_num]);
                char* body = strdup(prod->body);  // strok modifica la cadena :c
                strrev(body);  // Debemos meter las producciones en orden
                               // inverso a su aparicion
                char* Y = strtok(body, "/");               // Y_k
                for (int8_t k = prod->num; k >= 1; k--) {  // k = num ... 1
                    prod_num = strtol(Y, NULL, 10);        // cadena a numero
                    list_add(&(G.syms[prod_num].list), &stack);  // Push(Y_k)
                    Y = strtok(NULL, "/");  // Y = Y_(k - 1)
                }
                free(body);  // libera la memoria alojada por strdup
            } else {
                printf("cima: %s\n", top->name);
                printf("token: %s\n", G.syms[3 + token].name);
                print_stack();
                error("1");
            }
        } else if (top->type == T) {
            top = list_first_entry(&stack, struct sym, list);  // pop()
            token = yylex();  // siguiente token
        } else {
            printf("cima: %s\n", top->name);
            printf("token: %s\n", G.syms[3 + token].name);
            print_stack();
            error("2");
        }
    }

    if (token == eof.pos) {  // token == $
        printf("cima: %s\n", top->name);
        printf("token: %d\n", token);
        print_stack();
        accept();
        printf("\n");
    } else {
        printf("cima: %s\n", top->name);
        printf("token: %d\n", token);
        print_stack();
        error("3");
    }

    return 0;
}

void error(const char* s)
{
    printf("Error D; %s\n", s);
    exit(-1);
}

void accept()
{
    printf("Aceptar :D\n");
}

void print_stack()
{
    printf("Stack: ");
    struct sym* entry;  // temporal para almacenar elementos de la pila
    list_for_each_entry(entry, &stack, list)  // despliega la pila
    {
        printf("%s ", entry->name);
    }
    printf("\n");
}

char* strrev(char* s)  // reverse in-place
{
    if (!s || strlen(s) < 2)  // Es reversible?
        return s;

    char* head = s;
    char* tail = s + strlen(s) - 1;
    char temp;

    do {
        temp = *head;
        *head = *tail;
        *tail = temp;
    } while (++head < --tail);
    return s;
}
