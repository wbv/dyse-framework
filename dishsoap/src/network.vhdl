--! network.vhdl

--! example network: gene_expression.xlsx (5 elements)

library ieee;
use ieee.std_logic_1164.all;

entity network is
	generic (
		NETWORK_SIZE: positive := 6
	);
	port (
		-- all elements have single input and output
		net:      in  std_logic_vector(NETWORK_SIZE-1 downto 0);
		net_next: out std_logic_vector(NETWORK_SIZE-1 downto 0)
	);
end entity;

architecture var1 of network is
begin
	--! TF    = TF
	net_next(0) <= net(0);
	--! Inh   = Inh
	net_next(1) <= net(1);
	--! Xgene = (TF,!Inh)
	net_next(2) <= net(0) and not net(1);
	--! Xrna = Xgene
	net_next(3) <= net(2);
	--! Xprotein = Xrna
	net_next(4) <= net(3);
	net_next(5) <= net(4);
end var1;
