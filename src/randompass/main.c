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
    FILE *dev_random;

    dev_random = fopen("/dev/random", "r");
    if (dev_random == NULL)
    {
        fprintf(stderr, "No /dev/random, using time to seed\n");
        srand(time(NULL));
    }
    else
    {
        int seed;
	int readed;

        readed = fread(&seed, sizeof(seed), 1, dev_random);
        srand(seed);
        fclose(dev_random);
    }

    for (i = 0; i < 16; i++)
        printf("%c", int_to_char(rand()));

    printf("\n");

    return 0;
}
