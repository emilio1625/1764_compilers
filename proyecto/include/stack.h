#ifndef STACK_H
#define STACK_H

#include "list.h"

/* Implementacion de un stack de listas doblemente ligadas
 * La implementacion es en realidad una lista doblemente ligada de listas
 * doblemente ligadas
 */

/**
 * stack_crear - aloja memoria para un nuevo stack
 * @return: apuntador al nuevo stack
 */
struct list_head *stack_crear();

/**
 * stack_eliminar - elimina de memoria un stack y todos los elementos de este
 * @stack: el stack a eliminar
 * @eliminar_elemento: una funcion para eliminar de memoria el elemento
 *  almacenado en el stack
 */
void stack_eliminar(struct list_head *stack,
                    void (*eliminar_elemento)(struct list_head *));

/**
 * stack_push - añade un elemento al stack
 * @stack: el stack al cual añadir el elemento
 * @head: el elemento a añadir
 */
void stack_push(struct list_head *stack, struct list_head *head);

/**
 * stack_pop - elimina el ultimo elemento añadido al stack
 * @stack: el stack del cual eliminar el elemento mas reciente
 * @return: el elemento eliminado o NULL si esta vacio
 */
struct list_head *stack_pop(struct list_head *stack);

/**
 * stack_peek - regresa el ultimo elemento añadido el stack, pero no lo elimina
 * @stack: el stack del cual obtener el elemento mas reciente
 * @return: el elemento mas recientemente añadido el stack o NULL si esta vacio
 */
struct list_head *stack_peek(struct list_head *stack);

/**
 * stack_imprimir - imprime todos el stack, el elemento mas reciente primero
 * @stack: stack a imprimir
 * @imprimir_elemento: una funcion para imprimir un elemento del stack
 */
void stack_imprimir(struct list_head *stack,
                    void (*imprimir_elemento)(struct list_head *));

#endif /* end of include guard: STACK_H */
