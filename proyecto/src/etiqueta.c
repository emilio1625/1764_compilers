#include "etiqueta.h"
#include <stdio.h>

char *et_nueva()
{
    char *str = malloc(TAM_ETIQUETA * sizeof(char));
    static const char set[] =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

    sprintf(str, "label_");

    for (int i = 6; i < TAM_ETIQUETA - 2; ++i) {
        str[i] = set[rand() % (sizeof(set) - 1)];
    }

    sprintf(str, "%s:\n", str);

    str[TAM_ETIQUETA] = '\0';
    return str;
}

void et_insertar(struct list_head *stack, char *str)
{
    if (stack == NULL)
        return;
    struct etiqueta *et = malloc(sizeof(struct etiqueta));
    if (et == NULL)
        return;
    et->str = str;
    list_add(&et->list, stack);
}

struct list_head *et_crear_stack()
{
    return list_new();
}

void et_eliminar_stack(struct list_head *stack)
{
    if (stack == NULL)
        return;
    struct etiqueta *et, *sig;
    if (!list_empty(stack)) {
        list_for_each_entry_safe(et, sig, stack, list)
        {
            list_del(&et->list);
            free(et->str);
            free(et);
        }
    }
    free(stack);
    stack = NULL;
}

void et_imprimir_etiqueta(struct etiqueta *et)
{
    if (et == NULL) {
        printf("etiqueta nula\n");
        return;
    }
    printf("%s", et->str);
}

void et_imprimir_stack(struct list_head *stack)
{
    struct etiqueta *et;
    printf("Stack de etiquetas\n");
    if (stack == NULL || list_empty(stack)) {
        printf("Vacio\n");
        return;
    }
    list_for_each_entry(et, stack, list) { et_imprimir_etiqueta(et); }
}

