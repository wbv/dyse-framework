# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_REGS_AXI_BASEADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_REGS_AXI_HIGHADDR" -parent ${Page_0}

  ipgui::add_param $IPINST -name "NETWORK_SIZE"
  ipgui::add_param $IPINST -name "C_REGS_AXI_DATA_WIDTH"
  ipgui::add_param $IPINST -name "C_REGS_AXI_ADDR_WIDTH"
  ipgui::add_param $IPINST -name "C_SIM_STATE_AXIS_TDATA_WIDTH"
  ipgui::add_param $IPINST -name "C_SIM_STATE_AXIS_START_COUNT"

}

proc update_PARAM_VALUE.C_REGS_AXI_ADDR_WIDTH { PARAM_VALUE.C_REGS_AXI_ADDR_WIDTH } {
	# Procedure called to update C_REGS_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_REGS_AXI_ADDR_WIDTH { PARAM_VALUE.C_REGS_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_REGS_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_REGS_AXI_DATA_WIDTH { PARAM_VALUE.C_REGS_AXI_DATA_WIDTH } {
	# Procedure called to update C_REGS_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_REGS_AXI_DATA_WIDTH { PARAM_VALUE.C_REGS_AXI_DATA_WIDTH } {
	# Procedure called to validate C_REGS_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_SIM_STATE_AXIS_START_COUNT { PARAM_VALUE.C_SIM_STATE_AXIS_START_COUNT } {
	# Procedure called to update C_SIM_STATE_AXIS_START_COUNT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_SIM_STATE_AXIS_START_COUNT { PARAM_VALUE.C_SIM_STATE_AXIS_START_COUNT } {
	# Procedure called to validate C_SIM_STATE_AXIS_START_COUNT
	return true
}

proc update_PARAM_VALUE.C_SIM_STATE_AXIS_TDATA_WIDTH { PARAM_VALUE.C_SIM_STATE_AXIS_TDATA_WIDTH } {
	# Procedure called to update C_SIM_STATE_AXIS_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_SIM_STATE_AXIS_TDATA_WIDTH { PARAM_VALUE.C_SIM_STATE_AXIS_TDATA_WIDTH } {
	# Procedure called to validate C_SIM_STATE_AXIS_TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.NETWORK_SIZE { PARAM_VALUE.NETWORK_SIZE } {
	# Procedure called to update NETWORK_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NETWORK_SIZE { PARAM_VALUE.NETWORK_SIZE } {
	# Procedure called to validate NETWORK_SIZE
	return true
}

proc update_PARAM_VALUE.C_REGS_AXI_BASEADDR { PARAM_VALUE.C_REGS_AXI_BASEADDR } {
	# Procedure called to update C_REGS_AXI_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_REGS_AXI_BASEADDR { PARAM_VALUE.C_REGS_AXI_BASEADDR } {
	# Procedure called to validate C_REGS_AXI_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_REGS_AXI_HIGHADDR { PARAM_VALUE.C_REGS_AXI_HIGHADDR } {
	# Procedure called to update C_REGS_AXI_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_REGS_AXI_HIGHADDR { PARAM_VALUE.C_REGS_AXI_HIGHADDR } {
	# Procedure called to validate C_REGS_AXI_HIGHADDR
	return true
}


proc update_MODELPARAM_VALUE.NETWORK_SIZE { MODELPARAM_VALUE.NETWORK_SIZE PARAM_VALUE.NETWORK_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NETWORK_SIZE}] ${MODELPARAM_VALUE.NETWORK_SIZE}
}

proc update_MODELPARAM_VALUE.C_REGS_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_REGS_AXI_DATA_WIDTH PARAM_VALUE.C_REGS_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_REGS_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_REGS_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_REGS_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_REGS_AXI_ADDR_WIDTH PARAM_VALUE.C_REGS_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_REGS_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_REGS_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_SIM_STATE_AXIS_TDATA_WIDTH { MODELPARAM_VALUE.C_SIM_STATE_AXIS_TDATA_WIDTH PARAM_VALUE.C_SIM_STATE_AXIS_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_SIM_STATE_AXIS_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_SIM_STATE_AXIS_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_SIM_STATE_AXIS_START_COUNT { MODELPARAM_VALUE.C_SIM_STATE_AXIS_START_COUNT PARAM_VALUE.C_SIM_STATE_AXIS_START_COUNT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_SIM_STATE_AXIS_START_COUNT}] ${MODELPARAM_VALUE.C_SIM_STATE_AXIS_START_COUNT}
}

