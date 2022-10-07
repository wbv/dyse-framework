library ieee;
use ieee.std_logic_1164.all;

entity network_toy_tb is end entity;

architecture test of network_toy_tb is
	component network_toy
		port (
			A,   B,   C:   in  std_logic;
			A_n, B_n, C_n: out std_logic
		);
	end component;
	for uut: network_toy use entity work.network_toy;

	signal state, state_next : std_logic_vector(2 downto 0);

	-- truth table definitions
	subtype net_state   is std_logic_vector(2 downto 0);
	type    truth_row   is array(0 to 1) of net_state;
	type    truth_table is array (natural range <>) of truth_row;

	constant table : truth_table :=
		-- ABC  A'B'C'
		(("000","000"),
		 ("001","110"),
		 ("010","100"),
		 ("011","110"),
		 ("100","001"),
		 ("101","100"),
		 ("110","101"),
		 ("111","100"));
	signal table_row : truth_row;

	-- clocking (simulated)
	constant delay : time := 10 fs;
	signal   clk   : std_logic := '1';

	-- test metadata
	shared variable test_complete: boolean := false;
	signal index : natural := 0;
	signal expected_state_next : net_state;
begin
	uut: network_toy
		port map (
			A => state(2),
			B => state(1),
			C => state(0),
			A_n => state_next(2),
			B_n => state_next(1),
			C_n => state_next(0)
		);

	table_row <= table(index);
	state <= table_row(0);
	expected_state_next <= table_row(1);

clock: process
begin
	if test_complete = true then
		wait;
	else
		wait for delay/2;
		clk <= not clk;
	end if;
end process clock;

-- main testbench process
tb: process(clk)
begin
	if rising_edge(clk) then
		assert state_next = expected_state_next 
		report "Truth table invalid at " & natural'image(index) & lf
			& " --> "
			& std_logic'image(state_next(0))
			& std_logic'image(state_next(1))
			& std_logic'image(state_next(2)) & " <> "
			& std_logic'image(expected_state_next(0))
			& std_logic'image(expected_state_next(1))
			& std_logic'image(expected_state_next(2));

		if index >= table'high then
			test_complete := true;
		else
			index <= index + 1;
		end if;

	end if;
end process;

end test;
