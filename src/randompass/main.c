#include <stdlib.h>
#include <stdio.h>
#include <time.h>

static char int_to_char(int i)
{
    i = i % 62;

    if (i < 26)
        return 'a' + i;
    if (i < 52)
        return 'A' + i - 26;
    if (i < 62)
        return '0' + i - 52;
}

int main(int argc, char **argv)
{
    int i;

    srand(time(NULL));

    for (i = 0; i < 16; i++)
        printf("%c", int_to_char(rand()));

    printf("\n");

    return 0;
}
