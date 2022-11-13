library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity count_stream_test_tb is end entity;

architecture test of count_stream_test_tb is

	--|===================================|--
	--| Unit-Under Test (UUT) definitions |--
	--|===================================|--

	component count_stream_test_v0_1
		generic (
			-- User parameter
			COUNTER_WIDTH: natural := 8;
			-- Parameters of Axi Slave Bus Interface S_AXI_registers
			C_S_AXI_registers_DATA_WIDTH: integer := 32;
			C_S_AXI_registers_ADDR_WIDTH: integer := 4;
			-- Parameters of Axi Master Bus Interface M_AXIS_output
			C_M_AXIS_output_TDATA_WIDTH:  integer := 32;
			C_M_AXIS_output_START_COUNT:  integer := 32
		);
		port (
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
	end component;

	for uut: count_stream_test_v0_1 use entity work.count_stream_test_v0_1;

	signal s_axi_registers_aclk:     std_logic;
	signal s_axi_registers_aresetn:  std_logic;
	signal s_axi_registers_awaddr:   std_logic_vector(C_S_AXI_registers_ADDR_WIDTH-1 downto 0);
	signal s_axi_registers_awprot:   std_logic_vector(2 downto 0);
	signal s_axi_registers_awvalid:  std_logic;
	signal s_axi_registers_awready:  std_logic;
	signal s_axi_registers_wdata:    std_logic_vector(C_S_AXI_registers_DATA_WIDTH-1 downto 0);
	signal s_axi_registers_wstrb:    std_logic_vector((C_S_AXI_registers_DATA_WIDTH/8)-1 downto 0);
	signal s_axi_registers_wvalid:   std_logic;
	signal s_axi_registers_wready:   std_logic;
	signal s_axi_registers_bresp:    std_logic_vector(1 downto 0);
	signal s_axi_registers_bvalid:   std_logic;
	signal s_axi_registers_bready:   std_logic;
	signal s_axi_registers_araddr:   std_logic_vector(C_S_AXI_registers_ADDR_WIDTH-1 downto 0);
	signal s_axi_registers_arprot:   std_logic_vector(2 downto 0);
	signal s_axi_registers_arvalid:  std_logic;
	signal s_axi_registers_arready:  std_logic;
	signal s_axi_registers_rdata:    std_logic_vector(C_S_AXI_registers_DATA_WIDTH-1 downto 0);
	signal s_axi_registers_rresp:    std_logic_vector(1 downto 0);
	signal s_axi_registers_rvalid:   std_logic;
	signal s_axi_registers_rready:   std_logic;
	signal -- Ports of Axi Master Bus Interface M_AXIS_output
	signal m_axis_output_aclk:       std_logic;
	signal m_axis_output_aresetn:    std_logic;
	signal m_axis_output_tvalid:     std_logic;
	signal m_axis_output_tdata:      std_logic_vector(C_M_AXIS_output_TDATA_WIDTH-1 downto 0);
	signal m_axis_output_tstrb:      std_logic_vector((C_M_AXIS_output_TDATA_WIDTH/8)-1 downto 0);
	signal m_axis_output_tlast:      std_logic;
	signal m_axis_output_tready:     std_logic;

	--|=======================|--
	--| Custom Helper Signals |--
	--|=======================|--

	signal resetn: std_logic;

	--|======================|--
	--| Generic Test Signals |--
	--|======================|--

	-- clock starts high to align rising edge to CLK_PERIOD intervals
	signal clk: std_logic := '1';

	-- flag for test completion
	shared variable test_complete : boolean := false;

	-- period for the main testbench's clock
	constant CLK_PERIOD: time := 10 ns;

begin
	
	uut: count_stream_test_v0_1
		generic map
			COUNTER_WIDTH => 8,
			-- Parameters of Axi Slave Bus Interface S_AXI_registers
			C_S_AXI_registers_DATA_WIDTH => 32,
			C_S_AXI_registers_ADDR_WIDTH => 4,
			-- Parameters of Axi Master Bus Interface M_AXIS_output
			C_M_AXIS_output_TDATA_WIDTH => 64,
			C_M_AXIS_output_START_COUNT => 16
		)
		port (
			-- Ports of Axi Slave Bus Interface S_AXI_registers
			s_axi_registers_aclk      => clk,
			s_axi_registers_aresetn   => s_axi_registers_aresetn,
			s_axi_registers_awaddr    => s_axi_registers_awaddr,
			s_axi_registers_awprot    => s_axi_registers_awprot,
			s_axi_registers_awvalid   => s_axi_registers_awvalid,
			s_axi_registers_awready   => s_axi_registers_awready,
			s_axi_registers_wdata     => s_axi_registers_wdata,
			s_axi_registers_wstrb     => s_axi_registers_wstrb,
			s_axi_registers_wvalid    => s_axi_registers_wvalid,
			s_axi_registers_wready    => s_axi_registers_wready,
			s_axi_registers_bresp     => s_axi_registers_bresp,
			s_axi_registers_bvalid    => s_axi_registers_bvalid,
			s_axi_registers_bready    => s_axi_registers_bready,
			s_axi_registers_araddr    => s_axi_registers_araddr,
			s_axi_registers_arprot    => s_axi_registers_arprot,
			s_axi_registers_arvalid   => s_axi_registers_arvalid,
			s_axi_registers_arready   => s_axi_registers_arready,
			s_axi_registers_rdata     => s_axi_registers_rdata,
			s_axi_registers_rresp     => s_axi_registers_rresp,
			s_axi_registers_rvalid    => s_axi_registers_rvalid,
			s_axi_registers_rready    => s_axi_registers_rready,
			-- Ports of Axi Master Bus Interface M_AXIS_output
			m_axis_output_aclk        => clk,
			m_axis_output_aresetn     => m_axis_output_aresetn,
			m_axis_output_tvalid      => m_axis_output_tvalid,
			m_axis_output_tdata       => m_axis_output_tdata,
			m_axis_output_tstrb       => m_axis_output_tstrb,
			m_axis_output_tlast       => m_axis_output_tlast,
			m_axis_output_tready      => m_axis_output_tready
		);

-- clock: oscillate until test_complete
clock: process
begin
	if test_complete = true then
		-- assert "undetermined" signal when done, for fun
		clk <= 'U';
		wait for CLK_PERIOD;
		wait;
	end if;

	wait for (CLK_PERIOD/2);
	clk <= not clk;
end process clock;


-- the main testbench
tb: process
begin
	-- initial states
	en <= '0';
	resetn <= '1';

	wait for CLK_PERIOD;
	resetn <= '0';
	wait for CLK_PERIOD;
	resetn <= '1';

	assert state = "0000"
		report "RST did not reset state";

	wait for CLK_PERIOD;
	test_complete := true;
	wait;
end process tb;

end test;
