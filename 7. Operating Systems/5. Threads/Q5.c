#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void *square(void *arg)
{
	int *num = (int *) arg;
	*num = (*num) * (*num);
	return NULL;
}

int main(int argc, char *argv[])
{
	if (argc != 2)
	{
		perror("Incorrect input brotherrr!");
		exit(EXIT_FAILURE);
	}

	int num = atoi(argv[1]);

	printf("Given number: %d\n", num);

	pthread_t thread;

	pthread_create(&thread, NULL, square, &num);
	pthread_join(thread, NULL);

	printf("The square of the number is: %d\n", num);

	return 0;
}