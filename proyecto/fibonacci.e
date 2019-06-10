entero a, b, c;
!* a = 20; *?

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
    entero a, b, c, k;
    a = 0; b = 1;
    si (n < 2) {
        devolver n;
    } sino {
        desde (k = 0; k <= n; k = k + 1;) {
            c = b + a;
            a = b;
            b = c;
        }
        devolver a;
    }
}


funcion entero main() {
    entero n;
    imprimir "Sucesion de Fibonacci";
    mientras (n < 10) {
        !* imprimir fib_r(n); [o] í é *?
        imprimir fib_i(n);
    }
    devolver 0;
}
