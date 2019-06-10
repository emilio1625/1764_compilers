#ifndef TOOLS_H
#define TOOLS_H

#include <stdio.h>
#include "list.h"
#include "stack.h"
#include "tabla_simbolos.h"
#include "tabla_tipos.h"

///////////////////////////////////////////////////////////////////////////////
//                               Etiquetas                                   //
///////////////////////////////////////////////////////////////////////////////
char *etiqueta_crear()
{
    char *str = malloc(16 * sizeof(char));
    static const char set[] =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

    sprintf(str, "label_");

    for (int i = 6; i < 16; ++i) {
        str[i] = set[rand() % (sizeof(set) - 1)];
    }

    str[16] = '\0';
    return str;
}

///////////////////////////////////////////////////////////////////////////////
//                         Stack de direciones                               //
///////////////////////////////////////////////////////////////////////////////
struct dir {
    u16 dir;
    struct list_head list;
};

void dir_push(struct list_head *stack, u16 dir)
{
    if (stack == NULL)
        return;
    struct dir *new = malloc(sizeof(struct dir));
    if (new == NULL)
        return;
    new->dir = dir;
    list_add(&new->list, stack);
}

u16 dir_pop(struct list_head *stack)
{
    if (stack == NULL || list_empty(stack))
        return -1;
    struct dir *entry = list_first_entry(stack, struct dir, list);
    list_del(&entry->list);
    u16 dir = entry->dir;
    free(entry);
    return dir;
}

u16 dir_peek(struct list_head *stack)
{
    if (stack == NULL || list_empty(stack))
        return -1;
    struct dir *entry = list_first_entry(stack, struct dir, list);
    u16 dir           = entry->dir;
    return dir;
}

void dir_eliminar(struct list_head **stack)
{
    if (stack == NULL || *stack == NULL)
        return;
    struct dir *dir, *sig;
    if (!list_empty(*stack)) {
        list_for_each_entry_safe(dir, sig, *stack, list)
        {
            list_del(&dir->list);
            free(dir);
        }
    }
    free(*stack);
    *stack = NULL;
}

///////////////////////////////////////////////////////////////////////////////
//                                 Ambito                                    //
///////////////////////////////////////////////////////////////////////////////
void ambito_crear(struct list_head *tt_s,
                  struct list_head **tt,
                  struct list_head *ts_s,
                  struct list_head **ts,
                  struct list_head *dir_s,
                  u16 *dir)
{
    /* Creando una nueva tabla de tipos */
    stack_push(tt_s, tt_crear_tabla());
    *tt = stack_peek(tt_s);
    if (tt == NULL) {
        printf("Error creando la tabla de tipos\n");
    }

    /* Creando una nueva tabla de simbolos */
    stack_push(ts_s, ts_crear_tabla());
    *ts = stack_peek(ts_s);
    if (ts == NULL) {
        printf("Error creando la tabla de simbolos\n");
    }

    /* Guadando la direccion anterior y regresando a 0 la actual */
    dir_push(dir_s, 0);
    *dir = dir_peek(dir_s);
}

void ambito_restaurar(struct list_head *tt_s,
                      struct list_head **tt,
                      struct list_head *ts_s,
                      struct list_head **ts,
                      struct list_head *dir_s,
                      u16 *dir,
                      int eliminar)
{
    stack_pop(ts_s);
    if (eliminar)
        ts_eliminar_tabla(ts);
    *ts = stack_peek(ts_s);

    stack_pop(tt_s);
    if (eliminar)
        tt_eliminar_tabla(tt);
    *ts = stack_peek(tt_s);

    dir_pop(dir_s);
    *dir = dir_peek(dir_s);
}

#endif /* end of include guard: TOOLS_H */
