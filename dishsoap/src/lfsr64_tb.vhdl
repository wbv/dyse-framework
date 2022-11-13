--! @file lfsr64_tb.vdhl
--! @brief testbench for lfsr64

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lfsr64_tb is end lfsr64_tb;

architecture test of lfsr64_tb is
	component lfsr64
		port (
			seed: in  std_logic_vector(63 downto 0);
			rand: out std_logic_vector(63 downto 0);
			clk, en, rst: in std_logic
		);
	end component;
	for uut: lfsr64 use entity work.lfsr64;

	-- uut signals
	signal rand_slv: std_logic_vector(63 downto 0);
	signal seed_slv: std_logic_vector(63 downto 0);
	signal rand: unsigned(63 downto 0);
	signal seed: unsigned(63 downto 0);
	signal en, rst: std_logic;

	-- clock starts low to move rising edge between CLK_PERIOD intervals
	signal clk: std_logic := '0';

	-- flag for test completion
	shared variable test_complete : boolean := false;

	-- period for the main testbench's clock
	constant CLK_PERIOD: time := 10 ns;
begin

	uut: lfsr64
		port map (
			seed => seed_slv,
			rand => rand_slv,
			clk => clk,
			en  => en,
			rst => rst
		);

	seed_slv <= std_logic_vector(seed);
	rand <= unsigned(rand_slv);

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
	variable temp: unsigned(63 downto 0);
begin
	-- initial states
	seed <= to_unsigned(0, seed'length);
	en <= '0';
	rst <= '0';

	-- Test: reset for a cycle (to 0)
	wait for CLK_PERIOD;
	rst <= '1';
	wait for CLK_PERIOD;
	rst <= '0';

	assert rand = to_unsigned(0, rand'length)
		report "rand did not reset to seed (0)";


	-- Test: reset to a specific seed
	wait for CLK_PERIOD;
	seed <= to_unsigned(55, seed'length);
	rst <= '1';
	wait for CLK_PERIOD;
	rst <= '0';

	assert rand = to_unsigned(55, rand'length)
		report "rand did not reset to seed (55)";


	-- Test: ensure that LFSR actually changes state while running
	en <= '1';
	wait for CLK_PERIOD;

	assert rand /= to_unsigned(0, rand'length)
		report "rand is zero (should be nonzero!)";


	-- Test: stop running but hold LFSR state
	en <= '0';
	wait for CLK_PERIOD;
	temp := rand;
	wait for CLK_PERIOD;

	assert rand = temp
		report "rand changed while enable was off";


	-- (not a test) observe RNG from large seed
	wait for CLK_PERIOD;
	seed <=   to_unsigned(10293, 16) & to_unsigned(5020,  16)
			& to_unsigned(56271, 16) & to_unsigned(18541, 16);
	rst <= '1';
	wait for CLK_PERIOD;
	rst <= '0';
	en <= '1';
	wait for 100*CLK_PERIOD;


	-- Test: ensure reset back to seed works
	en <= '0';
	seed <= to_unsigned(1, seed'length);
	rst <= '1';
	wait for CLK_PERIOD;
	rst <= '0';

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
