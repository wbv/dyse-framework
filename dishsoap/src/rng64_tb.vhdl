--! @file rng64_tb.vdhl
--! @brief testbench for rng64

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rng64_tb is
	generic (
		BOUNDARY: natural := 65
	);
	end rng64_tb;

architecture test of rng64_tb is
	component rng64
		generic (
			UPPER_BOUND: positive := BOUNDARY
		);
		port (
			clk:      in  std_logic;
			rst:      in  std_logic;
			seed:     in  std_logic_vector(63 downto 0);
			get_next: in  std_logic;
			rand:     out std_logic_vector(63 downto 0);
			valid:    out std_logic
		);
	end component;
	for uut: rng64 use entity work.rng64;

	-- uut signals
	signal rand_slv: std_logic_vector(63 downto 0);
	signal seed_slv: std_logic_vector(63 downto 0);
	signal rand: unsigned(63 downto 0);
	signal seed: unsigned(63 downto 0);
	signal rst, get_next, valid: std_logic;

	-- clock starts low to move rising edge between CLK_PERIOD intervals
	signal clk: std_logic := '0';

	-- flag for test completion
	shared variable test_complete : boolean := false;

	-- period for the main testbench's clock
	constant CLK_PERIOD: time := 10 ns;
begin

	uut: rng64
		port map (
			clk      => clk,
			rst      => rst,
			seed     => seed_slv,
			get_next => get_next,
			rand     => rand_slv,
			valid    => valid
		);

	seed_slv <= std_logic_vector(seed);
	rand <= unsigned(rand_slv);

-- clock: oscillate until test_complete
clock: process
begin
	if test_complete = true then
		-- disconnect the clock when done, for fun
		clk <= 'Z';
		wait for CLK_PERIOD;
		wait;
	end if;

	wait for (CLK_PERIOD/2);
	clk <= not clk;
end process clock;


-- the main testbench
tb: process
	variable temp: unsigned(63 downto 0);
	constant LFSR_TIMEOUT: integer := 10;
begin
	-- initial states
	seed <= to_unsigned(0, seed'length);
	rst <= '0';
	get_next <= '0';
	wait for CLK_PERIOD;

	-- Test: reset for a cycle (to 0)
	rst <= '1', '0' after CLK_PERIOD;
	wait for CLK_PERIOD;

	assert rand = to_unsigned(0, rand'length)
		report "rand did not reset to seed (0)";


	-- Test: reset to a specific seed
	wait for CLK_PERIOD;
	seed <= to_unsigned(55, seed'length);
	rst <= '1', '0' after CLK_PERIOD;
	wait for CLK_PERIOD;

	assert rand = to_unsigned(55, rand'length)
		report "rand did not reset to seed (55)";


	-- Test: ensure that LFSR actually changes state while running
	get_next <= '1', '0' after CLK_PERIOD;
	for t in 1 to LFSR_TIMEOUT loop
		wait for CLK_PERIOD;
		exit when valid = '1';
	end loop;

	assert valid = '1'
		report "valid did not assert after LFSR_TIMEOUT";
	assert rand <= to_unsigned(BOUNDARY, rand'length)
		report "rand is out-of-bounds";
	

	-- Test: we stopped running but make sure LFSR held state
	wait for CLK_PERIOD;
	temp := rand;
	wait for CLK_PERIOD;

	assert rand = temp
		report "rand changed without a get_next";


	-- (not a test) observe RNG from large seed
	wait for CLK_PERIOD;
	seed <=   to_unsigned(10293, 16) & to_unsigned(5020,  16)
			& to_unsigned(56271, 16) & to_unsigned(18541, 16);
	rst <= '1', '0' after CLK_PERIOD;
	wait for CLK_PERIOD;

	for i in 1 to 5 loop
		get_next <= '1', '0' after CLK_PERIOD;
		for t in 1 to LFSR_TIMEOUT loop
			wait for CLK_PERIOD;
			exit when valid = '1';
		end loop;
	end loop;


	-- Test: ensure reset back to seed works
	seed <= to_unsigned(1, seed'length);
	rst <= '1', '0' after CLK_PERIOD;
	wait for CLK_PERIOD;

	assert rand = to_unsigned(1, rand'length)
		report "rand didn't reset back to seed (1)";


	--|===============|--
	--| TEST COMPLETE |--
	--|===============|--
	wait for CLK_PERIOD;
	test_complete := true;
	wait;
end process tb;

end test;
