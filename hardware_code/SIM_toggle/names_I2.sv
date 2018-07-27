//Synchronous

`define INITIAL_NETWORK_STATE 61'hfffffffffffff 	//Initial Values of State Variables
`define STATE 61				  	//Number of Rules in System
`define LOG_RULES 6					//Ceiling Log of Number of Rules
`define PADDING 24					//Number of bits need such that `RULES + PADDING = Next Power of 2
`define NEAR_POW_2 64					//The nearest power of 2 > `RULES
`define INHIBITOR `LOG_RULES'b0				//Inhibitor Mask Value
`define ITERATION_NUMBER 50				//Number of Rounds
`define NUM_SEEDS 200					//Number of different seeds that will be used to run this model
`define TOGGLE_RULE 58					//Rule which should be toggled
`define TOGGLE 10'd7					//Iteration number before which the toggle occurs (so the toggle can occur on the intended iteration number)
`define SYNC_FILE "sync_I1.txt"
