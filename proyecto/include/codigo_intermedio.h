#ifndef CODIGO_INTERMEDIO_H
#define CODIGO_INTERMEDIO_H

#include "list.h"
#include "string.h"
#include "tools.h"

struct code {
    // la posicion en la lista que contiene el codigo
    u16 dir;
    char op[16], dir1[16], dir2[16], res[16];
    struct list_head list;
};

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

void code_eliminar(struct list_head **stack) {
    if (stack == NULL || *stack == NULL)
        return;
    struct code *code, *sig;
    if (!list_empty(*stack)) {
        list_for_each_entry_safe(code, sig, *stack, list){
            list_del(&code->list);
            free(code);
        }
    }
    free(*stack);
    *stack = NULL;
}

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

void backpatch(struct list_head *code, struct list_head *dirs, char label[16])
{
    if (dirs == NULL || list_empty(dirs) || code == NULL || list_empty(code) ||
        label == NULL)
        return;
    u32 i              = 0;
    struct code *tmp_c = list_entry(code->next, struct code, list);
    struct dir *tmp_d;
    // esperemos que funcione
    // TODO: arreglar esta cochinada
    list_for_each_entry_reverse(tmp_d, dirs, list)
    {
        if (i == tmp_d->dir) {
            strncpy(tmp_c->res, label, 16);
            continue;
        }
        list_for_each_entry_continue(tmp_c, code, list)
        {
            i++;
            if (i >= tmp_d->dir)
                break;
        }
    }
}

#endif /* end of include guard: CODIGO_INTERMEDIO_H */
