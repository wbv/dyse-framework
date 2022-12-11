--! @file dishsoap_ctrl.vhdl
--! @brief Controller for the DiSH SOAP simulator elements

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dishsoap_ctrl is
	generic (
		--! network size
		NETWORK_SIZE: positive;
		--! size of the 'number of rule steps' counter
		COUNTER_WIDTH: positive
	);
	port (
		--! simulation inputs/config
		init_state: in std_logic_vector(NETWORK_SIZE-1 downto 0);
		num_steps:  in std_logic_vector(COUNTER_WIDTH-1 downto 0);

		--! starts a sim run with configuration above
		go: in std_logic;
		--! tells the sim the current step has been read
		stream_ready: in std_logic;

		--! current state of the network
		state: out std_logic_vector(NETWORK_SIZE-1 downto 0);
		--! state flags
		state_valid: out std_logic; --! '1' when state should be saved
		state_last: out std_logic;  --! '1' when state is the last of the sim
		sim_done: out std_logic;    --! '1' when the sim completed

		--! DEBUG
		dbg_reg2: out std_logic_vector(COUNTER_WIDTH-1 downto 0);
		dbg_reg3: out std_logic_vector(COUNTER_WIDTH-1 downto 0);

		--! asynchronous reset, clock
		areset, clk: in std_logic
	);
end dishsoap_ctrl;

architecture behavioral of dishsoap_ctrl is
	component network is
		port (
			net:      in  std_logic_vector(NETWORK_SIZE-1 downto 0);
			net_next: out std_logic_vector(NETWORK_SIZE-1 downto 0)
		);
	end component;
	for the_network: network use entity work.network;

	component nw_reg is
		generic (
			NETWORK_SIZE: natural
		);
		port (
			state_next:  in  std_logic_vector(NETWORK_SIZE-1 downto 0);
			init_state:  in  std_logic_vector(NETWORK_SIZE-1 downto 0);
			rule_sel:    in  std_logic_vector(NETWORK_SIZE-1 downto 0);
			force_elems: in  std_logic_vector(NETWORK_SIZE-1 downto 0);
			force_vals:  in  std_logic_vector(NETWORK_SIZE-1 downto 0);
			clk:         in  std_logic;
			en:          in  std_logic;
			reset:       in  std_logic;
			state:       out std_logic_vector(NETWORK_SIZE-1 downto 0)
		);
	end component;
	for network_reg: nw_reg use entity work.nw_reg;

	type dishsoap_state is (
		IDLE,
		RUNNING
	);
	signal exec_state: dishsoap_state;
	signal is_idle:    std_logic;
	signal is_running: std_logic;

	signal step_counter: unsigned(COUNTER_WIDTH-1 downto 0);
	signal max_steps:    unsigned(COUNTER_WIDTH-1 downto 0);
	signal last_state:   std_logic;

	signal net_state:      std_logic_vector(NETWORK_SIZE-1 downto 0);
	signal net_state_next: std_logic_vector(NETWORK_SIZE-1 downto 0);

	signal net_update_en: std_logic;
	signal nw_reg_reset:  std_logic;
begin

	-- the network, as combinational logic
	the_network: network
		port map (
			net      => net_state,
			net_next => net_state_next
		);

	-- the network state register/update controller
	network_reg: nw_reg
		generic map (
			NETWORK_SIZE => NETWORK_SIZE
		)
		port map (
			state_next  => net_state_next,
			init_state  => init_state,
			rule_sel    => (others => '1'), -- synchronous for now
			force_elems => (others => '0'), -- no forcing function
			force_vals  => (others => '0'), -- no forcing function
			clk         => clk,
			en          => net_update_en,
			reset       => nw_reg_reset,
			state       => net_state
		);


	clk_process:
	process(clk)
	begin
		if rising_edge(clk) then
			if areset = '1' then
				-- reset all sim state and disable network update
				max_steps      <= (others => '1');
				step_counter   <= (others => '0');
				exec_state     <= IDLE;
			else
				case (exec_state) is
					when IDLE =>
						-- IDLE unless 'go' is asserted
						if go = '1' then
							-- latch in simulation variables/devices
							step_counter   <= to_unsigned(0, step_counter'length);
							max_steps      <= unsigned(num_steps);
							-- and enter run state
							exec_state <= RUNNING;
						end if;

					when RUNNING =>
						-- only step the simulation forward if state has been saved
						if stream_ready = '1' then
							step_counter <= step_counter + 1;
							-- after last state, transition to idle
							if last_state = '1' then
								exec_state <= IDLE;
							end if;
						end if;

				end case;
			end if;
		end if;
	end process;

	-- exec_state indicator signals
	is_idle    <= '1' when exec_state = IDLE else '0';
	is_running <= '1' when exec_state = RUNNING else '0';

	-- network state is always visible
	state <= net_state;
	-- and is being latched in while not executing
	nw_reg_reset <= '1' when exec_state = IDLE else '0';
	-- last state of current sim run is being sent
	last_state <= '1' when step_counter = max_steps else '0';

	-- allow network state to update if the stream recipient is ready for it
	-- and we're still running a sim
	net_update_en <= stream_ready and not is_idle;

	-- informative state outputs
	state_valid <= is_running;
	state_last  <= last_state;
	sim_done    <= is_idle;

	--DEBUG
	dbg_reg2 <= std_logic_vector(max_steps);
	dbg_reg3 <= std_logic_vector(step_counter);


end behavioral;
