//T-Cell model

`define INITIAL_NETWORK_STATE 61'h0b00000040010030 	//Initial Values of State Variables
`define RULES 61				  	//Number of Rules in System
`define INITIAL_SEED 64'h1234abcdef987563		//Initial RNG Seed
`define LOG_RULES 6					//Ceiling Log of Number of Rules
`define LOG_RULES_2 12					//Ceiling Log of Number of Rules * 2
`define PADDING 3					//Number of bits need such that `RULES + PADDING = Next Power of 2
`define NEAR_POW_2 64					//The nearest power of 2 > `RULES
`define GROUP_RULES 4400581				//Number of rng outputs assigned to a rule
`define GROUP_BITS 28					//Number of bits to be taken from LFSR
`define INHIBITOR `LOG_RULES'b0				//Inhibitor Mask Value
`define ITERATION_NUMBER 2000				//Number of Iterations
`define LOG_ITER	11				//Log number of Iterations
`define NUM_SEEDS 200					//Number of different seeds that will be used to run this model
