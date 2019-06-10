#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include "intdef.h"
#include "list.h"
#include "tabla_tipos.h"

/**
 * TS - Tipos de variables de un simbolo
 * En nuestro lenguaje un simbolo puede ser una variable, funcion o parametro
 */
enum TS {
    TS_VAR,
    TS_FUN,
    TS_PARAM,
};

/**
 * simbolo - almacena informacion de un simbolo en la tabla de simbolos
 * @pos: el lugar que ocupa en la tabla, iniciando en 0
 * @id: nombre del simbolo
 * @tipo: apuntador a un tipo en la tabla de tipos
 * @tipo_var: tipo que es este simbolo
 * @dir: direccion de memoria en la que se almacena este tipo
 * @argv: tipo de los argumentos si el simbolo es una funcion / apuntador a
 *  enteros/indices de la tabla de tipos
 * @argc: numero de argumentos si el simbolo es una funcion
 * @list: apuntadores al siguiente elemento y al elemento anterior en la tabla
 */
struct simbolo {
    u16 pos;
    char *id;
    struct tipo *tipo;
    enum TS tipo_var;
    u16 dir;
    u8 *argv;
    u8 argc;
    struct list_head list;
};

/**
 * ts_insertar_simbolo - aloja memoria y añade un nuevo simbolo a
 *  una tabla de simbolos
 * @ts: tabla de simbolo para insertar
 * @return: el nuevo simbolo creado y añadido a la tabla de simbolos o NULL si
 *  la tabla es NULL o no se puede alojar memoria
 *
 * Ver simbolo para mas informacion sobre los parametros
 * Comportamiento indefinido si argv no es un apuntador valido
 */
struct simbolo *ts_insertar_simbolo(struct list_head *ts,
                                    char *id,
                                    struct tipo *tipo,
                                    enum TS tipo_var,
                                    u16 dir,
                                    u8 *argv,
                                    u8 argc);

/**
 * ts_buscar_id - busca un simbolo en la tabla de simbolos por su nombre
 * @ts: la tabla de simbolos en la cual buscar
 * @id: el nombre del simbolo a buscar
 * @return: simbolo encontrado o NULL si la busqueda fallo
 */
struct simbolo *ts_buscar_id(struct list_head *ts, const char *id);

/**
 * ts_buscar_pos - busca un simbolo en la tabla de simbolos por su posicion
 * @ts: la tabla de simbolos en la cual buscar
 * @pos: posicion en la tabla de simbolos
 * @return: simbolo encontrado o NULL si la busqueda fallo
 */
struct simbolo *ts_buscar_pos(struct list_head *ts, u16 pos);

/**
 * ts_crear_tabla - aloja memoria para una nueva tabla de simbolos vacia
 * @return: apuntador a la nueva tabla de simbolos
 */
struct list_head *ts_crear_tabla();

/**
 * ts_eliminar_tabla - elimina de memoria toda una tabla de simbolos
 * @ts: apuntador a la tabla a eliminar
 */
void ts_eliminar_tabla(struct list_head **ts);

/**
 * ts_imprimir_simbolo - imprime un simbolo a la consola
 * @sim: el simbolo a imprimir
 */
void ts_imprimir_simbolo(struct simbolo *sim);

/**
 * ts_imprimir_tabla - imprime una tabla de simbolos
 * @ts: la tabla a imprimir
 */
void ts_imprimir_tabla(struct list_head *ts);

#endif /* end of include guard: SYMBOL_TABLE_H */
