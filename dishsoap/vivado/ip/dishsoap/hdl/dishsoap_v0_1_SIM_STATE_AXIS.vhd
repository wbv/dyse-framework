library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dishsoap_v0_1_SIM_STATE_AXIS is
	generic (
		--==============================--
		-- Users to add parameters here --
		--==============================--
		NETWORK_SIZE: integer := 3;
		-- also carry register widths in here
		C_S_AXI_DATA_WIDTH: integer := 64;
		--=====================================================--
		-- NOTE: Do not modify the parameters beyond this line --
		--=====================================================--
		-- Width of S_AXIS address bus.
		-- The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
		C_M_AXIS_TDATA_WIDTH: integer := 64;
		-- Start count is the number of clock cycles the master will wait before initiating/issuing any transaction.
		C_M_START_COUNT:      integer := 32
	);
	port (
		--=========================--
		-- Users to add ports here --
		--=========================--
		-- simulation i/o and configuration
		init_state: in  std_logic_vector(NETWORK_SIZE-1 downto 0);
		num_steps:  in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		start:      in  std_logic;
		ready:      out std_logic;
		--=====================================================--
		-- NOTE: Do not modify the parameters beyond this line --
		--=====================================================--
		-- Global ports
		M_AXIS_ACLK: in std_logic;
		M_AXIS_ARESETN: in std_logic;
		-- Master Stream Ports. TVALID indicates that the master is driving a valid transfer.
		-- A transfer takes place when both TVALID and TREADY are asserted.
		M_AXIS_TVALID: out std_logic;
		-- TDATA is the primary payload that is used to provide the data that is passing across the
		-- interface from the master.
		M_AXIS_TDATA:  out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		-- TSTRB is the byte qualifier that indicates whether the content of the associated byte
		-- of TDATA is processed as a data byte or a position byte.
		M_AXIS_TSTRB:  out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		-- TLAST indicates the boundary of a packet.
		M_AXIS_TLAST:  out std_logic;
		-- TREADY indicates that the slave can accept a transfer in the current cycle.
		M_AXIS_TREADY: in std_logic
	);
end dishsoap_v0_1_SIM_STATE_AXIS;

architecture implementation of dishsoap_v0_1_SIM_STATE_AXIS is
	-- state of the stream
	type state is (
		IDLE,         -- initial/idle state
		INIT_DELAY,   -- delay state, changes to SEND_STREAM after C_M_START_COUNT cycles of delay
		SEND_STREAM   -- stream data is output through M_AXIS_TDATA
	);
	signal exec_state: state;

	-- AXI Stream internal signals
	--wait counter. The master waits for the user defined number of clock cycles before initiating a transfer.
	signal start_delay: natural range 0 to C_M_START_COUNT;
	--streaming data valid
	signal axis_tvalid: std_logic;
	--Last of the streaming data
	signal axis_tlast: std_logic;
	-- signal being sent out over TDATA
	signal stream_data_out: std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);

	-- output controls
	signal num_output_states: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);

	-- dishsoap sim signals
	signal stream_ready: std_logic;
	signal sim_state_valid, sim_state_last, sim_done: std_logic;
	signal sim_state: std_logic_vector(NETWORK_SIZE-1 downto 0);

	-- non-inverted reset signal
	signal areset: std_logic;

	-- the dishsoap controller
	component dishsoap_ctrl is
		generic (
			N: positive := 3;
			COUNTER_WIDTH: positive := 16
		);
		port (
			init_state:   in  std_logic_vector(N - 1 downto 0);
			num_steps:    in  std_logic_vector(COUNTER_WIDTH - 1 downto 0);
			go:           in  std_logic;
			stream_ready: in  std_logic;
			state:        out std_logic_vector(N - 1 downto 0);
			state_valid:  out std_logic;
			state_last:   out std_logic;
			sim_done:     out std_logic;
			areset, clk:  in  std_logic
		);
	end component;

begin
	-- I/O Connections assignments
	M_AXIS_TVALID <= axis_tvalid;
	M_AXIS_TDATA  <= stream_data_out;
	M_AXIS_TLAST  <= axis_tlast;
	M_AXIS_TSTRB  <= (others => '1');

	-- provide standard reset signal (from AXI resetN)
	areset <= not M_AXIS_ARESETN;

	-- Control state machine implementation
	process (M_AXIS_ACLK)
	begin
		if rising_edge(M_AXIS_ACLK) then
			if(M_AXIS_ARESETN = '0') then
				-- Synchronous reset (active low)
				exec_state        <= IDLE;
				start_delay       <= C_M_START_COUNT;
				num_output_states <= (others => '0');
			else
				case (exec_state) is
					when IDLE =>
						-- only start a stream when 'start' port is raised
						if start = '1' then
							if start_delay > 0 then
								exec_state <= INIT_DELAY;
							else
								exec_state <= SEND_STREAM;
							end if;
							-- set output parameters on counter_start
							num_output_states <= num_steps;
						else
							exec_state <= IDLE;
						end if;

					when INIT_DELAY =>
						-- wait for C_M_START_COUNT clock cycles on first start
						if start_delay > 0 then
							start_delay <= start_delay - 1;
						else
							exec_state <= SEND_STREAM;
						end if;

					when SEND_STREAM =>
						-- if stream data was transmitted, go to next data point
						if M_AXIS_TREADY = '1' then
							-- move to idle if that was the last streamed data
							if axis_tlast = '1' then
								exec_state <= IDLE;
							end if;
						end if;

				end case;
			end if;
		end if;
	end process;

	dishsoap: dishsoap_ctrl
		generic map (
			N             => NETWORK_SIZE,
			COUNTER_WIDTH => C_S_AXI_DATA_WIDTH
		)
		port map(
			init_state   => init_state,
			num_steps    => num_output_states,
			go           => start,
			stream_ready => M_AXIS_TREADY,
			state        => sim_state,
			state_valid  => sim_state_valid,
			state_last   => sim_state_last,
			sim_done     => sim_done,
			areset       => areset,
			clk          => M_AXIS_ACLK
		);

	-- sim signal connections
	--go <= start; --TODO: unnecessary?
	stream_ready <= M_AXIS_TREADY;

	-- assert tvalid whenever we're currently in transmit state
	axis_tvalid <= '1' when ((exec_state = SEND_STREAM) and (sim_state_valid = '1'))
	               else '0';

	-- mark the last streamed data
	axis_tlast <= sim_state_last and sim_state_valid;

	-- the actual output stream data
	stream_data_out(NETWORK_SIZE-1 downto 0) <= sim_state;
	stream_data_out(C_M_AXIS_TDATA_WIDTH-1 downto NETWORK_SIZE) <= (others => '0');

end implementation;
