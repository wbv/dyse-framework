library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dishsoap_v0_1 is
	generic (
		-- User parameters here
		NETWORK_SIZE: positive := 3;
		--=====================================================--
		-- NOTE: Do not modify the parameters beyond this line --
		--=====================================================--
		-- Parameters of Axi Slave Bus Interface REGS_AXI
		C_REGS_AXI_DATA_WIDTH: integer := 64;
		C_REGS_AXI_ADDR_WIDTH: integer := 6;
		-- Parameters of Axi Master Bus Interface SIM_STATE_AXIS
		C_SIM_STATE_AXIS_TDATA_WIDTH: integer := 64;
		C_SIM_STATE_AXIS_START_COUNT: integer := 32
	);
	port (
		-- Users to add ports here

		--=====================================================--
		-- NOTE: Do not modify the parameters beyond this line --
		--=====================================================--
		-- Ports of Axi Slave Bus Interface REGS_AXI
		regs_axi_aclk:      in  std_logic;
		regs_axi_aresetn:   in  std_logic;
		regs_axi_awaddr:    in  std_logic_vector(C_REGS_AXI_ADDR_WIDTH-1 downto 0);
		regs_axi_awprot:    in  std_logic_vector(2 downto 0);
		regs_axi_awvalid:   in  std_logic;
		regs_axi_awready:   out std_logic;
		regs_axi_wdata:     in  std_logic_vector(C_REGS_AXI_DATA_WIDTH-1 downto 0);
		regs_axi_wstrb:     in  std_logic_vector((C_REGS_AXI_DATA_WIDTH/8)-1 downto 0);
		regs_axi_wvalid:    in  std_logic;
		regs_axi_wready:    out std_logic;
		regs_axi_bresp:     out std_logic_vector(1 downto 0);
		regs_axi_bvalid:    out std_logic;
		regs_axi_bready:    in  std_logic;
		regs_axi_araddr:    in  std_logic_vector(C_REGS_AXI_ADDR_WIDTH-1 downto 0);
		regs_axi_arprot:    in  std_logic_vector(2 downto 0);
		regs_axi_arvalid:   in  std_logic;
		regs_axi_arready:   out std_logic;
		regs_axi_rdata:     out std_logic_vector(C_REGS_AXI_DATA_WIDTH-1 downto 0);
		regs_axi_rresp:     out std_logic_vector(1 downto 0);
		regs_axi_rvalid:    out std_logic;
		regs_axi_rready:    in  std_logic;
		-- Ports of Axi Master Bus Interface SIM_STATE_AXIS
		sim_state_aclk:     in  std_logic;
		sim_state_aresetn:  in  std_logic;
		sim_state_tvalid:   out std_logic;
		sim_state_tdata:    out std_logic_vector(C_SIM_STATE_AXIS_TDATA_WIDTH-1 downto 0);
		sim_state_tstrb:    out std_logic_vector((C_SIM_STATE_AXIS_TDATA_WIDTH/8)-1 downto 0);
		sim_state_tlast:    out std_logic;
		sim_state_tready:   in  std_logic
	);
end dishsoap_v0_1;

architecture behavior of dishsoap_v0_1 is
	-- intermediate signals
	signal init_state:     std_logic_vector(C_REGS_AXI_DATA_WIDTH-1 downto 0);
	signal num_steps:      std_logic_vector(C_REGS_AXI_DATA_WIDTH-1 downto 0);
	signal start:          std_logic;
	signal ready:          std_logic;

	-- DEBUG
	signal dbg_reg0:      std_logic_vector(C_REGS_AXI_DATA_WIDTH-1 downto 0);
	signal dbg_reg1:      std_logic_vector(C_REGS_AXI_DATA_WIDTH-1 downto 0);
	signal dbg_reg2:      std_logic_vector(C_REGS_AXI_DATA_WIDTH-1 downto 0);
	signal dbg_reg3:      std_logic_vector(C_REGS_AXI_DATA_WIDTH-1 downto 0);

	-- component declaration
	component dishsoap_v0_1_REGS_AXI is
		generic (
			C_S_AXI_DATA_WIDTH: integer := C_REGS_AXI_DATA_WIDTH;
			C_S_AXI_ADDR_WIDTH: integer := C_REGS_AXI_ADDR_WIDTH
		);
		port (
			ready:          in  std_logic;
			start:          out std_logic;
			init_state:     out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			num_steps:      out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			-- DEBUG
			dbg_reg0:       in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			dbg_reg1:       in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			dbg_reg2:       in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			dbg_reg3:       in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			-- original ports
			S_AXI_ACLK:     in  std_logic;
			S_AXI_ARESETN:  in  std_logic;
			S_AXI_AWADDR:   in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
			S_AXI_AWPROT:   in  std_logic_vector(2 downto 0);
			S_AXI_AWVALID:  in  std_logic;
			S_AXI_AWREADY:  out std_logic;
			S_AXI_WDATA:    in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			S_AXI_WSTRB:    in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
			S_AXI_WVALID:   in  std_logic;
			S_AXI_WREADY:   out std_logic;
			S_AXI_BRESP:    out std_logic_vector(1 downto 0);
			S_AXI_BVALID:   out std_logic;
			S_AXI_BREADY:   in  std_logic;
			S_AXI_ARADDR:   in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
			S_AXI_ARPROT:   in  std_logic_vector(2 downto 0);
			S_AXI_ARVALID:  in  std_logic;
			S_AXI_ARREADY:  out std_logic;
			S_AXI_RDATA:    out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			S_AXI_RRESP:    out std_logic_vector(1 downto 0);
			S_AXI_RVALID:   out std_logic;
			S_AXI_RREADY:   in  std_logic
		);
	end component dishsoap_v0_1_REGS_AXI;

	component dishsoap_v0_1_SIM_STATE_AXIS is
		generic (
			NETWORK_SIZE:          natural := 3;
			C_S_AXI_DATA_WIDTH:    integer := C_REGS_AXI_DATA_WIDTH;
			-- original ports:
			C_M_AXIS_TDATA_WIDTH:  integer := C_SIM_STATE_AXIS_TDATA_WIDTH;
			C_M_START_COUNT:       integer := C_SIM_STATE_AXIS_START_COUNT
		);
		port (
			init_state:      in  std_logic_vector(NETWORK_SIZE-1 downto 0);
			num_steps:       in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			start:           in  std_logic;
			ready:           out std_logic;
			-- DEBUG
			dbg_reg0:        out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			dbg_reg1:        out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			dbg_reg2:        out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			dbg_reg3:        out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			-- original ports:
			M_AXIS_ACLK:     in  std_logic;
			M_AXIS_ARESETN:  in  std_logic;
			M_AXIS_TVALID:   out std_logic;
			M_AXIS_TDATA:    out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
			M_AXIS_TSTRB:    out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
			M_AXIS_TLAST:    out std_logic;
			M_AXIS_TREADY:   in  std_logic
		);
	end component dishsoap_v0_1_SIM_STATE_AXIS;
begin

-- REGS_AXI
	regs: dishsoap_v0_1_REGS_AXI
		generic map (
			C_S_AXI_DATA_WIDTH => C_REGS_AXI_DATA_WIDTH,
			C_S_AXI_ADDR_WIDTH => C_REGS_AXI_ADDR_WIDTH
		)
		port map (
			ready         => ready,
			start         => start,
			num_steps     => num_steps,
			init_state    => init_state,
			-- DEBUG
			dbg_reg0      => dbg_reg0,
			dbg_reg1      => dbg_reg1,
			dbg_reg2      => dbg_reg2,
			dbg_reg3      => dbg_reg3,
			-- original ports
			S_AXI_ACLK    => regs_axi_aclk,
			S_AXI_ARESETN => regs_axi_aresetn,
			S_AXI_AWADDR  => regs_axi_awaddr,
			S_AXI_AWPROT  => regs_axi_awprot,
			S_AXI_AWVALID => regs_axi_awvalid,
			S_AXI_AWREADY => regs_axi_awready,
			S_AXI_WDATA   => regs_axi_wdata,
			S_AXI_WSTRB   => regs_axi_wstrb,
			S_AXI_WVALID  => regs_axi_wvalid,
			S_AXI_WREADY  => regs_axi_wready,
			S_AXI_BRESP   => regs_axi_bresp,
			S_AXI_BVALID  => regs_axi_bvalid,
			S_AXI_BREADY  => regs_axi_bready,
			S_AXI_ARADDR  => regs_axi_araddr,
			S_AXI_ARPROT  => regs_axi_arprot,
			S_AXI_ARVALID => regs_axi_arvalid,
			S_AXI_ARREADY => regs_axi_arready,
			S_AXI_RDATA   => regs_axi_rdata,
			S_AXI_RRESP   => regs_axi_rresp,
			S_AXI_RVALID  => regs_axi_rvalid,
			S_AXI_RREADY  => regs_axi_rready
		);

-- SIM_STATE_AXIS
	sim: dishsoap_v0_1_SIM_STATE_AXIS
		generic map (
			NETWORK_SIZE         => 3,
			C_S_AXI_DATA_WIDTH   => C_REGS_AXI_DATA_WIDTH,
			-- original ports:
			C_M_AXIS_TDATA_WIDTH => C_SIM_STATE_AXIS_TDATA_WIDTH,
			C_M_START_COUNT      => C_SIM_STATE_AXIS_START_COUNT
		)
		port map (
			init_state     => init_state(NETWORK_SIZE-1 downto 0),
			num_steps      => num_steps,
			start          => start,
			ready          => ready,
			-- DEBUG
			dbg_reg0       => dbg_reg0,
			dbg_reg1       => dbg_reg1,
			dbg_reg2       => dbg_reg2,
			dbg_reg3       => dbg_reg3,
			-- original ports:
			M_AXIS_ACLK    => sim_state_aclk,
			M_AXIS_ARESETN => sim_state_aresetn,
			M_AXIS_TVALID  => sim_state_tvalid,
			M_AXIS_TDATA   => sim_state_tdata,
			M_AXIS_TSTRB   => sim_state_tstrb,
			M_AXIS_TLAST   => sim_state_tlast,
			M_AXIS_TREADY  => sim_state_tready
		);

end behavior;
