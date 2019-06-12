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
 * @return: el numero de instruccion de la instruccion agregada
 *
 * Ver struct code para mas informacion sobre los parametros
 */
u16 code_push(struct list_head *head,
              char op[16],
              char dir1[16],
              char dir2[16],
              char res[16])
{
    if (head == NULL)
        return -1;
    struct code *new = malloc(sizeof(struct code));
    if (new == NULL)
        return -1;
    strncpy(new->op, op, 16);
    strncpy(new->dir1, dir1, 16);
    strncpy(new->dir2, dir2, 16);
    strncpy(new->res, res, 16);
    new->dir = list_empty(head)
                   ? 0
                   : list_first_entry(head, struct code, list)->dir + 1;
    list_add(&new->list, head);
    return new->dir;
}

/**
 * code_eliminar - elimina los elementos de una lista de codigo de 3 direcciones
 * @head: la lista de codigo
 */
void code_eliminar(struct list_head **head)
{
    if (head == NULL || *head == NULL)
        return;
    struct code *code, *sig;
    if (!list_empty(*head)) {
        list_for_each_entry_safe(code, sig, *head, list)
        {
            list_del(&code->list);
            free(code);
        }
    }
    free(*head);
    *head = NULL;
}

void _code_imprimir(struct code *code)
{
    if (code == NULL) {
        printf("--\n");
        return;
    } else if (strncmp(code->op, "label", 6) == 0) {
        printf("%04lu\t%s:\n", code->dir, code->res);
    } else if (strncmp(code->op, "goto", 5) == 0) {
        printf("%04lu\t\t%s %s\n", code->dir, code->op, code->res);
    } else if (strncmp(code->op, "if", 3) == 0) {
        printf("%04lu\t\t%s %s %s %s\n", code->dir, code->op, code->dir1,
               code->dir2, code->res);
    } else if (strncmp(code->op, "=", 2) == 0) {
        printf("%04lu\t\t%s %s %s %s\n", code->dir, code->res, code->op,
               code->dir1, code->dir2);
    } else {
        printf("%04lu\t\t%s = %s %s %s\n", code->dir, code->res, code->dir1,
               code->op, code->dir2);
    }
}

void code_imprimir(struct list_head *head)
{
    if (head == NULL || list_empty(head)) {
        printf("Codigo vacio\n");
        return;
    }
    struct code *code;
    list_for_each_entry_reverse(code, head, list) { _code_imprimir(code); }
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
void code_backpatch(struct list_head *head,
                    struct list_head *dirs,
                    char label[16])
{
    if (dirs == NULL || list_empty(dirs) || head == NULL || list_empty(head) ||
        label == NULL)
        return;
    struct code *code = list_entry(head, struct code, list);
    struct dir *dir;
    // esperemos que funcione
    // TODO: arreglar esta cochinada
    list_for_each_entry(dir, dirs, list)
    {
        list_for_each_entry_continue(code, head, list) {
            if (code->dir == dir->dir) {
                strncpy(code->res, label, 16);
            }
        }
    }
}

/**
 * etiqueta_crear - crea una nueva etiqueta aleatoria
 */
char *etiqueta_crear()
{
    char *str = malloc(16 * sizeof(char));
    static const char set[] =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

    sprintf(str, "label_");

    for (int i = 6; i < 15; ++i) {
        str[i] = set[rand() % (sizeof(set) - 1)];
    }

    str[15] = '\0';
    return str;
}

/**
 * temporal_crear - crea una nueva temporal aleatoria
 */
char *temporal_crear()
{
    char *str = malloc(16 * sizeof(char));
    static const char set[] =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

    sprintf(str, "temp_");

    for (int i = 5; i < 15; ++i) {
        str[i] = set[rand() % (sizeof(set) - 1)];
    }

    str[15] = '\0';
    return str;
}

/**
 * tipo_ampliar - aumenta el tamaño de una variable
 */
char *tipo_ampliar(struct list_head *head, char *dir, enum TT t1, enum TT t2)
{
    if (t1 == t2) {
        return dir;
    } else {
        char *temp = temporal_crear();
        t1         = tipo_max(t1, t2);
        if (t1 == TT_CHAR)
            code_push(head, "=", "(char)", dir, temp);
        else if (t1 == TT_INT)
            code_push(head, "=", "(int)", dir, temp);
        else if (t1 == TT_FLOAT)
            code_push(head, "=", "(float)", dir, temp);
        return temp;
    }
}

#endif /* end of include guard: CODIGO_INTERMEDIO_H */
