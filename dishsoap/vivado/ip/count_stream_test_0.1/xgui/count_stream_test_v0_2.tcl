# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_S_AXI_registers_DATA_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_S_AXI_registers_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_registers_BASEADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_registers_HIGHADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_M_AXIS_output_TDATA_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_M_AXIS_output_START_COUNT" -parent ${Page_0}

  set COUNTER_WIDTH [ipgui::add_param $IPINST -name "COUNTER_WIDTH"]
  set_property tooltip {How many bits are used in the counter} ${COUNTER_WIDTH}

}

proc update_PARAM_VALUE.COUNTER_WIDTH { PARAM_VALUE.COUNTER_WIDTH } {
	# Procedure called to update COUNTER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.COUNTER_WIDTH { PARAM_VALUE.COUNTER_WIDTH } {
	# Procedure called to validate COUNTER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_registers_DATA_WIDTH { PARAM_VALUE.C_S_AXI_registers_DATA_WIDTH } {
	# Procedure called to update C_S_AXI_registers_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_registers_DATA_WIDTH { PARAM_VALUE.C_S_AXI_registers_DATA_WIDTH } {
	# Procedure called to validate C_S_AXI_registers_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_registers_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_registers_ADDR_WIDTH } {
	# Procedure called to update C_S_AXI_registers_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_registers_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_registers_ADDR_WIDTH } {
	# Procedure called to validate C_S_AXI_registers_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_registers_BASEADDR { PARAM_VALUE.C_S_AXI_registers_BASEADDR } {
	# Procedure called to update C_S_AXI_registers_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_registers_BASEADDR { PARAM_VALUE.C_S_AXI_registers_BASEADDR } {
	# Procedure called to validate C_S_AXI_registers_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S_AXI_registers_HIGHADDR { PARAM_VALUE.C_S_AXI_registers_HIGHADDR } {
	# Procedure called to update C_S_AXI_registers_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_registers_HIGHADDR { PARAM_VALUE.C_S_AXI_registers_HIGHADDR } {
	# Procedure called to validate C_S_AXI_registers_HIGHADDR
	return true
}

proc update_PARAM_VALUE.C_M_AXIS_output_TDATA_WIDTH { PARAM_VALUE.C_M_AXIS_output_TDATA_WIDTH } {
	# Procedure called to update C_M_AXIS_output_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXIS_output_TDATA_WIDTH { PARAM_VALUE.C_M_AXIS_output_TDATA_WIDTH } {
	# Procedure called to validate C_M_AXIS_output_TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXIS_output_START_COUNT { PARAM_VALUE.C_M_AXIS_output_START_COUNT } {
	# Procedure called to update C_M_AXIS_output_START_COUNT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXIS_output_START_COUNT { PARAM_VALUE.C_M_AXIS_output_START_COUNT } {
	# Procedure called to validate C_M_AXIS_output_START_COUNT
	return true
}


proc update_MODELPARAM_VALUE.C_S_AXI_registers_DATA_WIDTH { MODELPARAM_VALUE.C_S_AXI_registers_DATA_WIDTH PARAM_VALUE.C_S_AXI_registers_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_registers_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_registers_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_registers_ADDR_WIDTH { MODELPARAM_VALUE.C_S_AXI_registers_ADDR_WIDTH PARAM_VALUE.C_S_AXI_registers_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_registers_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_registers_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXIS_output_TDATA_WIDTH { MODELPARAM_VALUE.C_M_AXIS_output_TDATA_WIDTH PARAM_VALUE.C_M_AXIS_output_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXIS_output_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_M_AXIS_output_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXIS_output_START_COUNT { MODELPARAM_VALUE.C_M_AXIS_output_START_COUNT PARAM_VALUE.C_M_AXIS_output_START_COUNT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXIS_output_START_COUNT}] ${MODELPARAM_VALUE.C_M_AXIS_output_START_COUNT}
}

proc update_MODELPARAM_VALUE.COUNTER_WIDTH { MODELPARAM_VALUE.COUNTER_WIDTH PARAM_VALUE.COUNTER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.COUNTER_WIDTH}] ${MODELPARAM_VALUE.COUNTER_WIDTH}
}

