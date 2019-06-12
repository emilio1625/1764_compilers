#ifndef TOOLS_H
#define TOOLS_H

#include <stdio.h>
#include "list.h"
#include "stack.h"
#include "tabla_simbolos.h"
#include "tabla_tipos.h"


///////////////////////////////////////////////////////////////////////////////
//                         Stack de direciones                               //
///////////////////////////////////////////////////////////////////////////////
/**
 * dir - elemento de una lista de direcciones
 * @dir - una direccion, entero sin signo
 * @lsit - apuntadores al elemento siguiente y anterior
 *
 * Esta estructura es usada para direcciones de memoria, la posicion de una
 * instruccion de 3 direcciones, o cualquier lugar donde sea util una
 * lista de enteros.
 */
struct dir {
    u16 dir;
    struct list_head list;
};

void dir_push(struct list_head *head, u16 dir)
{
    if (head == NULL)
        return;
    struct dir *new = malloc(sizeof(struct dir));
    if (new == NULL)
        return;
    new->dir = dir;
    list_add(&new->list, head);
}

/**
 * dir_pop - elimina la ultima direccion de una lista
 * @head: la lista de la cual eliminar la ultima direccion
 * @return: la direccion eliminada
 */
u16 dir_pop(struct list_head *head)
{
    if (head == NULL || list_empty(head))
        return -1;
    struct dir *entry = list_first_entry(head, struct dir, list);
    list_del(&entry->list);
    u16 dir = entry->dir;
    free(entry);
    return dir;
}

/**
 * dir_peek - obtiene la ultima direccion agregada a una lista
 * @head: la lista de la cual obtener la ultima direccion
 * @return: la ultima direccion agregada a la lista
 */
u16 dir_peek(struct list_head *head)
{
    if (head == NULL || list_empty(head))
        return -1;
    struct dir *entry = list_first_entry(head, struct dir, list);
    u16 dir           = entry->dir;
    return dir;
}

/**
 * dir_eliminar - elimina un lista de direcciones
 * @head: la lista a eliminar
 */
void dir_eliminar(struct list_head **head)
{
    if (head == NULL || *head == NULL)
        return;
    struct dir *dir, *sig;
    if (!list_empty(*head)) {
        list_for_each_entry_safe(dir, sig, *head, list)
        {
            list_del(&dir->list);
            free(dir);
        }
    }
    free(*head);
    *head = NULL;
}

/**
 * combinar - combina de forma segura 2 listas, deja la lista vaciada en un
 * estado valido
 * @head1: un apuntador al inicio de una lista
 * @head2: un apuntador a otra lista
 * @return: apuntador a alguna de las dos lista, la cual contiene la lista unida
 *
 * Despues de realizar la union de las lista, la lista vaciada es reiniciada
 * para evitar acceder a los elementos que antes contenia a partir de ella,
 * ejecutar list_empty sobre ella devuelve true
 */
struct list_head *combinar(struct list_head *head1, struct list_head *head2)
{
    if (head1 == head2) {
        return head1;
    } else if (head1 == NULL || list_empty(head1)) {
        return head2;
    } else if (head2 == NULL || list_empty(head2)) {
        return head1;
    } else {
        list_splice_init(head2, head1);
    }
    return head1;
}

void _dir_imprimir(struct list_head *head) {
    struct dir *dir;
    list_for_each_entry(dir, head, list) {
        printf("%lu\n", dir->dir);
    }
}

///////////////////////////////////////////////////////////////////////////////
//                                 Ambito                                    //
///////////////////////////////////////////////////////////////////////////////
/**
 * ambito_crear - Crea nuevas tablas de simbolos y tipos y una reinicia la
 * direccion de memoria actual y almacena las anteriores en un stack
 * @tt_s: el stack de tablas donde guardar la tabla de tipos anterior
 * @tt: el apuntador a la tabla de tipos actual, para actualizarlo
 * @ts_s: el stack de tablas donde guardar la tabla de simbolos anterior
 * @ts: el apuntador a la tabla de simbolos actual para actualizarlo
 * @dir_s: el stack de direcciones donde guardar la direccion anterior
 * @dir: el apuntador a la direccion actual para actualizarlo
 */
void ambito_crear(struct list_head *tt_s,
                  struct list_head **tt,
                  struct list_head *ts_s,
                  struct list_head **ts,
                  struct list_head *dir_s,
                  u16 *dir)
{
    /* Creando una nueva tabla de tipos */
    stack_push(tt_s, *tt);
    *tt = tt_crear_tabla();
    if (*tt == NULL) {
        printf("Error creando la tabla de tipos\n");
    }

    /* Creando una nueva tabla de simbolos */
    stack_push(ts_s, *ts);
    *ts = ts_crear_tabla();
    if (*ts == NULL) {
        printf("Error creando la tabla de simbolos\n");
    }

    /* Guadando la direccion anterior y regresando a 0 la actual */
    dir_push(dir_s, *dir);
    *dir = 0;
}

/**
 * ambito_restaurar - Recupera las ultimas tablas de simbolos y tipos y la
 * direccion de memoria de un stack y opcionalmente elimina las actuales
 * @tt_s: el stack de tablas de donde restaurar la tabla de tipos anterior
 * @tt: el apuntador a la tabla de tipos actual, para actualizarlo
 * @ts_s: el stack de tablas de donde restaurar la tabla de simbolos anterior
 * @ts: el apuntador a la tabla de simbolos actual para actualizarlo
 * @dir_s: el stack de direcciones de donde restaurar la direccion anterior
 * @dir: el apuntador a la direccion actual para actualizarlo
 */
void ambito_restaurar(struct list_head *tt_s,
                      struct list_head **tt,
                      struct list_head *ts_s,
                      struct list_head **ts,
                      struct list_head *dir_s,
                      u16 *dir,
                      int eliminar)
{
    if (eliminar)
        tt_eliminar_tabla(tt);
    *tt = stack_pop(tt_s);

    if (eliminar)
        ts_eliminar_tabla(ts);
    *ts = stack_pop(ts_s);

    *dir = dir_pop(dir_s);
}

#endif /* end of include guard: TOOLS_H */
