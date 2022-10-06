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
	-- clock starts high to align rising edge to CLK_PERIOD intervals
	signal clk: std_logic := '1';

	-- flag for test completion
	shared variable test_complete : boolean := false;

	-- period for the main testbench's clock
	constant CLK_PERIOD: time := 10 ns;
begin

	uut: nw_reg port map (
		state      => state,
		state_next => state_next,

		clk => clk,
		en  => en,
		rst => rst
	);

-- clock: oscillate until test_complete
clock: process
begin
	if test_complete = true then
		-- assert "undetermined" signal when done, for fun
		clk <= 'U';
		wait for CLK_PERIOD;
		wait;
	end if;

	wait for (CLK_PERIOD/2);
	clk <= not clk;
end process clock;


-- the main testbench
tb: process
begin
	-- initial states
	state_next <= "101";
	en <= '0';
	rst <= '0';

	wait for CLK_PERIOD;
	rst <= '1';
	wait for CLK_PERIOD;
	rst <= '0';

	assert state = "000"
		report "RST did not reset state";


	wait for CLK_PERIOD;
	en <= '1';
	wait for CLK_PERIOD;
	en <= '0';

	assert state = "101"
		report "EN did not update state";


	wait for CLK_PERIOD;
	state_next <= "011";
	en <= '1';
	wait for CLK_PERIOD;
	en <= '0';

	assert state = "011"
		report "EN did not update state";


	wait for CLK_PERIOD;
	rst <= '1';
	wait for CLK_PERIOD;
	rst <= '0';

	assert state = "000"
		report "RST did not reset state";


	wait for CLK_PERIOD;
	en <= '0';
	rst <= '1';
	wait for CLK_PERIOD;
	en <= '1';
	rst <= '0';

	assert state = "000"
		report "RST did not reset state";


	wait for CLK_PERIOD;
	test_complete := true;
	wait;
end process tb;

end test;
