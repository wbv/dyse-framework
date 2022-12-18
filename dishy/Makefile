

DISHFLAGS = -std=c11 -O2 -march=native -mtune=native -Wall -Werror -pedantic

all: dish_synch

dish_synch: dish.c
	$(CC) $(DISHFLAGS) $(CFLAGS) $(CPPFLAGS) $(LFLAGS) $< -o $@

clean:
	$(RM) -vf dish_synch

.PHONY: clean all
