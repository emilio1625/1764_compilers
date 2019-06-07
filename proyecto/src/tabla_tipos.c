#include <stdio.h>
#include <stdlib.h>
#include "tabla_tipos.h"

struct list_head *tt_crear_tabla()
{
    struct list_head *tt = list_new();
    if (tt == NULL)
        return NULL;
    for (u8 i = 0; i < 4; i++) {
        if (!tt_insertar_tipo(tt, i, NULL, (i < 2) ? i : 4, 0)) {
            tt_eliminar_tabla(tt);
        }
    }
    return tt;
}

void tt_eliminar_tabla(struct list_head **tt)
{
    if (*tt == NULL)
        return;
    struct tipo *tipo, *sig;
    if (!list_empty(*tt)) {
        list_for_each_entry_safe(tipo, sig, *tt, list)
        {
            list_del(&tipo->list);
            free(tipo);
        }
    }
    free(*tt);
    *tt = NULL;
}

struct tipo *tt_insertar_tipo(struct list_head *tt,
                              enum TT tipo,
                              struct tipo *base,
                              u16 tam,
                              u8 dim)
{
    if (tt == NULL)
        return NULL;
    struct tipo *nuevo = malloc(sizeof(struct tipo));
    if (nuevo == NULL)
        return NULL;
    nuevo->id =
        list_empty(tt) ? 0 : list_first_entry(tt, struct tipo, list)->id + 1;
    nuevo->tipo = tipo;
    nuevo->base = base;
    nuevo->dim = dim;
    nuevo->tam = dim > 0 ? dim * (base == NULL? 1 : base->tam) : tam;
    list_add(&nuevo->list, tt);
    return nuevo;
}

struct tipo *tt_buscar_id(struct list_head *tt, u16 id)
{
    if (tt == NULL || list_empty(tt))
        return NULL;
    struct tipo *tipo;
    list_for_each_entry(tipo, tt, list)
    {
        if (tipo->id == id) {
            return tipo;
        }
    }
    return NULL;
}

void tt_imprimir_tipo(struct tipo *tipo)
{
    if (tipo == NULL) {
        printf("Tipo nulo\n");
        return;
    }
    printf("id: %lu,\t tipo: %u,\t base:%lu,\t tam: %lu,\t dim:%d\n", tipo->id,
           tipo->tipo, tipo->base == NULL ? 0 : tipo->base->id, tipo->tam,
           tipo->dim);
}

void tt_imprimir_tabla(struct list_head *tt)
{
    struct tipo *tipo;
    printf("Tabla de tipos\n");
    if (tt == NULL || list_empty(tt)) {
        printf("Vacia\n");
        return;
    }
    list_for_each_entry_reverse(tipo, tt, list) { tt_imprimir_tipo(tipo); }
}
