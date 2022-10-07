--| network_toy
--|
--| simple boolean network for testing DiSHSOAP
--|

library ieee;
use ieee.std_logic_1164.all;

entity network_toy is
	port (
		-- all elements have single input and output
		A,   B,   C:   in  std_logic;
		A_n, B_n, C_n: out std_logic
	);
end entity;

architecture var1 of network_toy is
begin
	A_n <=   B   or    C;
	B_n <= not A and   C;
	C_n <=   A   and not C;
end var1;
