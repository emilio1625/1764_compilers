#ifndef ETIQUETA_H
#define ETIQUETA_H

#include "list.h"

#ifndef TAM_ETIQUETA
#    define TAM_ETIQUETA 16
#endif

struct etiqueta {
    char *str;
    struct list_head list;
};

char *et_nueva();

void et_insertar(struct list_head *stack, char *str);

struct list_head *et_crear_stack();

void et_eliminar_stack(struct list_head *stack);

void et_imprimir_etiqueta(struct etiqueta *et);

void et_imprimir_stack(struct list_head *stack);

#endif /* end of include guard: ETIQUETA_H */
