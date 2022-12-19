library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity dishsoap_ctrl_tb is
	generic (
		-- network_toy is 3 elements
		N: natural := 3;
		COUNTER_WIDTH: positive := 16
	);
end dishsoap_ctrl_tb;

architecture test of dishsoap_ctrl_tb is
	component dishsoap_ctrl
		generic (
			NETWORK_SIZE: natural := N;
			COUNTER_WIDTH: positive := COUNTER_WIDTH
		);
		port (
			init_state:   in  std_logic_vector(NETWORK_SIZE - 1 downto 0);
			num_steps:    in  std_logic_vector(COUNTER_WIDTH - 1 downto 0);
			go:           in  std_logic;
			stream_ready: in  std_logic;
			state:        out std_logic_vector(NETWORK_SIZE - 1 downto 0);
			state_valid:  out std_logic;
			state_last:   out std_logic;
			sim_done:     out std_logic;
			areset:       in  std_logic;
			clk:          in  std_logic
		);
	end component;
	for uut: dishsoap_ctrl use entity work.dishsoap_ctrl;

	-- uut signals
	signal init_state:   std_logic_vector(N - 1 downto 0);
	signal num_steps:    std_logic_vector(COUNTER_WIDTH - 1 downto 0);
	signal go:           std_logic;
	signal stream_ready: std_logic;
	signal state:        std_logic_vector(N - 1 downto 0);
	signal state_valid:  std_logic;
	signal state_last:   std_logic;
	signal sim_done:     std_logic;
	signal areset:       std_logic;

	signal num_steps_int: natural;

	-- clock starts low to move rising edge off CLK_PERIOD intervals
	signal clk: std_logic := '0';

	-- flag for test completion
	shared variable test_complete : boolean := false;

	-- period for the main testbench's clock
	constant CLK_PERIOD: time := 10 ns;
begin

	uut: dishsoap_ctrl
		generic map (
			NETWORK_SIZE => N,
			COUNTER_WIDTH => COUNTER_WIDTH
		)
		port map (
			init_state   => init_state,
			num_steps    => num_steps,
			go           => go,
			stream_ready => stream_ready,
			state        => state,
			state_valid  => state_valid,
			state_last   => state_last,
			sim_done     => sim_done,
			areset       => areset,
			clk          => clk
		);

	-- use num_steps_int to control num_steps
	num_steps <= std_logic_vector(to_unsigned(num_steps_int, COUNTER_WIDTH));

-- clock: oscillate until test_complete
clock: process
begin
	if test_complete = true then
		-- disconnsect clk when done to visually indicate test over (for fun)
		clk <= 'Z';
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
	init_state    <= "000";
	num_steps_int <= 0;
	go            <= '0';
	stream_ready  <= '0';
	areset        <= '0';

	--| TEST: reset
	wait for CLK_PERIOD;
	areset <= '1', '0' after CLK_PERIOD;
	wait for CLK_PERIOD;

	assert state = "000"
		report "RST did not reset state";


	--| TEST: go, but no ready signal

	-- first, latch in a state that will change
	init_state <= "001";
	num_steps_int <= 10;
	areset <= '1', '0' after CLK_PERIOD;
	wait for 2*CLK_PERIOD;

	-- then say go and wait
	go <= '1', '0' after CLK_PERIOD;
	wait for 2*CLK_PERIOD;

	assert state = "001"
		report "stream_ready did not inhibit go";


	--| TEST: stream_ready tells it to run
	stream_ready <= '1';

	wait for CLK_PERIOD;
	assert state = "110"
		report "run: state 1";
	wait for CLK_PERIOD;
	assert state = "101"
		report "run: state 2";
	wait for CLK_PERIOD;
	assert state = "100"
		report "run: state 3";
	wait for CLK_PERIOD;
	assert state = "001"
		report "run: state 4";
	wait for CLK_PERIOD;
	assert state = "110"
		report "run: state 5";


	--| TEST: stream_ready stops it
	stream_ready <= '0';
	wait for CLK_PERIOD*2;
	assert state = "110"
		report "stream_ready didn't stop sim";


	--| TEST: resume stream and finish it
	stream_ready <= '1';
	wait for CLK_PERIOD*10;

	assert sim_done = '1'
		report "sim didn't finish";
	assert state_valid = '0'
		report "sim still reporting valid but should be finished";


	--|================|--
	--| Test Completed |--
	--|================|--
	wait for CLK_PERIOD;
	test_complete := true;
	wait;
end process tb;

end test;
