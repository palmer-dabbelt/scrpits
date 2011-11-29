#include <unistd.h>
#include <stdio.h>

int main(int argc, char **argv)
{
    int ret;

    ret = system("make clean");
    if (ret != 0)
    {
        fprintf(stderr, "'make clean' failed\n");
        return ret;
    }

    ret = system("make");
    if (ret != 0)
    {
        fprintf(stderr, "'make' failed\n");
        return ret;
    }

    return 0;
}
