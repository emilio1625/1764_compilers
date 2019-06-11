#ifndef CODIGO_INTERMEDIO_H
#define CODIGO_INTERMEDIO_H

#include "list.h"
#include "string.h"
#include "tools.h"

/**
 * code - almacena el numero y codigo de una instruccion de 3 direcciones
 * @op: la operacion que realiza la instruccion
 * @dir1: el primer operando de la instruccion
 * @dir2: segundo operando
 * @res: direccion para almacenar la instruccion
 */
struct code {
    // la posicion en la lista que contiene el codigo
    u16 dir;
    // operador, argumentos y resultados
    char op[16], dir1[16], dir2[16], res[16];
    // apuntadores al codigo siguiente y anterior
    struct list_head list;
};

/**
 * code_push - añade una nueva instruccion de 3 direcciones a una lista
 * @head: la lista a la cual añadir el codigo
 *
 * Ver struct code para mas informacion sobre los parametros
 */
struct code *code_push(struct list_head *head,
                       char op[16],
                       char dir1[16],
                       char dir2[16],
                       char res[16])
{
    if (head == NULL)
        return NULL;
    struct code *new = malloc(sizeof(struct code));
    if (new == NULL)
        return NULL;
    strncpy(new->op, op, 16);
    strncpy(new->dir1, dir1, 16);
    strncpy(new->dir2, dir2, 16);
    strncpy(new->res, res, 16);
    new->dir = list_empty(head)
                   ? 0
                   : list_first_entry(head, struct code, list)->dir + 1;
    list_add(&new->list, head);
    return new;
}

/**
 * code_eliminar - elimina los elementos de una lista de codigo de 3 direcciones
 * @head: la lista de codigo
 */
void code_eliminar(struct list_head **head) {
    if (head == NULL || *head == NULL)
        return;
    struct code *code, *sig;
    if (!list_empty(*head)) {
        list_for_each_entry_safe(code, sig, *head, list){
            list_del(&code->list);
            free(code);
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

/**
 * code_backpatch - Realiza la sustitucion de etiquetas faltantes en una lista
 * de codigo
 * @head: la lista de codigo
 * @dirs: la lista de los numeros de instruccion a sustituir
 * @label: la etiqueta que se sustituira
 *
 * Esta funcion asume fuertemente que la lista de direcciones esta ordenada
 * TODO: probar que en realidad funcione (en mi cabeza funcionaba xDDDD)
 */
void code_backpatch(struct list_head *head, struct list_head *dirs, char label[16])
{
    if (dirs == NULL || list_empty(dirs) || head == NULL || list_empty(head) ||
        label == NULL)
        return;
    u32 i              = 0;
    struct code *tmp_c = list_entry(head->next, struct code, list);
    struct dir *tmp_d;
    // esperemos que funcione
    // TODO: arreglar esta cochinada
    list_for_each_entry_reverse(tmp_d, dirs, list)
    {
        if (i == tmp_d->dir) {
            strncpy(tmp_c->res, label, 16);
            continue;
        }
        list_for_each_entry_continue(tmp_c, head, list)
        {
            i++;
            if (i >= tmp_d->dir)
                break;
        }
    }
}

#endif /* end of include guard: CODIGO_INTERMEDIO_H */
