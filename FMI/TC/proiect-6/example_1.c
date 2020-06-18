#include <stdio.h>
#ifdef \
    __LOCAL__
    #define LOCAL 1
#else
    #define LOCAL 0
#endif

int main() {
    int a = 1337; // 1337
    long int b = 0b1100110; // 102
    unsigned int c = 0xAaFf; // 437750
    int d = 01337; // 735
    printf("%d\n", LOCAL); // depends on the compile option
    printf("%d\n", (int)(a + b + c + d));

    int x;
    x = ~ (!5);
    printf("x = %d\n", x);
    
    float pi = 3.141592;
    double sqrt_2 = 1.4142; 
    printf("%.3f\n", /* sa nu inmultim si cu e? */ pi * sqrt_2);

    printf("salutare asta e un string \
pe mai multe linii \
huhuhuh \" \n \' \" caractere speciale      \t      \' \"");
    printf("\n~~~~\n\n");
    int arr[] = { 
        #include "data.txt"
    };
    printf("uite cum se pune un comentariu: /* comentariu */ ");

/*
    // cometariu micut si ascuns
    for (int i = 0; i < 10; i += 1) {
        printf("\t%d\n", i);
    }  
*/

    // cometariu micut si ascuns
    for (unsigned int i = 0; i < sizeof arr  / sizeof(int); i += 1) {
        printf("\t%d\n", arr[i]);
    }
}
