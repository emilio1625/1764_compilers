/* Seccion de declaraciones */

%{

#include <stdio.h>
#include <string.h>
#include "list.h"
#include "tabla_tipos.h"
#include "codigo_intermedio.h"
#include "tools.h"

u16 dir_g, salida_ciclo_g;
u8 argc, dim;
struct tipo *tipo_g;
struct list_head *tt_stack, *ts_stack, *dir_stack, *code_list, *tt_actual,
    *ts_actual;

void init();
void destroy();
void yyerror(char *str);

extern int yylineno;
extern char* yytext;
%}

%union {
    struct {
        enum TT tipo;
        char sval[16];
        union {
            int i;
            float f;
        } val;
    } num;
    // apunta a alguna entrada en la tabla de tipos
    struct tipo *tipo;
    struct {
        enum TT tipo;
        // stack de direcciones siguientes
        struct list_head *next;
    } sent;
    struct {
        // Almacena si es cierta (1) o falsa (0)
        u8 val;
        // Almacena un stack de direcciones que almacena el numero de las
        // instrucciones que deben de incluir la etiqueta verdadra o falsa
        struct list_head * true, *false;
    } cond;
    struct {
        enum TT tipo;
        size_t tam;
        char dir[16];
    } expr;
    char str16[16];
}

/* Terminales */
    /* Palabras reservadas */
        /* Tipos de dato */
%token INT FLOAT CHAR VOID STRUCT
        /* Control de flujo */
%token IF ELSE WHILE DO FOR SWITCH CASE BREAK DEFAULT
        /* Funciones */
%token FUNCT RETURN
%token PRINT
    /* Constantes */
        /* Boleanas */
%token TRUE FALSE
        /* Caracter y cadenas */
%token CCHAR STR
        /* Numerica */
%token<num> NUMERO
    /* Otros */
%token DP PYC LI LD
/* Precedencia de operadores */
%left COMA
%right ASIG
%left OR
%left AND
%left EQ NEQ
%left LT LE GT GE
%left MAS MEN
%left MUL DIV MOD
%right NOT
%left PTO CI CD
%nonassoc PI PD
%nonassoc IF
%nonassoc ELSE
/* Identificadores */
%token<str16> ID

%type<tipo> tipo lista arreglo
%type<sent> sentencias sentencia
%type<expr> expresion parte_izquierda var_arreglo
%type<cond> condicion
%type<str16> relacional

%start programa

/* Esquema de traduccion */

%%

programa        : {
                    init();
                } declaraciones funciones {
                    code_imprimir(code_list);
                    // TODO: limpiar el desmadre
                    stack_imprimir(ts_stack, ts_imprimir_tabla);
                    stack_imprimir(tt_stack, tt_imprimir_tabla);
                    destroy();
                };

declaraciones   : tipo {
                    if ($1->tipo == TT_VOID)
                        yyerror("Vacio no es un tipo de declaracion valido");
                    else
                        tipo_g = $1;
                } lista PYC declaraciones
                | {
                    printf("fin declaraciones\n");
                    tt_imprimir_tabla(tt_actual);
                    ts_imprimir_tabla(ts_actual);
                };

tipo            : INT {$$ = tt_buscar_id(tt_actual, TT_INT);}
                | FLOAT {$$ = tt_buscar_id(tt_actual, TT_FLOAT);}
                | CHAR {$$ = tt_buscar_id(tt_actual, TT_CHAR);}
                | VOID {$$ = tt_buscar_id(tt_actual, TT_VOID);}
                | STRUCT {
                    ambito_crear(tt_stack, &tt_actual,
                                ts_stack, &ts_actual,
                                dir_stack, &dir_g);
                } LI declaraciones LD {
                    printf("Tablas de struct\n");
                    tt_imprimir_tabla(tt_actual);
                    ts_imprimir_tabla(ts_actual);

                    u16 dir_previa = dir_g;
                    struct list_head *tt_previa = stack_peek(tt_stack),
                                     *ts_previa = stack_peek(ts_stack);
                    ambito_restaurar(tt_stack, &tt_actual,
                                    ts_stack, &ts_actual,
                                    dir_stack, &dir_g, 0);

                    $$ = tt_insertar_tipo(tt_actual,
                                          TT_STRUCT,
                                          NULL,
                                          0,
                                          dir_previa,
                                          tt_previa,
                                          ts_previa);
                };

lista           : lista COMA ID arreglo {
                    if (ts_buscar_id(ts_actual, $3) == NULL) {
                        ts_insertar_simbolo(ts_actual,
                            $3, $4, TS_VAR, dir_g, 0,
                            $4->tipo == TT_STRUCT ? $4->ts : NULL);
                        dir_g += $4->tam;
                    } else {
                        yyerror("El simbolo ya existe");
                    }
                }
                | ID arreglo {
                    if (ts_buscar_id(ts_actual, $1) == NULL) {
                        ts_insertar_simbolo(ts_actual,
                            $1, $2, TS_VAR, dir_g, 0,
                            $2->tipo == TT_STRUCT ? $2->ts : NULL);
                        dir_g += $2->tam;
                    } else {
                        yyerror("El simbolo ya existe");
                    }
                };

arreglo         : CI NUMERO CD arreglo {
                    if ($2.tipo == TT_INT && $2.val.i > 0) {
                        $$ = tt_insertar_tipo(tt_actual,
                            TT_ARRAY, $4, 0, $2.val.i, NULL, NULL);
                    } else {
                        yyerror("El indice debe ser entero mayor a 0");
                    }
                }
                | {$$ = tipo_g;};

funciones       : FUNCT tipo ID PI {
                    ambito_crear(tt_stack, &tt_actual,
                                 ts_stack, &ts_actual,
                                 dir_stack, &dir_g);
                    argc = 0;
                } argumentos PD {
                    struct list_head *ts_global = stack_peek(ts_stack);
                    if (ts_buscar_id(ts_global, $3) == NULL) {
                        ts_insertar_simbolo(ts_global,
                            $3, $2, TS_FUN, dir_g, argc, ts_actual);
                        code_push(code_list, "label", "", "", $3);
                    }
                } LI declaraciones sentencias LD {
                    if ($11.tipo != $2->tipo) {
                        yyerror("Tipo de retorno incorrecto");
                    }
                    ambito_restaurar(tt_stack, &tt_actual,
                                     ts_stack, &ts_actual,
                                     dir_stack, &dir_g, 1);
                    /* u16 inst = code_push(code_list, "label", "", "", "__"); */
                    /* dir_push($11.next, inst); */
                    /* code_backpatch(code_list, $11.next, etiqueta_crear()); */
                    // instruccion separadora
                    code_push(code_list, "--", "--", "--", "--");
                } funciones
                | ;

argumentos      : lista_argumentos
                | ;

lista_argumentos: lista_argumentos COMA tipo ID {
                    if ($3->tipo == TT_VOID) {
                        yyerror("tipo de parametro no valido");
                    } else {
                        // indica el numero de dimensiones de un arreglo
                        dim = 0;
                    }
                } parte_arreglo {
                    struct tipo *tipo_anterior = $3;
                    if (dim) {
                        // no sabemos el tamaño de cada dimension, asi que
                        // suponemos el maximo (255)
                        for (int i = 0; i < dim; i++) {
                            tipo_anterior = tt_insertar_tipo(tt_actual,
                                TT_ARRAY, tipo_anterior, 0, 255, NULL, NULL);
                        }
                        // un arreglo mide solo la direccion del primer elemento
                    }
                    if (ts_buscar_id(ts_actual, $4) == NULL) {
                        ts_insertar_simbolo(ts_actual,
                            $4, tipo_anterior, TS_PARAM, dir_g, 0, NULL);
                        dir_g += tipo_anterior->tam;
                        argc += 1;
                    } else {
                        yyerror("El simbolo ya existe");
                    }
                }
                | tipo ID {dim = 0;} parte_arreglo {
                    struct tipo *tipo_anterior = $1;
                    if (dim) {
                        // no sabemos el tamaño de cada dimension, asi que
                        // suponemos el maximo (255)
                        for (int i = 0; i < dim; i++) {
                            tipo_anterior = tt_insertar_tipo(tt_actual,
                                TT_ARRAY, tipo_anterior, 0, 255, NULL, NULL);
                        }
                        // un arreglo mide solo la direccion del primer elemento
                    }
                    if (ts_buscar_id(ts_actual, $2) == NULL) {
                        ts_insertar_simbolo(ts_actual,
                            $2, tipo_anterior, TS_PARAM, dir_g, 0, NULL);
                        dir_g += tipo_anterior->tam;
                        argc += 1;
                    } else {
                        yyerror("El simbolo ya existe");
                    }
                };

parte_arreglo   : CI CD {dim += 1;} parte_arreglo
                | ;

sentencias      : sentencias {
                    u16 inst = code_push(code_list, "label", "", "", "__");
                    dir_push($1.next, inst);
                } sentencia {
                    code_backpatch(code_list, $1.next, etiqueta_crear());
                    $$ = $3;
                }
                | sentencia {$$ = $1;};

sentencia       : IF PI condicion PD {
                    u16 inst = code_push(code_list, "label", "", "", "__");
                    dir_push($3.true, inst);
                } sentencia ELSE {
                    u16 inst = code_push(code_list, "label", "", "", "__");
                    dir_push($3.false, inst);
                } sentencia {
                    code_backpatch(code_list, $3.true, etiqueta_crear());
                    code_backpatch(code_list, $3.false, etiqueta_crear());
                    $$.next = combinar($6.next, $9.next);
                }
                | WHILE PI {
                    u16 inst = code_push(code_list, "label", "", "", "__");
                    $<sent>$.next = list_new();
                    dir_push($<sent>$.next, inst);
                } condicion PD {
                    u16 inst = code_push(code_list, "label", "", "", "__");
                    dir_push($4.true, inst);
                }
                sentencia {
                    char *et = etiqueta_crear();
                    $7.next = combinar($7.next, $<sent>3.next);
                    code_backpatch(code_list, $7.next, et);
                    code_backpatch(code_list, $4.true, etiqueta_crear());
                    code_push(code_list, "goto", "", "", et);
                    $$.next = $4.false;
                    if (salida_ciclo_g) {
                        dir_push($$.next, salida_ciclo_g);
                        salida_ciclo_g = 0;
                    }
                }
                | DO {
                    u16 inst = code_push(code_list, "label", "", "", "__");
                    $<sent>$.next = list_new();
                    dir_push($<sent>$.next, inst);
                } sentencia WHILE PI {
                    u16 inst = code_push(code_list, "label", "", "", "__");
                    dir_push($3.next, inst);
                } condicion PD PYC {
                    $7.true = combinar($<sent>2.next, $7.true);
                    code_backpatch(code_list, $7.true, etiqueta_crear());
                    code_backpatch(code_list, $3.next, etiqueta_crear());
                    $$.next = $7.false;
                    if (salida_ciclo_g) {
                        dir_push($$.next, salida_ciclo_g);
                        salida_ciclo_g = 0;
                    }
                }
                | FOR PI sentencia {
                    u16 inst = code_push(code_list, "label", "", "", "__");
                    dir_push($3.next, inst);
                } condicion PYC {
                    u16 inst = code_push(code_list, "label", "", "", "__");
                    $<sent>$.next = list_new();
                    dir_push($<sent>$.next, inst);
                } sentencia PD {
                    u16 inst = code_push(code_list, "goto", "", "", "__");
                    dir_push($8.next, inst);
                    inst = code_push(code_list, "label", "", "", "__");
                    dir_push($5.true, inst);
                } sentencia {
                    u16 inst = code_push(code_list, "goto", "", "", "__");
                    dir_push($<sent>7.next, inst);
                    $11.next = combinar($11.next, $<sent>7.next);
                    code_backpatch(code_list, $11.next, etiqueta_crear());
                    $3.next = combinar($3.next, $8.next);
                    code_backpatch(code_list, $3.next, etiqueta_crear());
                    code_backpatch(code_list, $5.true, etiqueta_crear());
                    $$.next = $5.false;
                    if (salida_ciclo_g) {
                        dir_push($$.next, salida_ciclo_g);
                        salida_ciclo_g = 0;
                    }
                }
                | SWITCH PI expresion PD LI casos predeterminado LD {}
                | BREAK PYC {
                    salida_ciclo_g = code_push(code_list, "goto", "", "", "__");
                }
                | LI sentencias LD {$$ = $2;}
                | parte_izquierda ASIG expresion PYC {
                    // TODO: Comprobar tipos
                    code_push(code_list, "=", $3.dir, "", $1.dir);
                    $$.next = list_new();
                }
                | RETURN expresion PYC {}
                | RETURN PYC {}
                | PRINT expresion PYC {}
                | expresion PYC {};

casos           : CASE NUMERO DP sentencia casos
                | ;

predeterminado  : DEFAULT DP sentencia
                | ;

parte_izquierda : ID {
                    struct simbolo *sim = ts_buscar_id(ts_actual, $1);
                    if (sim != NULL) {
                        $$.tipo = sim->tipo->id;
                        strncpy($$.dir, $1, 16);
                    } else {
                        yyerror("El simbolo no existe");
                    }
                }
                | var_arreglo {$$ = $1;}
                | ID PTO ID{
                    struct simbolo *sim1 = ts_buscar_id(ts_actual, $1), *sim2;
                    if (sim1 != NULL) {
                        if (sim1->tipo->tipo == TT_STRUCT) {
                            sim2 = ts_buscar_id(sim1->argv, $3);
                            if (sim2 != NULL) {
                                $$.tipo = sim2->tipo->id;
                                printf("\n\n%d\n\n", $$.tipo);
                                snprintf($$.dir, 16, "%s.%s", $1, $3);
                            } else {
                                yyerror("no existe el miembro");
                            }
                        } else {
                            yyerror("el simbolo no es una estructura");
                        }
                    } else {
                        yyerror("El simbolo no existe");
                    }
                };

var_arreglo     : ID CI expresion CD {
                    struct simbolo *sim = ts_buscar_id(ts_actual, $1);
                    if (sim != NULL) {
                        tipo_g = sim->tipo;
                        if (tipo_g->tipo == TT_ARRAY) {
                            if ($3.tipo == TT_INT) {
                                $$.tipo = tipo_g->base->id;
                                snprintf($$.dir, 16, "%s[%s]", $1, $3.dir);
                            } else {
                                yyerror("el indice debe ser entero");
                            }
                        } else {
                            yyerror("El simbolo no es un arreglo");
                        }
                    } else {
                        yyerror("El simbolo no existe");
                    }
                }
                | var_arreglo CI expresion CD {
                    tipo_g = tipo_g->base;
                    if (tipo_g != NULL) {
                        if (tipo_g->tipo == TT_ARRAY) {
                            if ($3.tipo == TT_INT) {
                                $$.tipo = tipo_g->id;
                                snprintf($$.dir, 16, "%s[%s]", $1.dir, $3.dir);
                            } else {
                                yyerror("el indice debe ser entero");
                            }
                        } else {
                            yyerror("El simbolo no es un arreglo");
                        }
                    } else {
                        yyerror("dimensiones del arreglo excedidas");
                    }
                };

expresion       : expresion MAS expresion {
                    char *dir1, *dir2;
                    // TODO: Revisar que los tipos a operar son compatibles
                    $$.tipo = tipo_max($1.tipo, $3.tipo);
                    if ($$.tipo) {
                        strncpy($$.dir, temporal_crear(), 16);
                        dir1 = tipo_ampliar(code_list, $1.dir, $1.tipo, $$.tipo);
                        dir2 = tipo_ampliar(code_list, $3.dir, $3.tipo, $$.tipo);
                        code_push(code_list, "+", dir1, dir2, $$.dir);
                    } else {
                        yyerror("Los tipos no son operables");
                    }
                }
                | expresion MEN expresion {
                    char *dir1, *dir2;
                    // TODO: Revisar que los tipos a operar son compatibles
                    $$.tipo = tipo_max($1.tipo, $3.tipo);
                    if ($$.tipo) {
                        strncpy($$.dir, temporal_crear(), 16);
                        dir1 = tipo_ampliar(code_list, $1.dir, $1.tipo, $$.tipo);
                        dir2 = tipo_ampliar(code_list, $3.dir, $3.tipo, $$.tipo);
                        code_push(code_list, "-", dir1, dir2, $$.dir);
                    } else {
                        yyerror("Los tipos no son operables");
                    }
                }
                | expresion MUL expresion {
                    char *dir1, *dir2;
                    // TODO: Revisar que los tipos a operar son compatibles
                    $$.tipo = tipo_max($1.tipo, $3.tipo);
                    if ($$.tipo) {
                        strncpy($$.dir, temporal_crear(), 16);
                        dir1 = tipo_ampliar(code_list, $1.dir, $1.tipo, $$.tipo);
                        dir2 = tipo_ampliar(code_list, $3.dir, $3.tipo, $$.tipo);
                        code_push(code_list, "*", dir1, dir2, $$.dir);
                    } else {
                        yyerror("Los tipos no son operables");
                    }
                }
                | expresion DIV expresion {
                    char *dir1, *dir2;
                    // TODO: Revisar que los tipos a operar son compatibles
                    $$.tipo = tipo_max($1.tipo, $3.tipo);
                    if ($$.tipo) {
                        strncpy($$.dir, temporal_crear(), 16);
                        dir1 = tipo_ampliar(code_list, $1.dir, $1.tipo, $$.tipo);
                        dir2 = tipo_ampliar(code_list, $3.dir, $3.tipo, $$.tipo);
                        code_push(code_list, "/", dir1, dir2, $$.dir);
                    } else {
                        yyerror("Los tipos no son operables");
                    }
                }
                | expresion MOD expresion {
                    char *dir1, *dir2;
                    // TODO: Revisar que los tipos a operar son compatibles
                    $$.tipo = tipo_max($1.tipo, $3.tipo);
                    if ($$.tipo) {
                        strncpy($$.dir, temporal_crear(), 16);
                        dir1 = tipo_ampliar(code_list, $1.dir, $1.tipo, $$.tipo);
                        dir2 = tipo_ampliar(code_list, $3.dir, $3.tipo, $$.tipo);
                        code_push(code_list, "mod", dir1, dir2, $$.dir);
                    } else {
                        yyerror("Los tipos no son operables");
                    }
                }
                | NUMERO {
                    $$.tipo = $1.tipo;
                    strncpy($$.dir, $1.sval, 16);
                }
                | CCHAR {}
                | STR {}
                | parte_izquierda {
                    $$ = $1;
                }
                | ID PI parametros PD {};

parametros      : lista_param
                | ;

lista_param     : lista_param COMA expresion
                | expresion;

condicion       : condicion OR {
                    u16 inst = code_push(code_list, "label", "", "", "__");
                    dir_push($1.false, inst);
                } condicion {
                    code_backpatch(code_list, $1.false, etiqueta_crear());
                    $$.true = combinar($1.true, $4.true);
                    $$.false = $4.false;
                }
                | condicion AND {
                    u16 inst = code_push(code_list, "label", "", "", "__");
                    dir_push($1.true, inst);
                } condicion {
                    code_backpatch(code_list, $1.true, etiqueta_crear());
                    $$.false = combinar($1.false, $4.false);
                    $$.true = $4.true;
                }
                | NOT condicion {
                    $$.true = $2.false;
                    $$.false = $2.true;
                }
                | PI condicion PD {$$ = $2;}
                | TRUE {
                    u16 inst = code_push(code_list, "goto", "", "", "__");
                    $$.true = list_new();
                    dir_push($$.true, inst);
                }
                | FALSE {
                    u16 inst = code_push(code_list, "goto", "", "", "__");
                    $$.false = list_new();
                    dir_push($$.false, inst);
                }
                | expresion relacional expresion {
                    char *temp = temporal_crear();
                    code_push(code_list, $2, $1.dir, $3.dir, temp);

                    u16 inst = code_push(code_list, "if", temp, "goto", "__");
                    $$.true = list_new();
                    dir_push($$.true, inst);

                    inst = code_push(code_list, "goto", "", "", "__");
                    $$.false = list_new();
                    dir_push($$.false, inst);
                };


relacional      : LT  {strncpy($$, "<" , 3);}
                | LE  {strncpy($$, "<=", 3);}
                | GT  {strncpy($$, ">" , 3);}
                | GE  {strncpy($$, ">=", 3);}
                | EQ  {strncpy($$, "==", 3);}
                | NEQ {strncpy($$, "!=", 3);};
%%

void yyerror(char * str) {
    printf("Error: En la linea %d, simbolo %s: %s\n", yylineno, yytext, str);
}

void init()
{
    /* Creando el stack de tablas de tipos */
    tt_stack  = stack_crear();
    tt_actual = tt_crear_tabla();
    /* Creando el stack de tablas de simbolos */
    ts_stack  = stack_crear();
    ts_actual = ts_crear_tabla();
    /* Creando el stack de direcciones */
    dir_stack = list_new();
    /* Creando la lista de codigo */
    code_list = list_new();

    if (!tt_stack || !ts_stack || !dir_stack || !code_list || !tt_actual ||
        !ts_actual) {
        printf("Error creando las estructuras de datos\n");
        exit(-1);
    }

    printf("Estructuras de datos inicializadas\n");

    stack_imprimir(tt_stack, tt_imprimir_tabla);
    stack_imprimir(ts_stack, ts_imprimir_tabla);
}

void destroy()
{
    stack_eliminar(&tt_stack, tt_eliminar_tabla);
    stack_eliminar(&ts_stack, ts_eliminar_tabla);
    dir_eliminar(&dir_stack);
    code_eliminar(&code_list);
}
