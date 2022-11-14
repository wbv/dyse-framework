--! @file rng64.vhdl
--! @brief Uniform Random Number Generation
--!
--! Uses a fixed-width binary PRNG to generate uniformly-distributed random
--! numbers inside any range of [0, bound)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rng64 is
	generic (
		UPPER_BOUND: positive := 61
	);
	port (
		clk: in std_logic;
		rst: in std_logic;

		--! seed for the RNG (used on reset)
		seed: in std_logic_vector(63 downto 0);

		--! obtain another random number
		get_next: in std_logic;

		--! the RNG output
		rand: out std_logic_vector(63 downto 0);
		--! indicates that `rand` is a valid (bounded) output
		valid: out std_logic
	);
end rng64;

architecture behavioral of rng64 is
	component lfsr64
		port (
			seed: in  std_logic_vector(63 downto 0);
			rand: out std_logic_vector(63 downto 0);
			clk, en, rst: in std_logic
		);
	end component;
	for lfsr: lfsr64 use entity work.lfsr64;

	-- untruncated output from the lfsr
	signal lfsr_out: std_logic_vector(63 downto 0);

	-- indicates whether or not the LFSR needs to keep running
	signal run_lfsr: std_logic;
	-- indicates if the output is bounded
	signal is_valid: std_logic;

	-- num_bits(val)
	-- returns number of bits required to represent positive integer `val`
	function num_bits(val: positive) return positive is
		variable num, remainder: natural;
	begin
		num := 0;
		remainder := val;
		while remainder > 0 loop
			num := num + 1;
			remainder := remainder / 2;
		end loop;
		return num;
	end function;

	-- statically-compute portion of lfsr to actually use
	constant KEEP_BITS: positive := num_bits(UPPER_BOUND);
	constant BOUND: unsigned := to_unsigned(UPPER_BOUND, KEEP_BITS);
	signal lfsr_trunc: unsigned(KEEP_BITS - 1 downto 0);

begin
	lfsr: lfsr64
		port map (
			clk  => clk,
			en   => run_lfsr,
			rst  => rst,
			seed => seed,
			rand => lfsr_out
		);

	-- portion of LFSR output actually kept
	lfsr_trunc <= unsigned(lfsr_out(KEEP_BITS-1 downto 0));

	-- check LFSR output boundaries
	is_valid <= '1' when (lfsr_trunc <= BOUND) else '0';

	-- output the bounded lfsr result (masking ignored bits)
	rand(63 downto KEEP_BITS)    <= (others => '0');
	rand(KEEP_BITS - 1 downto 0) <= std_logic_vector(lfsr_trunc);
	valid <= is_valid;

	-- the LFSR runs until it has a valid random number
	-- or it hasn't been asked for another one
	run_lfsr <= '1' when (get_next = '1') or (is_valid = '0') else '0';

end behavioral;
