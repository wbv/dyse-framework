--| test_pad_tb: a scratchpad for testing small pieces of VHDL

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_pad_tb is
end test_pad_tb;

architecture test of test_pad_tb is

	--|=============================|--
	--| Unit-Under-Test Definitions |--
	--|=============================|--
	signal a, in_a: std_logic_vector(1 downto 0);
	signal b, wr_en: std_logic := '0';
	signal c,d: unsigned(7 downto 0) := (others => '0');


	--|==============================|--
	--| Common Testbench Definitions |--
	--|==============================|--
	-- clock starts high to align rising edge to CLK_PERIOD intervals
	signal clk: std_logic := '1';
	-- flag for test completion
	shared variable test_complete : boolean := false;
	-- period for the main testbench's clock
	constant CLK_PERIOD: time := 10 ns;
begin

--|=======|--
--| Clock |--
--|=======|--
clock: process
begin
	if test_complete = true then
		-- assert "undetermined" clk when done, for fun
		clk <= 'U';
		wait for CLK_PERIOD;
		wait;
	end if;

	wait for (CLK_PERIOD/2);
	clk <= not clk;
end process clock;


----- test code -----
a(0) <= b;

process(clk)
begin
	if rising_edge(clk) then
		if wr_en = '1' then
			if in_a(0) = '1' then
				b <= '1';
			end if;
			a(a'high downto 1) <= in_a(a'high downto 1);
			c <= c + 1;
		else
			b <= '0';
		end if;
	end if;
end process;


--|================|--
--| Main Testbench |--
--|================|--
tb: process
begin
	wait for CLK_PERIOD;
	--| Begin Test |--
	in_a <= "00";
	wr_en <= '0';

--	assert a = "00"
--		report "a is not high";

	wait for CLK_PERIOD;

	in_a <= "01";
	wr_en <= '1';

	wait for CLK_PERIOD;

	wr_en <= '0';

	wait for CLK_PERIOD;

	in_a <= "11";

	wait for CLK_PERIOD;

	wr_en <= '1';

	wait for CLK_PERIOD;

	wr_en <= '0';

	wait for CLK_PERIOD;

	--| End of test |--
	wait for CLK_PERIOD;
	test_complete := true;
	wait;
end process tb;

end test;
