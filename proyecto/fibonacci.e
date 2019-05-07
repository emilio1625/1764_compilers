funcion entero fib_r(entero n)
{
    si (n < 2) {
        devolver n;
    } sino {
        devolver fib_r(n - 1) + fib_r(n - 2);
    }
}

funcion entero fib_i(entero n)
{
    entero a = 0, b = 1, c;
    si (n < 2) {
        devolver n;
    } sino {
        desde (entero k = 0; k = n; k = k + 1) {
            c = b + a;
            a = b;
            b = c;
        }
        devolver a;
    }
}


entero main(nada) {
    entero n;
    imprimir("Sucesion de Fibonacci");
    mientras (n < 10) {
        !* imprimir(fib_r(n)); [o] í é *?
        imprimir (fib_i(n));
    }
    devolver 0;
}
