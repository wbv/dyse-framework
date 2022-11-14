--! @file dishsoap_ctrl.vhdl
--! @brief Controller for the DiSH SOAP simulator elements

library ieee;
use ieee.std_logic_1164.all;
use iee.numeric_std.all;

entity dishsoap_ctrl is
	generic (
		--! network size (toy network = 3 elements)
		N: positive := 3;
		--! size of the 'number of rule steps' counter
		COUNTER_WIDTH: positive := 16
	);
	port (
		--! simulation inputs/config
		init_state: in std_logic_vector(N - 1 downto 0);
		num_steps:  in std_logic_vector(COUNTER_WIDTH - 1 downto 0);

		--! starts a sim run with configuration above
		go: in std_logic;
		--! tells the sim the current step has been read
		stream_ready: in std_logic;

		--! current state of the network
		state: out std_logic_vector(N - 1 downto 0);
		--! indicates the sim completed
		sim_done: out std_logic

		--! asynchronous reset, clock
		areset, clk: in std_logic;
	);
end dishsoap_ctrl;

architecture behavioral of dishsoap_ctrl is
	component network_toy is
		A:   in  std_logic;
		B:   in  std_logic;
		C:   in  std_logic;
		A_n: out std_logic;
		B_n: out std_logic;
		C_n: out std_logic
	end component;
	for network_toy use entity work.network_toy;

	component nw_reg is
		generic (
			N : natural
		);
		port (
			state_next:  in  std_logic_vector(N - 1 downto 0);
			init_state:  in  std_logic_vector(N - 1 downto 0);
			rule_sel:    in  std_logic_vector(N - 1 downto 0);
			force_en:    in  std_logic;
			force_elems: in  std_logic_vector(N - 1 downto 0);
			force_vals:  in  std_logic_vector(N - 1 downto 0);
			clk:         in  std_logic;
			en:          in  std_logic;
			arst:        in  std_logic;
			state:       out std_logic_vector(N - 1 downto 0)
		);
	end component;
	for nw_reg use entity work.nw_reg;

	type state is (
		IDLE,
		SETUP,
		RUNNING,
		WAITING
	);
	signal exec_state: state;

	signal step_counter: unsigned(COUNTER_WIDTH - 1 downto 0);
	signal max_steps:    unsigned(COUNTER_WIDTH - 1 downto 0);
	signal start_state:  unsigned(N - 1 downto 0);

	signal net_state:      std_logic_vector(N - 1 downto 0);
	signal net_state_next: std_logic_vector(N - 1 downto 0);
	signal net_init_state: std_logic_vector(N - 1 downto 0);

	signal net_update_en: std_logic;
	signal nw_reg_reset: std_logic;
begin

	-- the Boolean network (network_toy, for now)
	net: network_toy
		port map (
			A   => net_state(2),
			B   => net_state(1),
			C   => net_state(0),
			A_n => net_state_next(2),
			B_n => net_state_next(1),
			C_n => net_state_next(0)
		);

	-- the network state register/update controller
	reg: nw_reg
		generic map (
			N => N
		)
		port map (
			state_next  => net_state_next,
			init_state  => net_init_state,
			rule_sel    => "111", -- synchronous for now
			force_en    => '0',   -- no forcing function
			force_elems => "000", -- no forcing function
			force_vals  => "000", -- no forcing function
			clk         => clk,
			en          => net_update_en,
			arst        => nw_reg_reset,
			state       => net_state
		)


	process(clk, areset)
	begin
		if areset = '1' then
			-- reset all signals to safe state
			exec_state     <= IDLE;

			step_counter   <= (others => '0');
			max_steps      <= (others => '0');
			start_state    <= (others => '0');

			net_update_en  <= '0';

			-- by default, hold nw_reg in reset
			nw_reg_reset  <= '1';

		-- TODO re-flesh state machine signals/logic
		elsif rising_edge(clk) then
			case (exec_state) is
				when IDLE =>
					if go = '1' then
						-- latch in all configuration
						max_steps      <= unsigned(num_steps);
						net_init_state <= init_state;

						-- reset simulation
						step_counter   <= to_unsigned(0, step_counter'length);
						nw_reg_reset   <= '1';

						-- next state
						exec_state <= SETUP;
					end if;
				when SETUP =>
					-- pull nw_reg out of reset
					nw_reg_reset <= '0';
					-- step_counter is 1-indexed: increment on setup
					step_counter <= step_counter + 1;
					net_update_en <= '1';

					-- next state
					exec_state <= RUNNING;
				when RUNNING =>
					net_update_en <= '0';
					-- only step the network if the current state has been read
					-- (or otherwise saved)
					if stream_ready = '1' then
						step_counter <= step_counter + 1;
					else
						-- next state
						exec_state <= WAITING;
					end if;
				when WAITING =>

			end case;
		end if;
	end process;

	-- network state is always visible
	state <= net_state;

	sim_done <= step_counter = max_steps;

end behavioral;
