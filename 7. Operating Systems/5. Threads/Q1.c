#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void *myturn(void *arg)
{
	while (1)
	{
		sleep(1);
		printf("My Turn from Child Thread\n");
	}
	return NULL;
}

void yourturn()
{
	for (int i = 0; i < 5; i++)
	{
		sleep(2);
		printf("Your Turn from Parent Thread\n");
	}
}

int main()
{
	pthread_t newthread;
	pthread_create(&newthread, NULL, myturn, NULL);
	yourturn();
	pthread_cancel(newthread);
	// pthread_join(newthread, NULL);
	printf("Parent: Child thread has been successfully canceled andjoined.\n");
	return 0;
}