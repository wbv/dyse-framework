

DISHFLAGS = -std=c11 -O2 -march=native -mtune=native -Wall -Werror -pedantic

all: dish_synch_gene_expr dish_synch_tcell

dish_synch_gene_expr: dish.c
	$(CC) $(DISHFLAGS) $(CFLAGS) -DDISH_GENE $(CPPFLAGS) $(LFLAGS) $< -o $@

dish_synch_tcell: dish.c
	$(CC) $(DISHFLAGS) $(CFLAGS) -DDISH_TCELL $(CPPFLAGS) $(LFLAGS) $< -o $@

clean:
	$(RM) -vf dish_synch_gene_expr dish_synch_tcell

.PHONY: clean all
