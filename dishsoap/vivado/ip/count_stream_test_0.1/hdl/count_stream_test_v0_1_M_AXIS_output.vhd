library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity count_stream_test_v0_1_M_AXIS_output is
	generic (
		-- Users to add parameters here
		COUNTER_WIDTH: natural range 2 to 16 := 8;
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXIS address bus.
		-- The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
		C_M_AXIS_TDATA_WIDTH: integer := 32;
		-- Start count is the number of clock cycles the master will wait before initiating/issuing any transaction.
		C_M_START_COUNT:      integer := 32
	);
	port (
		-- Users to add ports here
		counter_lo:    in  std_logic_vector(COUNTER_WIDTH-1 downto 0);
		counter_hi:    in  std_logic_vector(COUNTER_WIDTH-1 downto 0);
		counter_start: in  std_logic;
		-- debugging ports
		dbg_tvalid:    out std_logic;
		dbg_tlast:     out std_logic;
		dbg_tready:    out std_logic;
		dbg_cnt_start: out std_logic;
		dbg_pointer:   out std_logic_vector(COUNTER_WIDTH-1 downto 0);
		dbg_tx_en:     out std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Global ports
		M_AXIS_ACLK: in std_logic;
		M_AXIS_ARESETN: in std_logic;
		-- Master Stream Ports.
		-- TVALID indicates that the master is driving a -- valid transfer, A
		-- transfer takes place when both TVALID and TREADY are asserted.
		M_AXIS_TVALID: out std_logic;
		-- TDATA is the primary payload that is used to provide the data that is
		-- passing across the interface from the master.
		M_AXIS_TDATA: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		-- TSTRB is the byte qualifier that indicates whether the content of the
		-- associated byte of TDATA is processed as a data byte or position byte.
		M_AXIS_TSTRB: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		-- TLAST indicates the boundary of a packet.
		M_AXIS_TLAST: out std_logic;
		-- TREADY indicates that the slave can accept a transfer in the current cycle.
		M_AXIS_TREADY: in std_logic
	);
end count_stream_test_v0_1_M_AXIS_output;

architecture implementation of count_stream_test_v0_1_M_AXIS_output is
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
	-- indicates slave is ready and we're transmitting
	signal tx_en: std_logic;

	-- output controls
	signal first_output_word, num_output_words: unsigned(COUNTER_WIDTH-1 downto 0);
	signal word_offset: unsigned(COUNTER_WIDTH-1 downto 0);

begin
	-- I/O Connections assignments
	M_AXIS_TVALID <= axis_tvalid;
	M_AXIS_TDATA  <= stream_data_out;
	M_AXIS_TLAST  <= axis_tlast;
	M_AXIS_TSTRB  <= (others => '1');

	-- Control state machine implementation
	process (M_AXIS_ACLK)
	begin
		if rising_edge(M_AXIS_ACLK) then
			if(M_AXIS_ARESETN = '0') then
				-- Synchronous reset (active low)
				exec_state        <= IDLE;
				start_delay       <= C_M_START_COUNT;
				num_output_words  <= (others => '0');
				first_output_word <= (others => '0');
				word_offset       <= (others => '1');
			else
				case (exec_state) is
					when IDLE =>
						-- only start a transaction when counter_start is raised
						if counter_start = '1' then
							if start_delay > 0 then
								exec_state <= INIT_DELAY;
							else
								exec_state <= SEND_STREAM;
							end if;
							-- set output parameters on counter_start
							word_offset       <= (others => '0');
							num_output_words  <= unsigned(counter_hi) - unsigned(counter_lo) + 1;
							first_output_word <= unsigned(counter_lo);
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
							-- increment the word_offset if we're continuing
							word_offset <= word_offset + 1;
							-- move to idle if that was the last streamed data
							if axis_tlast = '1' then
								exec_state <= IDLE;
							end if;
						end if;

				end case;
			end if;
		end if;
	end process;

	-- assert tvalid whenever we're currently in transmit state
	axis_tvalid <= '1' when (exec_state = SEND_STREAM) else '0';

	-- mark the last streamed data
	axis_tlast <= '1' when (word_offset = num_output_words-1) else '0';

	-- indicates this is will be a succesfful stream word
	tx_en <= M_AXIS_TREADY and axis_tvalid;

	-- the actual output stream data
	stream_data_out(COUNTER_WIDTH-1        downto 0)             <= std_logic_vector(word_offset + first_output_word);
	stream_data_out(C_M_AXIS_TDATA_WIDTH-1 downto COUNTER_WIDTH) <= (others => '0');
	
	--debug ports
	dbg_tvalid    <= axis_tvalid;
	dbg_tlast     <= axis_tlast;
	dbg_tready    <= M_AXIS_TREADY;
	dbg_cnt_start <= counter_start;
	dbg_pointer   <= std_logic_vector(word_offset);
	dbg_tx_en     <= tx_en;

end implementation;
