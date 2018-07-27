//Synchronous

`define INITIAL_NETWORK_STATE 61'h06123456789abc3e 	//Initial Values of State Variables
`define STATE 61				  	//Number of Rules in System
`define LOG_RULES 6					//Ceiling Log of Number of Rules
`define PADDING 24					//Number of bits need such that `RULES + PADDING = Next Power of 2
`define NEAR_POW_2 64					//The nearest power of 2 > `RULES
`define INHIBITOR `LOG_RULES'b0				//Inhibitor Mask Value
`define ITERATION_NUMBER 50				//Number of Rounds
`define NUM_SEEDS 200					//Number of different seeds that will be used to run this model
`define SYNC_FILE "sync_I3.txt"
