library ieee;
use ieee.std_logic_1164.all;

entity nw_reg_tb is
	generic (
		N : natural := 3
	);
end nw_reg_tb;

architecture test of nw_reg_tb is
	component nw_reg
		generic (
			N : natural := N 
		);
		port (
			state_next: in  std_logic_vector(N - 1 downto 0);
			state:      out std_logic_vector(N - 1 downto 0);

			clk: in std_logic;
			en:  in std_logic;
			rst: in std_logic
		);
	end component;
	for uut: nw_reg use entity work.nw_reg;

	-- uut signals
	signal state_next, state: std_logic_vector(N - 1 downto 0);
	signal en, rst: std_logic;
	signal clk: std_logic := '0';

	-- test variables
	shared variable test_complete : boolean := false;
begin

	uut: nw_reg port map (
		state      => state,
		state_next => state_next,

		clk => clk,
		en  => en,
		rst => rst
	);

-- clock: do nothing for 5ns, then run on 10ns clock period until test_complete
clock: process
begin
	if test_complete = true then
		wait;
	end if;

	wait for 5 ns;
	clk <= not clk;
end process clock;


-- test bench
tb: process
begin
	wait for 5 ns; -- wait for clock to go high

	wait for 10 ns;
	rst <= '1';
	state_next <= "101";

	wait for 10 ns;
	rst <= '0';

	wait for 10 ns;
	en <= '1';

	wait for 10 ns;
	en <= '0';

	wait for 10 ns;

	test_complete := true;
	assert false report "test_complete" severity note;
	wait;
end process tb;

end test;
