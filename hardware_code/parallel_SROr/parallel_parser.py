#!/usr/bin/python

from __future__ import print_function
import re
import sys

runningBooleanAve = {}

logictxt = open("logic_t.sv")
logic = logictxt.read()
logicStart = logic.find("/* Inputs (current state) */")+34
logicEnd = logic[logicStart:].find(";") + logicStart
logic = re.sub('\s','',logic[logicStart:logicEnd]).replace("_curr","").split(",")

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
		start1 = line.find("network_state1=")
		start2 = line.find("network_state2=")
		if start1 != -1 and start2 != -1:
			#The below code could ultimately be reduced to a for loop
			#which takes a cmd line arg for number of parallel sims
			#and calculates the binary for each. I chose the manual way for now
			#to do quick debugging on the .sv files
			binaryStart = start1+15
			binaryEnd = line[binaryStart:].find(",") + binaryStart
			binary1 = line[binaryStart:binaryEnd]
			
			binaryStart = start2+15
			binaryEnd = line[binaryStart:].find(",") + binaryStart
			binary2 = line[binaryStart:binaryEnd]
						
			iterationStart = line.find(keyword)+offset
			iterationEnd = line[iterationStart:].find(",") + iterationStart
			iteration = int(line[iterationStart:iterationEnd])
			
			if iteration>=1 and iteration<=runs:					
				for specificSignal,boolValue in enumerate(binary1):
					signals[specificSignal][iteration-1] += int(boolValue)
				for specificSignal,boolValue in enumerate(binary2):
					signals[specificSignal][iteration-1] += int(boolValue)				

for i,specificSignal in enumerate(signals):
	print(logic[i] + "\t", end='')
	for iteration in specificSignal:
		print(str(float(iteration)/seeds) +"\t", end='')
	print()





