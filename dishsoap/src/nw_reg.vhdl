--| nw_reg: an `N`-bit register outputing the current network state
--| 
--| generics
--| --------
--| N    number of elements 
--| 
--| dir  port        port description
--| ---  ----        ----------------
--| out  state       current state of all network elements (as a std_logic_vector)
--| in   state_next  what `state` will become at next clk
--| 
--| in   clk         clock (leading edge)
--| in   en          enable update
--| in   rst         asynchronous reset (active 'hi')
--| 

library ieee;
use ieee.std_logic_1164.all;

entity nw_reg is
	generic (
		N : natural := 3 
	);
	port (
		state_next: in  std_logic_vector(N - 1 downto 0);
		state:      out std_logic_vector(N - 1 downto 0);

		clk: in std_logic;
		en:  in std_logic;
		rst: in std_logic
	);
end nw_reg;

architecture behavioral of nw_reg is
begin
	process(clk, rst)
	begin
		if rst = '1' then
			state <= (others => '0');
		elsif rising_edge(clk) and en = '1' then
			state <= state_next;
		end if;
	end process;
end behavioral;
