#=====================================#
# @file build.tcl                     #
#                                     #
# builds the generated Vivado project #
#=====================================#

source config.tcl


open_project ./${overlay_name}/${overlay_name}.xpr

# set platform properties
#set_property AUTO_INCREMENTAL_CHECKPOINT 0 [get_runs synth_1]
set_property platform.default_output_type "sd_card" [current_project]
set_property platform.design_intent.embedded "true" [current_project]
set_property platform.design_intent.server_managed "false" [current_project]
set_property platform.design_intent.external_host "false" [current_project]
set_property platform.design_intent.datacenter "false" [current_project]

#==============#
# Build steps: #
#==============#
# 1. run synthesis
launch_runs synth_1
wait_on_run synth_1
# 2. run implementation
launch_runs impl_1
wait_on_run impl_1
# 3. generate bitstream
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1
# 4. generate xsa (for the hwh file that pynq needs)
write_hw_platform -fixed -include_bit -force ./${overlay_name}.xsa
validate_hw_platform ./${overlay_name}.xsa

# copy bitstream, hwh file to top-level directory
file copy -force ./${overlay_name}/${overlay_name}.runs/impl_1/${design_name}_wrapper.bit ${overlay_name}.bit
file copy -force ./${overlay_name}/${overlay_name}.gen/sources_1/bd/${design_name}/hw_handoff/${design_name}.hwh ${overlay_name}.hwh
