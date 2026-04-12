#include <stdio.h>
#include <dlfcn.h>

int main() {
    char op[6];
    int num1, num2;

    while(scanf("%5s %d %d", op, &num1, &num2) == 3) {
        //keep taking input until invalid

        char libname[50];
        snprintf(libname, sizeof(libname), "./lib%s.so", op);
        //libname now has ./libop.so

        void *handle = dlopen(libname, RTLD_LAZY);
        //load the shared library

        if(handle == NULL) {
            continue;
        }

        typedef int (*operationFunction)(int, int);

        operationFunction func = dlsym(libname, op);

        if(func == NULL) {
            dlclose(libname);
            continue;
        }

        int result = func(num1, num2);
        printf("%d\n", result);

        dlclose(libname);
    }

    return 0;
}