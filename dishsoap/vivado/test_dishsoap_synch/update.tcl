#======================================#
# @file update.tcl                     #
#                                      #
# updates and upgrades any outdated IP #
#======================================#

source config.tcl


open_project ./${overlay_name}/${overlay_name}.xpr
open_bd_design ./${overlay_name}/${overlay_name}.srcs/sources_1/bd/${design_name}/${design_name}.bd

# update IP repo with any changes, and upgrade the parts
# (only update our custom IP for now)
update_ip_catalog -rebuild -scan_changes -repo_path ../ip
report_ip_status -name ip_status
upgrade_ip -vlnv wbv:user:dishsoap:0.1 [get_ips  dishsoap_vivado_bd_dishsoap_0_0]
export_ip_user_files -of_objects [get_ips dishsoap_vivado_bd_dishsoap_0_0] -no_script -sync -force -quiet

# save&close the updated design
save_bd_design
close_bd_design [get_bd_designs ${design_name}]

reset_run synth_1

close_project

# then rebuild
source build.tcl
