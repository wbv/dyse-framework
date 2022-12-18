#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>


typedef uint_fast8_t state_t;
#define NET_SIZE (61)

// T-cell regulatory network update functions for each element.
// (i'm so sorry)
void update(state_t* net) {
	// fill net_next with the computed next-states of net
	state_t net_next[NET_SIZE];
	net_next[0]  = (net[36] && net[30]) && ! (net[1]);
	net_next[1]  = net[1];
	net_next[2]  = net[11] && net[19];
	net_next[3]  = net[56];
	net_next[4]  = net[4];
	net_next[5]  = net[5];
	net_next[6]  = net[13] || (net[2] && net[33] && net[35]) || net[51];
	net_next[7]  = net[7];
	net_next[8]  = net[20];
	net_next[9]  = net[8];
	net_next[10] = net[9];
	net_next[11] = net[10];
	net_next[12] = net[11];
	net_next[13] = (! net[24] && net[51]) || (net[33] && net[50]);
	net_next[14] = ((net[2] && net[33] && net[35]) || net[14]) && ! (net[13]);
	net_next[15] = net[14] || net[15];
	net_next[16] = (net[6] && net[4] && net[5]);
	net_next[17] = net[16] && net[15];
	net_next[18] = net[21];
	net_next[19] = net[18];
	net_next[20] = net[46];
	net_next[21] = net[55];
	net_next[22] = (net[28] && net[31]);
	net_next[23] = net[22];
	net_next[24] = net[23];
	net_next[25] = net[25];
	net_next[26] = net[26];
	net_next[27] = (net[48]) && ! net[29];
	net_next[28] = net[27];
	net_next[29] = net[29];
	net_next[30] = net[38] || (net[39] && ! net[49]);
	net_next[31] = net[30];
	net_next[32] = net[32];
	net_next[33] = (net[3]) && ! (net[34]);
	net_next[34] = net[34];
	net_next[35] = net[43] || net[0];
	net_next[36] = net[40];
	net_next[37] = net[38] || net[39];
	net_next[38] = (net[57] && net[7]) || (net[38] && net[15] && net[16]);
	net_next[39] = (net[58] && net[7]) || (net[39] && net[15] && net[16]);
	net_next[40] = net[41] || net[42];
	net_next[41] = net[41];
	net_next[42] = net[42];
	net_next[43] = net[57] || (net[58] && net[7] && net[30]);
	net_next[44] = net[49];
	net_next[45] = (net[45] && ! net[57]) || (net[13] && ! net[57]);
	net_next[46] = net[47];
	net_next[47] = (net[56] && net[7]) || (net[47] && net[15] && net[16]);
	net_next[48] = net[48];
	net_next[49] = net[27];
	net_next[50] = net[59];
	net_next[51] = net[17];
	net_next[52] = net[51];
	net_next[53] = net[53];
	net_next[54] = net[54];
	net_next[55] = net[43];
	net_next[56] = net[57] || net[58];
	net_next[57] = net[57];
	net_next[58] = net[58];
	net_next[59] = net[59];
	net_next[60] = ! net[0];

	// now we can update net
	memcpy(net, net_next, sizeof(state_t) * NET_SIZE);
}


int main(int argc, char** argv) {
	int num_steps = (argc > 1) ? atoi(argv[1]) : 4096;

	// default state --> scenario 0 from the xlsx
	state_t net[NET_SIZE] = {
		0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1
	};

	printf("# step ");
	for (int i = 0; i < NET_SIZE; i++) {
		printf("element%d ", i);
	}
	printf("\n");

	for (int step = 0; step < num_steps; step++) {
		printf("%d ", step);
		for (int i = 0; i < NET_SIZE; i++) {
			printf("%u ", net[i]);
		}
		printf("\n");

		update(net);
	}

	printf("%d ", num_steps);
	for (int i = 0; i < NET_SIZE; i++) {
		printf("%u ", net[i]);
	}
	printf("\n");

	return 0;
}

