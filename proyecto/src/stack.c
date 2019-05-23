#include <stdio.h>
#include "stack.h"

struct list_head *stack_crear()
{
    return list_new();
}

void stack_eliminar(struct list_head *stack,
                    void (*eliminar_elemento)(struct list_head *))
{
    if (stack == NULL || list_empty(stack))
        return;
    struct list_head *tmp, *sig;
    list_for_each_safe(tmp, sig, stack)
    {
        list_del(tmp);
        eliminar_elemento(tmp->entry);
        free(tmp);
    }
    free(stack);
    stack = NULL;
}

void stack_push(struct list_head *stack, struct list_head *head)
{
    if (head == NULL || stack == NULL)
        return;
    struct list_head *nueva = list_new();
    if (nueva == NULL)
        return;
    nueva->entry = head;
    list_add(nueva, stack);
}

struct list_head *stack_pop(struct list_head *stack)
{
    if (stack == NULL || list_empty(stack))
        return NULL;
    struct list_head *head = NULL, *tmp = list_pop(stack);
    if (tmp != NULL) {
        head = tmp->entry;
        free(tmp);
    }
    return head;
}

struct list_head *stack_peek(struct list_head *stack)
{
    if (stack == NULL || list_empty(stack))
        return NULL;
    struct list_head *head = NULL, *tmp = stack->next;
    if (tmp != NULL) {
        head = tmp->entry;
    }
    return head;
}

void stack_imprimir(struct list_head *stack,
                    void (*imprimir_elemento)(struct list_head *))
{
    if (stack == NULL || list_empty(stack)) {
        printf("Stack vacio\n");
        return;
    }
    int i = 0;
    struct list_head *tabla;
    list_for_each(tabla, stack)
    {
        printf("Tabla %d\n", i);
        imprimir_elemento(tabla->entry);
        i++;
    }
}
