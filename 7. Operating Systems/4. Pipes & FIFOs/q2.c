#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <unistd.h>

int main()
{
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
        
        dup2(fd[1], 1);
        
        close(fd[1]);
        execlp("ls", "ls", "-l", NULL);

        perror("Exec Failed!\n");
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
            close(fd[1]);
            dup2(fd[0], 0);
            
            int file = open("c_files.txt", O_WRONLY | O_TRUNC | O_CREAT, 0644);
            dup2(file, 1);
            
            close(fd[0]);

            execlp("grep", "grep", ".c", NULL);

            perror("Exec Failed!\n");
        }
        else
        {
            // parent process
            wait(NULL);
        }

        close(fd[1]);
        close(fd[0]);

        wait(NULL);
    }

    printf("Task completed. Check the c_files.txt\n");

    return 0;
}