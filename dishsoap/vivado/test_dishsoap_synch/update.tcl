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
update_ip_catalog -rebuild -repo_path ../ip
upgrade_ip -vlnv wbv:user:dishsoap:0.1 [get_bd_cells dishsoap_0]

# save&close the updated design
save_bd_design
close_bd_design [get_bd_designs ${design_name}]

# then rebuild
source build.tcl
