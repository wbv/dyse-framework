library ieee;
use ieee.std_logic_1164.all;


entity nw_reg_tb is
	generic (
		N : natural := 4 -- use explicit 4-bit nw_reg
	);
end nw_reg_tb;

architecture test of nw_reg_tb is
	component nw_reg
		generic (
			N : natural := N
		);
		port (
			state_next:  in  std_logic_vector(N - 1 downto 0);
			init_state:  in  std_logic_vector(N - 1 downto 0);
			rule_sel:    in  std_logic_vector(N - 1 downto 0);
			force_elems: in  std_logic_vector(N - 1 downto 0);
			force_vals:  in  std_logic_vector(N - 1 downto 0);
			clk:         in  std_logic;
			en:          in  std_logic;
			reset:       in  std_logic;
			state:       out std_logic_vector(N - 1 downto 0)
		);
	end component;
	for uut: nw_reg use entity work.nw_reg;

	-- uut signals
	signal state:       std_logic_vector(N - 1 downto 0);
	signal state_next:  std_logic_vector(N - 1 downto 0);
	signal init_state:  std_logic_vector(N - 1 downto 0);
	signal rule_sel:    std_logic_vector(N - 1 downto 0);
	signal force_elems: std_logic_vector(N - 1 downto 0);
	signal force_vals:  std_logic_vector(N - 1 downto 0);
	signal en:          std_logic;
	signal reset:       std_logic;
	-- clock starts low to move rising edge off CLK_PERIOD intervals
	signal clk: std_logic := '0';

	-- flag for test completion
	shared variable test_complete : boolean := false;

	-- period for the main testbench's clock
	constant CLK_PERIOD: time := 10 ns;
begin

	uut: nw_reg
		generic map (
			N => N
		)
		port map (
			state_next   => state_next,
			init_state   => init_state,
			rule_sel     => rule_sel,
			force_elems  => force_elems,
			force_vals   => force_vals,
			clk          => clk,
			en           => en,
			reset        => reset,
			state        => state
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
	state_next <= "1010";
	en <= '0';
	reset <= '0';
	init_state <= (others => '0');
	rule_sel <= (others => '1');
	force_elems <= (others => 'Z');
	force_vals <= (others => 'Z');

	wait for CLK_PERIOD;
	reset <= '1', '0' after CLK_PERIOD;
	wait for CLK_PERIOD;

	assert state = "0000"
		report "RST did not reset state";


	en <= '1', '0' after CLK_PERIOD;
	wait for CLK_PERIOD;

	assert state = "1010"
		report "EN did not update state";


	state_next <= "0011";
	en <= '1', '0' after CLK_PERIOD;
	wait for CLK_PERIOD;

	assert state = "0011"
		report "EN did not update state";


	reset <= '1', '0' after CLK_PERIOD;
	wait for CLK_PERIOD;

	assert state = "0000"
		report "RST did not reset state";


	en <= '0', '1' after CLK_PERIOD;
	reset <= '1', '0' after CLK_PERIOD;
	wait for CLK_PERIOD;

	assert state = "0000"
		report "RST did not reset state";


	-- new test: reset to custom 'init'
	init_state <= "0111";
	reset <= '1', '0' after CLK_PERIOD;
	wait for CLK_PERIOD;

	assert state = "0111"
		report "state not updated to nonzero init";


	-- new test: partial update
	rule_sel <= "0001";
	state_next <= "1000";
	en <= '1', '0' after CLK_PERIOD;
	wait for CLK_PERIOD;

	assert state = "0110"
		report "rule_sel failed first update";


	-- new test: partial update (continued)
	rule_sel <= "1100";
	state_next <= "1001";
	en <= '1', '0' after CLK_PERIOD;
	wait for CLK_PERIOD;

	assert state = "1010"
		report "rule_sel failed first update";

	-- TODO tests: forcing functions

	--|================|--
	--| Test Completed |--
	--|================|--
	wait for CLK_PERIOD;
	test_complete := true;
	wait;
end process tb;

end test;
