!* a = 20; *?
entero a, b, c, k, n;
funcion entero main() {
    a = 0;
    b = 1;
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
