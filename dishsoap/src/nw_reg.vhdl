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
--| in   arst         asynchronous reset (active 'hi')
--|

library ieee;
use ieee.std_logic_1164.all;

entity nw_reg is
	generic (
		N : natural := 3
	);
	port (
		--! computed next state for each element
		--! (should connect to the output of the network combinational logic)
		state_next: in std_logic_vector(N - 1 downto 0);

		--! initial (reset) state of the network
		init_state: in std_logic_vector(N - 1 downto 0);
		--! mask for which rules are selected
		rule_sel: in std_logic_vector(N - 1 downto 0);

		--! forcing function:
		--! when force_en = 1, override state of elements with force_vals if
		--! they are selected by force_elems
		force_en:    in std_logic;
		force_elems: in std_logic_vector(N - 1 downto 0);
		force_vals:  in std_logic_vector(N - 1 downto 0);

		clk: in std_logic;
		en:  in std_logic;
		arst: in std_logic;

		state: out std_logic_vector(N - 1 downto 0)
	);
end nw_reg;

architecture behavioral of nw_reg is
begin
	process(clk, arst)
	begin
		if arst = '1' then
			state <= init_state;
		elsif rising_edge(clk) and en = '1' then
			for i in 0 to N-1 loop
				if force_en = '1' and force_elems(i) = '1' then
					state(i) <= force_vals(i);
				elsif rule_sel(i) = '1' then
					state(i) <= state_next(i);
				end if;
			end loop;
		end if;
	end process;
end behavioral;
