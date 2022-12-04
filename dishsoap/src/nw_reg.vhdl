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
		--! override state of elements with force_vals if
		--! they are selected by force_elems
		force_elems: in std_logic_vector(N - 1 downto 0);
		force_vals:  in std_logic_vector(N - 1 downto 0);

		clk: in std_logic;
		en:  in std_logic;
		reset: in std_logic;

		state: out std_logic_vector(N - 1 downto 0)
	);
end nw_reg;

architecture behavioral of nw_reg is
	signal reg_next:     std_logic_vector(N-1 downto 0);
	signal reg:          std_logic_vector(N-1 downto 0);
begin
	process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				reg <= init_state;
			elsif en = '1' then
				reg <= reg_next;
			end if;
		end if;
	end process;

	state <= reg;

	register_update_mux:
	for i in 0 to N-1 generate
		reg_next(i) <=      force_vals(i) when force_elems(i) = '1'
		               else state_next(i) when rule_sel(i) = '1'
		               else reg(i);
	end generate;
end behavioral;
