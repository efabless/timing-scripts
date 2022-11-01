source $::env(TIMING_ROOT)/env/common.tcl
source $::env(TIMING_ROOT)/env/caravel_spef_mapping-mpw7.tcl

if { [file exists $::env(CUP_ROOT)/env/spef_mapping.tcl] } {
    source $::env(CUP_ROOT)/env/spef_mapping.tcl
}

source $::env(TIMING_ROOT)/env/$::env(LIB_CORNER).tcl

set libs [split [regexp -all -inline {\S+} $libs]]
set verilogs [split [regexp -all -inline {\S+} $verilogs]]


foreach liberty $libs {
    puts $liberty
}

foreach liberty $libs {
    read_liberty $liberty
}

foreach verilog $verilogs {
    read_verilog $verilog
}

link_design caravel

run_puts "read_spef $spef"
foreach key [array names spef_mapping] {
    run_puts "read_spef -path $key $spef_mapping($key)"
}

#read_spef /home/kareem_farid/re-timing/caravel-mpw-2b/spef/old-orcx/caravel_$::env(RCX_CORNER)_$::env(LIB_CORNER).spef
 if { $::env(SPEF_OVERWRITE) ne "" } {
     puts "overwriting spef from "
     puts "$spef to"
     puts "$::env(SPEF_OVERWRITE)"
     eval set spef $::env(SPEF_OVERWRITE)
 }

set sdc $::env(CARAVEL_ROOT)/signoff/caravel/caravel.sdc
run_puts "read_sdc -echo $sdc"

# report_checks -path_delay min -fields {slew cap input nets fanout} -format full_clock_expanded -group_count 50
# report_checks -path_delay max -fields {slew cap input nets fanout} -format full_clock_expanded -group_count 50
# puts "Management Area Interface"
# report_checks -to soc/core_clk -unconstrained -group_count 1
# puts "User project Interface"
# report_checks -to mprj/wb_clk_i -unconstrained -group_count 1
# report_checks -to mprj/wb_rst_i -unconstrained -group_count 1
# report_checks -to mprj/wbs_cyc_i -unconstrained -group_count 1
# report_checks -to mprj/wbs_stb_i -unconstrained -group_count 1
# report_checks -to mprj/wbs_we_i -unconstrained -group_count 1
# report_checks -to mprj/wbs_sel_i[*] -unconstrained -group_count 4
# report_checks -to mprj/wbs_adr_i[*] -unconstrained -group_count 32
# report_checks -to mprj/io_in[*] -unconstrained -group_count 32
# report_checks -to mprj/user_clock2 -unconstrained -group_count 32
# report_checks -to mprj/user_irq[*] -unconstrained -group_count 32
# report_checks -to mprj/la_data_in[*] -unconstrained -group_count 128
# report_checks -to mprj/la_oenb[*] -unconstrained -group_count 128
# puts "Flash output Interface"
# report_checks -to flash_clk -group_count 1
# report_checks -to flash_csb -group_count 1
# report_checks -to flash_io0 -group_count 1


#puts "report_checks -from \[get_pins {housekeeping/serial_clock}\] -to \[get_pins {gpio_control_bidir_2[2]/serial_clock}\] -unconstrained"
#report_checks -from [get_pins {housekeeping/serial_clock}] -to [get_pins {gpio_control_bidir_2[2]/serial_clock}] -unconstrained
#puts "report_checks -from \[get_pins {housekeeping/serial_clock}\] -to \[get_pins {gpio_control_bidir_2\[2\]/serial_clock_out}\] -unconstrained"
#report_checks -from [get_pins {housekeeping/serial_clock}] -to [get_pins {gpio_control_bidir_2[2]/serial_clock_out}] -unconstrained
#
#puts "report_checks -from \[get_pins {housekeeping/serial_clock}\] -to \[get_pins {gpio_control_bidir_2\[2\]/serial_clock}\]"
#report_checks -from [get_pins {housekeeping/serial_clock}] -to [get_pins {gpio_control_bidir_2[2]/serial_clock}]
#puts "report_checks -from \[get_pins {housekeeping/serial_clock}\] -to \[get_pins {gpio_control_bidir_2\[2\]/serial_clock_out}\]"
#report_checks -from [get_pins {housekeeping/serial_clock}] -to [get_pins {gpio_control_bidir_2[2]/serial_clock_out}]
#
#report_annotated_check -list_not_annotated
#
#puts "get_property -object_type pin \[get_pins {gpio_control_bidir_2\[2\]/serial_clock}\] actual_fall_transition_max"
#puts "[get_property -object_type pin [get_pins {gpio_control_bidir_2[2]/serial_clock}] actual_fall_transition_max]"
#puts "\[get_property -object_type pin \[get_pins {gpio_control_bidir_2\[2\]/serial_clock}\] actual_rise_transition_max\]"
#puts "[get_property -object_type pin [get_pins {gpio_control_bidir_2[2]/serial_clock}] actual_rise_transition_max]"
#
##puts "report_clock_properties \[all_clocks\]"
##report_clock_properties [all_clocks]
##puts "report_clock_skew -clock hk_serial_clk"
##report_clock_skew -clock hk_serial_clk
##report_check_types -max_slew -violators
##puts "max slew violation count [sta::max_slew_violation_count]"
#
#report_checks -unconstrained -format full_clock_expanded -fields {slew cap input nets fanout}
#
##report_worst_slack -max 
##report_worst_slack -min 
set logs_path "$::env(CARAVEL_ROOT)/signoff/caravel/openlane-signoff/$::env(LIB_CORNER)/$::env(RCX_CORNER)/"
file mkdir $logs_path
report_checks -path_delay min -format full_clock_expanded -fields {slew cap input_pins nets fanout} \
    -no_line_splits -path_group hk_serial_clk \
    -group_count 10000 -endpoint_count 10 -slack_max 10 -digits 4 > $logs_path/hk_serial_clk-min.log

report_checks -path_delay max -format full_clock_expanded -fields {slew cap input_pins nets fanout} \
    -no_line_splits -path_group hk_serial_clk \
    -group_count 10000 -endpoint_count 10 -slack_max 10 -digits 4 > $logs_path/hk_serial_clk-max.log

report_checks -path_delay max -format full_clock_expanded -fields {slew cap input_pins nets fanout} \
    -no_line_splits -path_group hkspi_clk \
    -group_count 10000 -endpoint_count 10 -slack_max 10 -digits 4 > $logs_path/hkspi_clk-max.log

report_checks -path_delay min -format full_clock_expanded -fields {slew cap input_pins nets fanout} \
    -no_line_splits -path_group hkspi_clk \
    -group_count 10000 -endpoint_count 10 -slack_max 10 -digits 4 > $logs_path/hkspi_clk-min.log

report_parasitic_annotation -report_unannotated > $logs_path/unannotated.log
puts "check $logs_path"
