#===================================================#
# @file generate.tcl                                #
#                                                   #
# generates the DiSHSOAP Vivado project from source #
#===================================================#

source config.tcl


# set script_folder to current working directory
namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

# check if script is running in correct Vivado version
set scripts_vivado_version 2022.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "INFO" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. This may cause problems with IP availability and configuration."}
}

# create the project file if not already open
set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project ${overlay_name} ${overlay_name} -part ${target_part}
}

# set project's IP Catalog location
set_property  ip_repo_paths  ../ip [current_project]
update_ip_catalog

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\
xilinx.com:ip:processing_system7:5.5\
xilinx.com:ip:axi_dma:7.1\
wbv:user:dishsoap:0.1\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

#========#
# Design #
#========#

# project properties
set_property target_language VHDL [current_project]

# Create IP blocks, only changing defaults as needed

# AXI DMA block
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0
set_property -dict [list \
	CONFIG.c_m_axi_s2mm_data_width.VALUE_SRC USER \
	CONFIG.c_s_axis_s2mm_tdata_width.VALUE_SRC USER\
] [get_bd_cells axi_dma_0]
set_property -dict [list \
	CONFIG.c_include_sg {0} \
	CONFIG.c_sg_length_width {26} \
	CONFIG.c_sg_include_stscntrl_strm {0} \
	CONFIG.c_include_mm2s {0} \
	CONFIG.c_m_axi_s2mm_data_width {64} \
	CONFIG.c_s_axis_s2mm_tdata_width {64} \
	CONFIG.c_s2mm_burst_size {256} \
	CONFIG.c_addr_width {64}\
] [get_bd_cells axi_dma_0]

# Zynq PS7 block
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
set_property -dict [list \
	CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {133} \
	CONFIG.PCW_USE_S_AXI_HP0 {1} \
	CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
	CONFIG.PCW_IRQ_F2P_INTR {1} \
	CONFIG.PCW_FCLK0_PERIPHERAL_CLKSRC {DDR PLL} \
] [get_bd_cells processing_system7_0]

# DiSHSOAP block
create_bd_cell -type ip -vlnv wbv:user:dishsoap:0.1 dishsoap_0
set_property -dict [list \
	CONFIG.C_REGS_AXI_ADDR_WIDTH {8} \
] [get_bd_cells dishsoap_0]


# Apply board automation to create interconnects and connections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { \
	Clk_master {/processing_system7_0/FCLK_CLK0 (133 MHz)} \
	Clk_slave {/processing_system7_0/FCLK_CLK0 (133 MHz)} \
	Clk_xbar {/processing_system7_0/FCLK_CLK0 (133 MHz)} \
	Master {/processing_system7_0/M_AXI_GP0} \
	Slave {/axi_dma_0/S_AXI_LITE} \
	ddr_seg {Auto} \
	intc_ip {New AXI Interconnect} \
	master_apm {0} \
} [get_bd_intf_pins axi_dma_0/S_AXI_LITE]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { \
	Clk_master {/processing_system7_0/FCLK_CLK0 (133 MHz)} \
	Clk_slave {/processing_system7_0/FCLK_CLK0 (133 MHz)} \
	Clk_xbar {/processing_system7_0/FCLK_CLK0 (133 MHz)} \
	Master {/axi_dma_0/M_AXI_S2MM} \
	Slave {/processing_system7_0/S_AXI_HP0} \
	ddr_seg {Auto} \
	intc_ip {New AXI Interconnect} \
	master_apm {0} \
} [get_bd_intf_pins processing_system7_0/S_AXI_HP0]

apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config { \
	make_external "FIXED_IO, DDR" \
	Master "Disable" \
	Slave "Disable" \
} [get_bd_cells processing_system7_0]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { \
	Clk_master {/processing_system7_0/FCLK_CLK0 (133 MHz)} \
	Clk_slave {Auto} \
	Clk_xbar {/processing_system7_0/FCLK_CLK0 (133 MHz)} \
	Master {/processing_system7_0/M_AXI_GP0} \
	Slave {/dishsoap_0/REGS_AXI} \
	ddr_seg {Auto} \
	intc_ip {/ps7_0_axi_periph} \
	master_apm {0} \
} [get_bd_intf_pins dishsoap_0/REGS_AXI]

# connect dishsoap and axi_dma manually
connect_bd_intf_net [get_bd_intf_pins dishsoap_0/SIM_STATE_AXIS] [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM]
# also add DMA interrupt pin
connect_bd_net [get_bd_pins axi_dma_0/s2mm_introut] [get_bd_pins processing_system7_0/IRQ_F2P]

# but autoapply the clk and reset pins
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config { \
	Clk {/processing_system7_0/FCLK_CLK0 (133 MHz)} \
	Freq {100} \
	Ref_Clk0 {} \
	Ref_Clk1 {} \
	Ref_Clk2 {} \
} [get_bd_pins dishsoap_0/sim_state_aclk]

# validate and save the final design
validate_bd_design
save_bd_design

# autogenerate and add VHDL wrapper for board design as top-level module
make_wrapper -files [get_files ./${overlay_name}/${overlay_name}.srcs/sources_1/bd/${design_name}/${design_name}.bd] -top
add_files -norecurse ./${overlay_name}/${overlay_name}.srcs/sources_1/bd/${design_name}/hdl/${design_name}_wrapper.vhd
set_property top ${design_name}_wrapper [current_fileset]

# import constraints file
import_files -fileset constrs_1 -norecurse "../constraintfiles/pynq-z2-v1.0.xdc"
update_compile_order -fileset sources_1

close_project
