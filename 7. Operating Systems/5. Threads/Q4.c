#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define NUM_THREADS 5

void *perform_task(void *arg)
{
	int id = *((int *) arg);
	// I get a warning if I use %d instead of %lu
	printf("Thread %d: Thread ID: %lu\n", id, (unsigned long) pthread_self());
	sleep(1);
	free(arg); // Clean up the memory we allocated in main
	pthread_exit(NULL);
}

int main()
{
	pthread_t workers[NUM_THREADS]; // array of thread IDs

	for (int i = 0; i < NUM_THREADS; i++)
	{
		// We create a unique piece of memory for each thread's ID
		int *id = malloc(sizeof(int));
		*id = i;
		pthread_create(&workers[i], NULL, perform_task, id);
	}
	for (int i = 0; i < NUM_THREADS; i++)
	{
		pthread_join(workers[i], NULL);
	}
	printf("Main: All threads are done. Program exiting.\n");
	return 0;
}