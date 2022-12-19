#!/bin/sh

#OUTFILEPREFIX="tcell-bench-dishy-"
#
#for e in $(seq 0 15); do
#	steps=$(( 2**e ))
#	#printf "Running %8d\n" $steps
#	./dish_synch_tcell $steps > "$OUTFILEPREFIX-$steps.txt"
#done

OUTFILEPREFIX="gene-bench-dishy"

for e in $(seq 0 15); do
	steps=$(( 2**e ))
	#printf "Running %8d\n" $steps
	./dish_synch_gene_expr $steps > "$OUTFILEPREFIX-$steps.txt"
done


