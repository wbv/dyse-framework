library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity count_stream_test_v0_1 is
	generic (
		-- Users to add parameters here
		COUNTER_WIDTH: natural := 8;
		-- User parameters ends
		--=====================================================--
		-- NOTE: Do not modify the parameters beyond this line --
		--=====================================================--
		-- Parameters of Axi Slave Bus Interface S_AXI_registers
		C_S_AXI_registers_DATA_WIDTH: integer := 32;
		C_S_AXI_registers_ADDR_WIDTH: integer := 4;
		-- Parameters of Axi Master Bus Interface M_AXIS_output
		C_M_AXIS_output_TDATA_WIDTH:  integer := 32;
		C_M_AXIS_output_START_COUNT:  integer := 32
	);
	port (
		-- Users to add ports here

		-- User ports ends
		--=====================================================--
		-- NOTE: Do not modify the parameters beyond this line --
		--=====================================================--

		-- Ports of Axi Slave Bus Interface S_AXI_registers
		s_axi_registers_aclk:     in  std_logic;
		s_axi_registers_aresetn:  in  std_logic;
		s_axi_registers_awaddr:   in  std_logic_vector(C_S_AXI_registers_ADDR_WIDTH-1 downto 0);
		s_axi_registers_awprot:   in  std_logic_vector(2 downto 0);
		s_axi_registers_awvalid:  in  std_logic;
		s_axi_registers_awready:  out std_logic;
		s_axi_registers_wdata:    in  std_logic_vector(C_S_AXI_registers_DATA_WIDTH-1 downto 0);
		s_axi_registers_wstrb:    in  std_logic_vector((C_S_AXI_registers_DATA_WIDTH/8)-1 downto 0);
		s_axi_registers_wvalid:   in  std_logic;
		s_axi_registers_wready:   out std_logic;
		s_axi_registers_bresp:    out std_logic_vector(1 downto 0);
		s_axi_registers_bvalid:   out std_logic;
		s_axi_registers_bready:   in  std_logic;
		s_axi_registers_araddr:   in  std_logic_vector(C_S_AXI_registers_ADDR_WIDTH-1 downto 0);
		s_axi_registers_arprot:   in  std_logic_vector(2 downto 0);
		s_axi_registers_arvalid:  in  std_logic;
		s_axi_registers_arready:  out std_logic;
		s_axi_registers_rdata:    out std_logic_vector(C_S_AXI_registers_DATA_WIDTH-1 downto 0);
		s_axi_registers_rresp:    out std_logic_vector(1 downto 0);
		s_axi_registers_rvalid:   out std_logic;
		s_axi_registers_rready:   in  std_logic;

		-- Ports of Axi Master Bus Interface M_AXIS_output
		m_axis_output_aclk:       in  std_logic;
		m_axis_output_aresetn:    in  std_logic;
		m_axis_output_tvalid:     out std_logic;
		m_axis_output_tdata:      out std_logic_vector(C_M_AXIS_output_TDATA_WIDTH-1 downto 0);
		m_axis_output_tstrb:      out std_logic_vector((C_M_AXIS_output_TDATA_WIDTH/8)-1 downto 0);
		m_axis_output_tlast:      out std_logic;
		m_axis_output_tready:     in  std_logic
	);
end count_stream_test_v0_1;

architecture behavior of count_stream_test_v0_1 is
	signal counter_lo:    std_logic_vector(COUNTER_WIDTH-1 downto 0);
	signal counter_hi:    std_logic_vector(COUNTER_WIDTH-1 downto 0);
	signal counter_start: std_logic;
	-- debugging ports
	signal dbg_tvalid:    std_logic;
	signal dbg_tlast:     std_logic;
	signal dbg_tready:    std_logic;
	signal dbg_cnt_start: std_logic;
	signal dbg_pointer:   std_logic_vector(COUNTER_WIDTH-1 downto 0);
	signal dbg_tx_done:   std_logic;
	signal dbg_tx_en:     std_logic;

	-- component declaration
	component count_stream_test_v0_1_S_AXI_registers is
		generic (
			-- Users to add parameters here
			COUNTER_WIDTH:      natural := COUNTER_WIDTH;
			-- User parameters ends
			C_S_AXI_DATA_WIDTH: integer := 32;
			C_S_AXI_ADDR_WIDTH: integer := 4
		);
		port (
			-- Users to add ports here
			counter_lo:    out std_logic_vector(COUNTER_WIDTH-1 downto 0);
			counter_hi:    out std_logic_vector(COUNTER_WIDTH-1 downto 0);
			counter_start: out std_logic;
			-- debugging ports
			dbg_tvalid:    in  std_logic;
			dbg_tlast:     in  std_logic;
			dbg_tready:    in  std_logic;
			dbg_cnt_start: in  std_logic;
			dbg_pointer:   in  std_logic_vector(COUNTER_WIDTH-1 downto 0);
			dbg_tx_done:   in  std_logic;
			dbg_tx_en:     in  std_logic;
			-- User ports ends
			S_AXI_ACLK:    in  std_logic;
			S_AXI_ARESETN: in  std_logic;
			S_AXI_AWADDR:  in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
			S_AXI_AWPROT:  in  std_logic_vector(2 downto 0);
			S_AXI_AWVALID: in  std_logic;
			S_AXI_AWREADY: out std_logic;
			S_AXI_WDATA:   in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			S_AXI_WSTRB:   in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
			S_AXI_WVALID:  in  std_logic;
			S_AXI_WREADY:  out std_logic;
			S_AXI_BRESP:   out std_logic_vector(1 downto 0);
			S_AXI_BVALID:  out std_logic;
			S_AXI_BREADY:  in  std_logic;
			S_AXI_ARADDR:  in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
			S_AXI_ARPROT:  in  std_logic_vector(2 downto 0);
			S_AXI_ARVALID: in  std_logic;
			S_AXI_ARREADY: out std_logic;
			S_AXI_RDATA:   out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			S_AXI_RRESP:   out std_logic_vector(1 downto 0);
			S_AXI_RVALID:  out std_logic;
			S_AXI_RREADY:  in  std_logic
		);
	end component count_stream_test_v0_1_S_AXI_registers;

	component count_stream_test_v0_1_M_AXIS_output is
		generic (
			-- Users to add parameters here
			COUNTER_WIDTH:        natural := 8;
			-- User parameters ends
			C_M_AXIS_TDATA_WIDTH: integer := 32;
			C_M_START_COUNT:      integer := 32
		);
		port (
			-- Users to add ports here
			counter_lo:     in  std_logic_vector(COUNTER_WIDTH-1 downto 0);
			counter_hi:     in  std_logic_vector(COUNTER_WIDTH-1 downto 0);
			counter_start:  in  std_logic;
			-- debugging ports
			dbg_tvalid:    out std_logic;
			dbg_tlast:     out std_logic;
			dbg_tready:    out std_logic;
			dbg_cnt_start: out std_logic;
			dbg_pointer:   out std_logic_vector(COUNTER_WIDTH-1 downto 0);
			dbg_tx_done:   out std_logic;
			dbg_tx_en:     out std_logic;
			-- User ports ends
			M_AXIS_ACLK:    in  std_logic;
			M_AXIS_ARESETN: in  std_logic;
			M_AXIS_TVALID:  out std_logic;
			M_AXIS_TDATA:   out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
			M_AXIS_TSTRB:   out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
			M_AXIS_TLAST:   out std_logic;
			M_AXIS_TREADY:  in  std_logic
		);
	end component count_stream_test_v0_1_M_AXIS_output;

begin

-- Instantiation of Axi Bus Interface S_AXI_registers
	count_stream_test_v0_1_S_AXI_registers_inst: count_stream_test_v0_1_S_AXI_registers
		generic map (
			COUNTER_WIDTH      => COUNTER_WIDTH,
			C_S_AXI_DATA_WIDTH => C_S_AXI_registers_DATA_WIDTH,
			C_S_AXI_ADDR_WIDTH => C_S_AXI_registers_ADDR_WIDTH
		)
		port map (
			counter_lo    => counter_lo,
			counter_hi    => counter_hi,
			counter_start => counter_start,
			dbg_tvalid    => dbg_tvalid,
			dbg_tlast     => dbg_tlast,
			dbg_tready    => dbg_tready,
			dbg_cnt_start => dbg_cnt_start,
			dbg_pointer   => dbg_pointer,
			dbg_tx_done   => dbg_tx_done,
			dbg_tx_en     => dbg_tx_en,
			S_AXI_ACLK    => s_axi_registers_aclk,
			S_AXI_ARESETN => s_axi_registers_aresetn,
			S_AXI_AWADDR  => s_axi_registers_awaddr,
			S_AXI_AWPROT  => s_axi_registers_awprot,
			S_AXI_AWVALID => s_axi_registers_awvalid,
			S_AXI_AWREADY => s_axi_registers_awready,
			S_AXI_WDATA   => s_axi_registers_wdata,
			S_AXI_WSTRB   => s_axi_registers_wstrb,
			S_AXI_WVALID  => s_axi_registers_wvalid,
			S_AXI_WREADY  => s_axi_registers_wready,
			S_AXI_BRESP   => s_axi_registers_bresp,
			S_AXI_BVALID  => s_axi_registers_bvalid,
			S_AXI_BREADY  => s_axi_registers_bready,
			S_AXI_ARADDR  => s_axi_registers_araddr,
			S_AXI_ARPROT  => s_axi_registers_arprot,
			S_AXI_ARVALID => s_axi_registers_arvalid,
			S_AXI_ARREADY => s_axi_registers_arready,
			S_AXI_RDATA   => s_axi_registers_rdata,
			S_AXI_RRESP   => s_axi_registers_rresp,
			S_AXI_RVALID  => s_axi_registers_rvalid,
			S_AXI_RREADY  => s_axi_registers_rready
		);

	-- Instantiation of Axi Bus Interface M_AXIS_output
	count_stream_test_v0_1_M_AXIS_output_inst: count_stream_test_v0_1_M_AXIS_output
		generic map (
			COUNTER_WIDTH        => COUNTER_WIDTH,
			C_M_AXIS_TDATA_WIDTH => C_M_AXIS_output_TDATA_WIDTH,
			C_M_START_COUNT      => C_M_AXIS_output_START_COUNT
		)
		port map (
			counter_lo     => counter_lo,
			counter_hi     => counter_hi,
			counter_start  => counter_start,
			dbg_tvalid     => dbg_tvalid,
			dbg_tlast      => dbg_tlast,
			dbg_tready     => dbg_tready,
			dbg_cnt_start  => dbg_cnt_start,
			dbg_pointer    => dbg_pointer,
			dbg_tx_done    => dbg_tx_done,
			dbg_tx_en      => dbg_tx_en,
			M_AXIS_ACLK    => m_axis_output_aclk,
			M_AXIS_ARESETN => m_axis_output_aresetn,
			M_AXIS_TVALID  => m_axis_output_tvalid,
			M_AXIS_TDATA   => m_axis_output_tdata,
			M_AXIS_TSTRB   => m_axis_output_tstrb,
			M_AXIS_TLAST   => m_axis_output_tlast,
			M_AXIS_TREADY  => m_axis_output_tready
		);

end behavior;
