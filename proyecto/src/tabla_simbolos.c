#include <stdio.h>
#include <string.h>

#include "tabla_simbolos.h"

struct simbolo *ts_insertar_simbolo(struct list_head *ts,
                                    char *id,
                                    struct tipo *tipo,
                                    enum ST tipo_var,
                                    u16 dir,
                                    u8 *argv,
                                    u8 argc)
{
    if (ts == NULL)
        return NULL;
    struct simbolo *nuevo = malloc(sizeof(struct simbolo));
    if (nuevo == NULL)
        return NULL;
    nuevo->pos =
        list_empty(ts) ? 0 : list_last_entry(ts, struct simbolo, list)->pos + 1;
    nuevo->id = strndup(id, 32);
    nuevo->tipo = tipo;
    nuevo->tipo_var = tipo_var;
    nuevo->dir = dir;
    nuevo->argc = argc;
    nuevo->argv = malloc(argc * sizeof(u8));
    memcpy(nuevo->argv, argv, argc * sizeof(u8));
    list_add(&nuevo->list, ts);
    return nuevo;
}

struct simbolo *ts_buscar_id(struct list_head *ts, const char *id)
{
    struct simbolo *res = NULL;
    if (ts == NULL || list_empty(ts))
        return NULL;
    list_for_each_entry(res, ts, list)
    {
        if (strncmp(id, res->id, 32) == 0) {
            return res;
        }
    }
    return NULL;
}

struct list_head *ts_crear_tabla()
{
    return list_new();
}

void ts_eliminar_tabla(struct list_head *ts)
{
    if (ts == NULL)
        return;
    struct simbolo *tmp, *sig;
    if (!list_empty(ts)) {
        list_for_each_entry_safe(tmp, sig, ts, list)
        {
            list_del(&tmp->list);
            free(tmp->id);
            free(tmp->argv);
            free(tmp);
        }
    }
    free(ts);
    ts = NULL;
}

void ts_imprimir_simbolo(struct simbolo *sim)
{
    if (sim == NULL) {
        printf("Simbolo nulo\n");
        return;
    }
    printf(
        "pos: %lu,\t id: %s,\t tipo: %lu,\t tipoVar: %u\t, dir:%lx,\t "
        "argc:%u\n",
        sim->pos, sim->id, sim->tipo->id, sim->tipo_var, sim->dir, sim->argc);
}

void ts_imprimir_tabla(struct list_head *ts)
{
    struct simbolo *sim;
    printf("Tabla de Simbolos\n");
    if (ts == NULL || list_empty(ts)) {
        printf("Vacia\n");
        return;
    }
    list_for_each_entry_reverse(sim, ts, list) { ts_imprimir_simbolo(sim); }
}
