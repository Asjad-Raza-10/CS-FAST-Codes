#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <unistd.h>

int main(int argc, char* argv[])
{
    if(argc == 1)
    {
        printf("Provide some input biraathar!\n");
        return 0;
    }

    int n = atoi(argv[1]);
    
    int fd[2];
    pipe(fd);

    pid_t pid1 = fork();

    if(pid1 < 0)
    {
        perror("First Fork Failed!");
        exit(EXIT_FAILURE);
    }
    else if(pid1 == 0)
    {
        // child process
        close(fd[0]);
        
        int start = 1, end = n/4 + 1, sum = 0;

        for(int i = start; i <= end; i++)
        {
            if(n % i == 0) // a factor
            {
                sum += i;
            }
        }

        write(fd[1], &sum, sizeof(int));
        close(fd[1]);
        return 0;
    }
    else
    {
        // parent process
        pid_t pid2 = fork();
                
        if(pid2 < 0)
        {
            perror("Second Fork Failed!");
            exit(EXIT_FAILURE);
        }
        else if(pid2 == 0)
        {
            // child process
            close(fd[0]);
            int start = n/4 + 2, end = n/2 + 1, sum = 0;

            for(int i = start; i <= end; i++)
            {
                if(n % i == 0) // a factor
                {
                    sum += i;
                }
            }

            write(fd[1], &sum, sizeof(int));
            close(fd[1]);

            return 0;
        }
        else
        {
            // parent process
            wait(NULL);   
        }

        wait(NULL);

        close(fd[1]);

        int i = 0;
        read(fd[0], &i, sizeof(int));
        int sum = i;
        read(fd[0], &i, sizeof(int));
        sum += i;
        
        close(fd[0]);

        if(n == sum)
        {
            printf("%d is a perfect number!\n", n);
        }
        else
        {
            printf("%d is NOT a perfect number :(\n", n);
        }
    }
    return 0;
}