This is a JAVA program to do simulation on biological models. The original program is written by Yu-Hsin Kuo, and I want to thank Howard fot his contribution to the formatting for model checker. If you are going to use this simulator, please cite the paper:

Khaled Sayed, Yu-Hsin Kuo, Anuva Kulkarni, and Natasa Miskov-Zivanov, "DiSH simulator: Capturing dynamics of cellular signaling with heterogeneous knowledge," in 2017 Winter Simulation Conference (WSC), 2017, pp. 896-907.

## A. Installation:

under src/: javac *.java

## B. Usage: 

under src/: 
java Simulator [input file] [type: ra|ca] [runs] [cycle] [output file] [isRank] [probability version] [option: output mode]

Examples:

~~~shell
java Simulator model.txt ra 100 20 out.txt yes 0 1

java Simulator model.txt ra 100 20 out.txt no 1

java Simulator model.txt ca 100 20 out.txt yes 0 2

java Simulator model.txt ca 100 20 out.txt yes 0 

java Simulator model.txt ca 100 20 out.txt no 0 
~~~

***Some rules about the usage***
(1) isRank: can only take on two values: yes and no (case insensitive) and only supports ca mode

(2) probability version: can only take on three values as of now: 0, 1, and 2 (will explain this later, should discuss with Natasa about mode 2)
    ***If the value is nonzero then the isRank MUST set to no, and the type MUST set to ra***

(3) Output mode specifies the format of the output trace file. 1 is the standard output mode, 2 is the output mode for model checker, and 3 is frequency-only version

## C. Guidlines of the format of the input file:
(1) Initialization of the elements goes first then followed by a list of rules. (Should be separated by the keyword: "Rules:")

format:
    v1 = v1InitialState
    .
    .
    vx = vxInitialState
    Rules:
    v1 = v2*v3+!v4;
    .
    .
    .
    v4 = v2*v4+!v7;

(2) The initial value of the elements can take on three values: true, false, random (case insensitive)

(3) For each rule, there should be a semicolon at the end but before the probability if there is one.

## D. Examples of various input formats:

### 1. Rules with rank:
There is another mode of operation available in only ca (current async), which allows one to specify rankings (all non-negative integers) of the Rules. 

NOTE: ALL rules must have the rankings if this mode is to be used; undefined behavior otherwise. (***haven’t handled this***)

Rules placed within the smallest rank are applied with the ca algorithm first, then the next smallest rank, etc.
This enables the isolation of certain blocks of rules that you want to run in a specific but random order. 

format:

	v1 = v1InitialState
	.
	.
	vx = vxInitialState
	Rules:
	0: v1 = v2*v3+!v4;	//rank 0
	1: v1 = !(v9*v3+v4);	//rank 1
	3: v1 = v2*v4;		//rank 3
	0: v1 = v6+v4;		//rank 0
	.
	.
	.
	2: v4 = v2*v4+!v7;	//rank 2


In this example, rules from rank 0 are performed using the current async algorithm, before moving on to select rules from rank 1, then rank 2, and finally rank 3.
This additional feature is only performed if it detects a ranking within the input file. If no rankings are detected, normal execution resumes. 

### 2. Grouped rules

Both modes (ca and ra) also support the addition of ruleblocks, which allows one to specify that this block of rules are synchronously executed.
Thus, if one should want to execute all the rules synchronously, one will opt to place all rules in one block.
Alternatively, specifying a wildcard character (*) at the end of the rank number, but before the colon will allow the block of rules to be asynchronously executed, according to the natural ordering specified in the inputs.

format:

	v1 = v1InitialState
	.
	.
	vx = vxInitialState
	Rules:
	//block 1
	*{
	v1 = v2*v3+!v4;
	v3 = v2*v3;
	}
	//block 2
	{
	v2 = !(v9*v3+v4);
	v3 = ...
	...
	}
	//unblocked
	v4 = v2*v4+!v7;

In this example, the probability of the selecting block 1 is 33%, block 2 is 33%, and the rule v4=... is 33%.
In other words, number of individual rules within each block do not increase the block probability.
As aforementioned, all the rules in the block are executed synchronously if the block is selected.
If no blocks are detected, "unblocked" execution resumes as per normal.

*: rank priorities are also supported in block mode. replacing "*" with "3:" for example, will cause the entire block to be of rank 3.
NOTE: similar rules apply for rank priorities.

### 3. Toggle
 
Both ca(current async) and ra(random async) also supports the toggle-round, which allows one to specify the round at which the state of a variable is toggled. 

NOTE: ensure that toggle-round>0

format:
	v1 = v1InitialState 2
	v2 = v2InitialState 
	v3 = v3InitialState 5
	v4 = v4InitialState 6
	v5 = v5InitialState 
	.
	vx = vxInitialState 2
	Rules:
	v1 = v2*v3+!v4;
	.
	.
	.
	v4 = v2*v4+!v7;

In this example, v1 and vx will toggle its state at round 2,
becoming True if it was False in round 1,
becoming False if it was True in round 1.
Even if these variables were unused in rules, one can still toggle the variable. 

### 4. Probabilities

Only ra supports probabilities function. The probability should go after the semicolon or “{“ if grouped rules are used.
There are two types of probabilities. In version 1 (implemented): each rule has some probability (rate) and we sample 
the rules based on the probability. In version 2 (haven't implemented): Same element might have multiple rules with different
probabilities and we choose one based on the probability.

NOTE: every rule must have probability 

format:

	v1 = v1InitialState
	.
	.
	vx = vxInitialState
	Rules:
	//block 1
	*{ 0.3
	v1 = v2*v3+!v4;
	v3 = v2*v3;
	}
	//block 2
	{ 0.5
	v2 = !(v9*v3+v4);
	v3 = ...
	...
	}
	//unblocked
	v4 = v2*v4+!v7; 0.2

In this example, the probability of the selecting block 1 is 0.3, block 2 is 0.5, and the rule v4=... is 0.2.
