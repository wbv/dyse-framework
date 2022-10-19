

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "count_stream_test" "NUM_INSTANCES" "DEVICE_ID"  "C_S_AXI_registers_BASEADDR" "C_S_AXI_registers_HIGHADDR"
}
