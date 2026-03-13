#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void *myturn(void *arg)
{
	for (int i = 0; i < 10; i++)
	{
		sleep(1);
		printf("My Turn from Child Thread %d\n", i + 1);
	}
	return NULL;
}

void yourturn()
{
	for (int i = 0; i < 3; i++)
	{
		sleep(2);
		printf("Your Turn from Parent Thread %d\n", i + 1);
	}
}

int main()
{
	pthread_t newthread;
	pthread_create(&newthread, NULL, myturn, NULL);
	yourturn();
	pthread_join(newthread, NULL);
	printf("Parent: Child thread has been successfully canceled andjoined.\n");
	return 0;
}