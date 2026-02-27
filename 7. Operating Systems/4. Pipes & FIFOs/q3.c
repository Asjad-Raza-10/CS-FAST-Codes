#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>

int count_words(int file, int start, int end)
{
    lseek(file, start, SEEK_SET);

    int count = 0;
    int in_word = 0;
    char buffer;

    for (int i = start; i < end; i++)
    {
        read(file, &buffer, 1);

        if (buffer == ' ' || buffer == '\n' || buffer == '\t')
        {
            in_word = 0;
        }
        else
        {
            if (!in_word)
            {
                count++;
                in_word = 1;
            }
        }
    }

    return count;
}

int main(int argc, char* argv[])
{
    if (argc == 1)
    {
        printf("Provide a file path!\n");
        return 1;
    }

    int file = open(argv[1], O_RDONLY);
    if (file < 0)
    {
        perror("Failed to open file");
        return 1;
    }

    struct stat buf;
    int bytes_count = 0;
    if (fstat(file, &buf) != -1)
    {
        bytes_count = buf.st_size;
    }

    printf("Byte Count: %d\n", bytes_count);

    // Two named pipes, one per child
    mkfifo("pipe1", 0666);
    mkfifo("pipe2", 0666);

    pid_t pid1 = fork();

    if (pid1 < 0)
    {
        perror("First fork failed");
        exit(EXIT_FAILURE);
    }
    else if (pid1 == 0)
    {
        int count = count_words(file, 0, bytes_count / 2);

        int fd = open("pipe1", O_WRONLY);
        write(fd, &count, sizeof(int));
        close(fd);
        close(file);
        return 0;
    }
    else
    {
        // parent process 

        pid_t pid2 = fork();

        if (pid2 < 0)
        {
            perror("Second fork failed");
            exit(EXIT_FAILURE);
        }
        else if (pid2 == 0)
        {
            int count = count_words(file, bytes_count / 2, bytes_count);

            int fd = open("pipe2", O_WRONLY);
            write(fd, &count, sizeof(int));
            close(fd);
            close(file);
            return 0;
        }
        else
        {
            int count1 = 0, count2 = 0;

            int fd1 = open("pipe1", O_RDONLY);
            read(fd1, &count1, sizeof(int));
            close(fd1);

            int fd2 = open("pipe2", O_RDONLY);
            read(fd2, &count2, sizeof(int));
            close(fd2);

            wait(NULL);
            wait(NULL);

            close(file);
            unlink("pipe1");
            unlink("pipe2");

            printf("Number of words in the file: %d\n", count1 + count2);
        }
    }

    


    return 0;
}