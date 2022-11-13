--! @file lfsr64.vhdl
--! @brief Linear Feedback Shift Register, 64-bits (fixed)
--!
--! Generates a 64-bit LFSR, based off a table of XNORs needed for a given
--! random number size. (see Xilinx XAPP 210 for table used)

library ieee;
use ieee.std_logic_1164.all;

entity lfsr64 is
	port (
		--! Initial value used on reset signal
		seed: in  std_logic_vector(63 downto 0);
		--! Random number output
		rand: out std_logic_vector(63 downto 0);

		clk: in std_logic; --! Clock input
		en:  in std_logic; --! Enable shift
		rst: in std_logic  --! Reset value to 'seed'
	);
end lfsr64;

architecture behavioral of lfsr64 is
	signal state: std_logic_vector(63 downto 0);
	signal new_bit: std_logic;
begin
	process(clk, rst)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				state <= seed;
			elsif en = '1' then
				state <= state(62 downto 0) & new_bit;
			end if;
		end if;
	end process;

	-- new_bit is determined by the size of the LFSR. Some common sizes:
	--
	--   N   XNOR indices (0-indexed)
	-- ------------------------------
	--  16    15  14  12  3
	--  32    31  21   1  0
	--  64    63  62  60 59
	-- 128   127 125 100 98
	--
	new_bit <= state(63) xnor state(62) xnor state(60) xnor state(59);

	rand <= state;

end behavioral;
