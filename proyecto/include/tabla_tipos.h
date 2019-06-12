#ifndef TYPE_TABLE_H
#define TYPE_TABLE_H

#include "intdef.h"
#include "list.h"

/**
 * TT - tipos de datos primitivos del lenguaje de programacion
 */
enum TT {
    TT_VOID,
    TT_CHAR,
    TT_INT,
    TT_FLOAT,
    TT_ARRAY,
    TT_STRUCT,
};

/**
 * tipo - almacena la informacion de un tipo de dato del lenguaje
 * @id: posicion en la tabla de tipos
 * @tipo: tipo primitivo
 * @base: tipos primitivo del que heredan los tipos compuestos
 * @tam: tamaño en bytes que ocupa el tipo en memoria
 * @dim: dimension del tipo compuesto
 * @tt: tabla de tipos asociada a un struct
 * @ts: tabla de simbolos asociada a un struct
 * @list: apuntadores al elemento anterior y siguiente en la tabla
 */
struct tipo {
    u16 id;
    enum TT tipo;
    struct tipo *base;
    u16 tam;
    u8 dim;
    struct list_head *tt, *ts;
    struct list_head list;
};

/**
 * tt_crear_tabla - aloja memoria y crea una nueva tabla de tipos con
 *  los tipos primitivos
 * @return: apuntador a la nueva tabla de tipos
 */
struct list_head *tt_crear_tabla();

/**
 * tt_eliminar_tabla - libera la memoria ocupada por una tabla de memoria
 * @tt - apuntador a la tabla a eliminar
 */
void tt_eliminar_tabla(struct list_head **tt);

/**
 * tt_insertar_tipo - aloja memoria y añade un nuevo tipo a la tabla de tipos
 * @tt - tabla de tipos a la cual añadir
 * @return - apuntador al nuevo tipo creado
 *
 * Ver tipo para mas informacion sobre los parametros
 */
struct tipo *tt_insertar_tipo(struct list_head *tt,
                              enum TT tipo,
                              struct tipo *base,
                              u16 tam,
                              u8 dim,
                              struct list_head *tts,
                              struct list_head *tss);

/**
 * tt_buscar_id - busca un tipo por su posicion en la tabla de tipos
 * @tt - la tabla de tipos en la cual buscar
 * @id - la posicion en la tabla de tipos a buscar
 */
struct tipo *tt_buscar_id(struct list_head *tt, u16 id);

/**
 * tt_imprimir_tipo - imprime los campos de un tipo a la consola
 * @tipo - el tipo a imprimir
 */
void tt_imprimir_tipo(struct tipo *tipo);

/**
 * ts_imprimir_tabla - imprime una tabla de tipos
 * @tt: la tabla a imprimir
 */
void tt_imprimir_tabla(struct list_head *tt);

/**
 * tipo_max - devuelve el tipo mas grande entre dos tipos
 * @t1: el tipo 1
 * @t2: el tipo 2
 * @return: el tipo mas grade de los dos
 */
enum TT tipo_max(enum TT t1, enum TT t2);

#endif /* end of include guard: TYPE_TABLE_H */
