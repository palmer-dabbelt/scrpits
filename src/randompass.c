#include <stdlib.h>
#include <stdio.h>
#include <time.h>

#ifndef PASSWORD_CHARS
#define PASSWORD_CHARS 16
#endif

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
    FILE *dev_random;
    unsigned char buffer[PASSWORD_CHARS];

    dev_random = fopen("/dev/random", "r");
    if (dev_random == NULL) {
        fprintf(stderr, "No /dev/random, aborting\n");
        abort();
    }

    if (fread(&buffer, sizeof(buffer), 1, dev_random) != 1) {
        fprintf(stderr, "Short read, aborting\n");
        abort();
    }

    for (i = 0; i < PASSWORD_CHARS; i++)
        printf("%c", int_to_char(buffer[i]));

    printf("\n");

    return 0;
}
