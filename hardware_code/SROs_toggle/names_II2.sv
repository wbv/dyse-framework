//T-Cell Model

`define INITIAL_NETWORK_STATE 61'h0600000040010030 	//Initial Values of State Variables
`define RULES 61				  	//Number of Rules in System
`define INITIAL_SEED 64'h1234abcdef987563		//Initial RNG Seed
`define LOG_RULES 6					//Ceiling Log of Number of Rules
`define LOG_RULES_2 12					//Ceiling Log of Number of Rules * 2
`define PADDING 3					//Number of bits need such that `RULES + PADDING = Next Power of 2
`define NEAR_POW_2 64					//The nearest power of 2 > `RULES
`define INHIBITOR `LOG_RULES'b0				//Inhibitor Mask Value
`define ROUND_NUMBER 30					//Number of Rounds
`define TOGGLE 10'd8					//Round in which the toggle occurs
`define TOGGLE_RULE 58					//Rule which should be toggled
`define NUM_SEEDS 1000					//Number of different seeds that will be used to run this model
