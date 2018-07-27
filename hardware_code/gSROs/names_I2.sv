//T-Cell Model

`define INITIAL_NETWORK_STATE 61'h0a00000040010030 	//Initial Values of State Variables
`define RULES 61				  	//Number of Rules in System
`define STATE 38					//Number of Groups of Rules in System
`define INITIAL_SEED 64'h1234abcdef987563		//Initial RNG Seed
`define LOG_RULES 6					//Ceiling Log of Number of Rules
`define LOG_RULES_2 12					//Ceiling Log of Number of Rules * 2
`define PADDING 26					//Number of bits need such that `STATE + PADDING = Next Power of 2
`define NEAR_POW_2 64					//The nearest power of 2 > `STATE
`define GROUP_RULES 107					//Number of rng outputs assigned to a rule
`define GROUP_BITS 12					//Number of bits to be taken from LFSR
`define INHIBITOR `LOG_RULES'b0				//Inhibitor Mask Value
`define ROUND_NUMBER 30					//Number of Rounds
`define NUM_SEEDS 1000					//Number of different seeds that will be used to run this model
`define LOG_ITER	11				//Log number of Iterations
