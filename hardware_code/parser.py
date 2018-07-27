#!/usr/bin/python

from __future__ import print_function
import re
import sys

runningBooleanAve = {}

#Open logic_t and extract the names of the signals based on lexical landmarks
logictxt = open("logic_t.sv")
logic = logictxt.read()
logicStart = logic.find("/* Inputs (current state) */")+34
logicEnd = logic[logicStart:].find(";") + logicStart
logic = re.sub('\s','',logic[logicStart:logicEnd]).replace("_curr","").split(",")


#Define variables for parsing
numSignals = len(logic)
runs = int(sys.argv[3])
seeds = int(sys.argv[4])
signals = [[0 for x in range(runs)] for y in range(numSignals)]
prevBinary = ""		
prevIteration = 1
if sys.argv[2] == "round": 
	offset = 17 
	keyword = "iteration_number="
else: 
	offset = 13
	keyword = "round_number="

	
with open(sys.argv[1]) as rawtxt:
	for line in rawtxt:
		start = line.find("network_state=") #find the starting point of the line
		if start != -1:
			#extract the binary network state variable
			binaryStart = start+14
			binaryEnd = line[binaryStart:].find(",") + binaryStart
			binary = line[binaryStart:binaryEnd]
			
			#extract the iteration number
			iterationStart = line.find(keyword)+offset
			iterationEnd = line[iterationStart:].find(",") + iterationStart
			iteration = int(line[iterationStart:iterationEnd])
			
			#if valid iteration number...
			if iteration>=1 and iteration<=runs:
				#If step simulation and the iteration number has not changed since the previous network state,
				#compare binary to previous value. If not the same, subtract the previous value and replace it with the new one
				#The result is that, in the case where an iteration number has not changed but the network state has,
				#utilize the most recent network state data only
				if sys.argv[2] == "step" and iteration == prevIteration:		
					for specificSignal,prevBoolValue in enumerate(prevBinary):		
						signals[specificSignal][iteration-1] -= int(prevBoolValue)
						
				#Add the binary value for each signal to the running sum for each signal		
				for specificSignal,boolValue in enumerate(binary):
					signals[specificSignal][iteration-1] += int(boolValue)
				
				#Store the previous binary value for comparison in the step simulations
				prevIteration = iteration		
				prevBinary = str(binary)

for i,specificSignal in enumerate(signals):
	#Print the signal name
	print(logic[i] + "\t", end='')
	
	#Print the average signal value for each iteration number in a csv friendly fashion
	for iteration in specificSignal:
		print(str(float(iteration)/seeds) +"\t", end='')
	
	print()





