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
		dbg_tx_done:   out std_logic;
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
	-- function called clogb2 that returns an integer which has the
	-- value of the ceiling of the log base 2.
	function clogb2 (bit_depth: integer) return integer is
		variable depth: integer := bit_depth;
		variable count: integer := 1;
	begin
		-- Works for up to 32 bit integers
		for clogb2 in 1 to bit_depth loop
			if (bit_depth <= 2) then
				count := 1;
			else
				if(depth <= 1) then
					count := count;
				else
					depth := depth / 2;
					count := count + 1;
				end if;
			end if;
		end loop;
		return(count);
	end;

	 -- WAIT_COUNT_BITS is the width of the wait counter.
	constant WAIT_COUNT_BITS: integer := clogb2(C_M_START_COUNT-1);

	-- In this example, Depth of FIFO is determined by the greater of
	-- the number of input words and output words.
	--constant depth: integer := NUMBER_OF_OUTPUT_WORDS;

	-- bit_num gives the minimum number of bits needed to address 'depth' size of FIFO
	--constant bit_num: integer := clogb2(depth);

	-- Define the states of state machine
	-- The control state machine oversees the writing of input streaming data to the FIFO,
	-- and outputs the streaming data from the FIFO
	type state is (
		IDLE,         -- initial/idle state
		INIT_COUNTER, -- delay state, changes to SEND_STREAM once counter reaches C_M_START_COUNT
		SEND_STREAM   -- stream data is output through M_AXIS_TDATA
	);

	signal mst_exec_state: state;
	-- Example design FIFO read pointer
	signal read_pointer: integer range 0 to 2**COUNTER_WIDTH - 1;

	-- AXI Stream internal signals
	--wait counter. The master waits for the user defined number of clock cycles before initiating a transfer.
	signal count: std_logic_vector(WAIT_COUNT_BITS-1 downto 0);
	--streaming data valid
	signal axis_tvalid: std_logic;
	--streaming data valid delayed by one clock cycle
	signal axis_tvalid_delay: std_logic;
	--Last of the streaming data
	signal axis_tlast: std_logic;
	--Last of the streaming data delayed by one clock cycle
	signal axis_tlast_delay: std_logic;
	--FIFO implementation signals
	signal stream_data_out: std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
	signal tx_en: std_logic;
	--The master has issued all the streaming data stored in FIFO
	signal tx_done: std_logic;

	-- custom signals
	signal first_output_word, num_output_words: unsigned(COUNTER_WIDTH-1 downto 0);

begin
	-- I/O Connections assignments
	M_AXIS_TVALID <= axis_tvalid_delay;
	M_AXIS_TDATA  <= stream_data_out;
	M_AXIS_TLAST  <= axis_tlast_delay;
	M_AXIS_TSTRB  <= (others => '1');

	-- Control state machine implementation
	process(M_AXIS_ACLK)
	begin
		if (rising_edge (M_AXIS_ACLK)) then
			if(M_AXIS_ARESETN = '0') then
				-- Synchronous reset (active low)
				mst_exec_state <= IDLE;
				count <= (others => '0');
				num_output_words <= (others => '0');
				first_output_word <= (others => '0');
			else
				case (mst_exec_state) is
					when IDLE =>
						-- only start a transaction when counter_start is raised
						if counter_start = '1' then
							mst_exec_state <= INIT_COUNTER;
							-- output range is latched in with counter_start
							num_output_words <= unsigned(counter_hi) - unsigned(counter_lo) + 1;
							first_output_word <= unsigned(counter_lo);
						else
							mst_exec_state <= IDLE;
						end if;
					when INIT_COUNTER =>
						-- wait for C_M_START_COUNT number of clock cycles
						if ( count = std_logic_vector(to_unsigned((C_M_START_COUNT - 1), WAIT_COUNT_BITS))) then
							mst_exec_state <= SEND_STREAM;
						else
							count <= std_logic_vector (unsigned(count) + 1);
							mst_exec_state <= INIT_COUNTER;
						end if;
					when SEND_STREAM =>
						-- example design functionality starts when the master drives output tdata
						-- from the FIFO and the slave has finished storing the S_AXIS_TDATA
						if (tx_done = '1') then
							mst_exec_state <= IDLE;
						else
							mst_exec_state <= SEND_STREAM;
						end if;
					when others =>
						mst_exec_state <= IDLE;
				end case;
			end if;
		end if;
	end process;

	--tvalid generation
	--axis_tvalid is asserted when the control state machine's state is SEND_STREAM and
	--number of output streaming data is less than the num_output_words.
	axis_tvalid <= '1' when ((mst_exec_state = SEND_STREAM) and (read_pointer < num_output_words)) else '0';

	-- AXI tlast generation
	-- axis_tlast is asserted number of output streaming data is num_output_words-1
	-- (0 to num_output_words-1)
	axis_tlast <= '1' when (read_pointer = num_output_words-1) else '0';

	-- Delay the axis_tvalid and axis_tlast signal by one clock cycle
	-- to match the latency of M_AXIS_TDATA
	process(M_AXIS_ACLK)
	begin
		if (rising_edge (M_AXIS_ACLK)) then
			if(M_AXIS_ARESETN = '0') then
				axis_tvalid_delay <= '0';
				axis_tlast_delay <= '0';
			else
				axis_tvalid_delay <= axis_tvalid;
				axis_tlast_delay <= axis_tlast;
			end if;
		end if;
	end process;


	--read_pointer increment
	process(M_AXIS_ACLK)
	begin
		if (rising_edge (M_AXIS_ACLK)) then
			if(M_AXIS_ARESETN = '0') then
				read_pointer <= 0;
				tx_done <= '0';
			elsif (read_pointer <= num_output_words-1) and (tx_en = '1') then
				-- read pointer is incremented after every read from the FIFO
				-- when FIFO read signal is enabled.
				read_pointer <= read_pointer + 1;
				tx_done <= '0';
			else
				-- tx_done is asserted when num_output_words of streaming data has been sent
				tx_done <= '1';
			end if;
		end if;
	end process;


	--FIFO read enable generation
	tx_en <= M_AXIS_TREADY and axis_tvalid;

	-- FIFO Implementation
	-- Streaming output data is read from FIFO
	process(M_AXIS_ACLK)
		constant sig_one: unsigned(C_M_AXIS_TDATA_WIDTH-1 downto 0)
			:= (others => '1');
	begin
		if (rising_edge (M_AXIS_ACLK)) then
			if(M_AXIS_ARESETN = '0') then
				stream_data_out <= std_logic_vector(
					sig_one
				);
			elsif (tx_en = '1') then
				stream_data_out <= std_logic_vector(
					to_unsigned(read_pointer, C_M_AXIS_TDATA_WIDTH) + first_output_word
				);
			end if;
		end if;
	end process;
	
	--debug ports
	dbg_tvalid    <= axis_tvalid_delay;
	dbg_tlast     <= axis_tlast_delay;
	dbg_tready    <= M_AXIS_TREADY;
	dbg_cnt_start <= counter_start;
	dbg_pointer   <= std_logic_vector(to_unsigned(read_pointer, COUNTER_WIDTH));
	dbg_tx_done   <= tx_done;
	dbg_tx_en     <= tx_en;

end implementation;
-- vim: textwidth=100
