--! @file dishsoap_ctrl.vhdl
--! @brief Controller for the DiSH SOAP simulator elements

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
		--! state flags
		state_valid: out std_logic; --! '1' when state should be saved
		state_last: out std_logic;  --! '1' when state is the last of the sim
		sim_done: out std_logic;    --! '1' when the sim completed

		--! asynchronous reset, clock
		areset, clk: in std_logic
	);
end dishsoap_ctrl;

architecture behavioral of dishsoap_ctrl is
	component network_toy is
		port (
			A:   in  std_logic;
			B:   in  std_logic;
			C:   in  std_logic;
			A_n: out std_logic;
			B_n: out std_logic;
			C_n: out std_logic
		);
	end component;
	for net: network_toy use entity work.network_toy;

	component nw_reg is
		generic (
			N: natural
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
	for reg: nw_reg use entity work.nw_reg;

	type dishsoap_state is (
		IDLE,
		RUNNING
	);
	signal exec_state: dishsoap_state;
	signal is_idle:    std_logic;
	signal is_running: std_logic;

	signal step_counter: unsigned(COUNTER_WIDTH - 1 downto 0);
	signal max_steps:    unsigned(COUNTER_WIDTH - 1 downto 0);
	signal last_state:   std_logic;

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
			rule_sel    => (others => '1'), -- synchronous for now
			force_en    => '0',             -- no forcing function
			force_elems => (others => '0'), -- no forcing function
			force_vals  => (others => '0'), -- no forcing function
			clk         => clk,
			en          => net_update_en,
			arst        => nw_reg_reset,
			state       => net_state
		);


	clk_process: process(clk, areset)
	begin
		if areset = '1' then
			-- reset all sim state and disable network update
			max_steps      <= (others => '0');
			net_init_state <= (others => '0');
			step_counter   <= (others => '0');
			nw_reg_reset   <= '1';
		elsif rising_edge(clk) then
			case (exec_state) is
				when IDLE =>
					-- IDLE unless 'go' is asserted
					if go = '1' then
						-- latch in all configuration
						max_steps      <= unsigned(num_steps);
						net_init_state <= init_state;
						-- initialize simulation variables/devices
						step_counter   <= to_unsigned(0, step_counter'length);
						-- reset network state to init_state (input)
						nw_reg_reset   <= '1';

						exec_state <= RUNNING;
					end if;

				when RUNNING =>
					nw_reg_reset <= '0';
					-- only step the network if the current state has been saved
					if stream_ready = '1' then
						step_counter  <= step_counter + 1;
						-- after last state, transition to idle
						if last_state = '1' then
							exec_state <= IDLE;
						end if;
					end if;

			end case;
		end if;
	end process;

	-- network state is always visible
	state <= net_state;

	-- last state of current sim run is being sent
	last_state <= '1' when step_counter = max_steps else '0';
	-- exec_state indicator signals
	is_idle    <= '1' when exec_state = IDLE else '0';
	is_running <= '1' when exec_state = RUNNING else '0';

	-- always update the network state if the stream recipient is ready for it
	-- and we're still running a sim
	net_update_en <= stream_ready and not is_idle;

	-- informative state outputs
	state_valid <= is_running;
	state_last  <= last_state;
	sim_done    <= is_idle;


end behavioral;
