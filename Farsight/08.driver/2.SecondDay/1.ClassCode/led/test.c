#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>


void main()
{
    int fd;

    fd = open("hello",O_RDWR);
    if(fd<0)
    {
        perror("open fail\n");
    }
    sleep(3);

    close(fd);

}
