source $::env(TIMING_ROOT)/env/common.tcl

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

foreach key [array names spef_mapping] {
    puts "read_spef -path $key $spef_mapping($key)"
    read_spef -path $key $spef_mapping($key)
}

#read_spef /home/kareem_farid/re-timing/caravel-mpw-2b/spef/old-orcx/caravel_$::env(RCX_CORNER)_$::env(LIB_CORNER).spef
 if { $::env(SPEF_OVERWRITE) ne "" } {
     puts "overwriting spef from "
     puts "$spef to"
     puts "$::env(SPEF_OVERWRITE)"
     eval set spef $::env(SPEF_OVERWRITE)
 }
puts "read_spef $spef"
read_spef $spef

puts $sdc
read_sdc -echo $sdc

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


puts "report_checks -from \[get_pins {housekeeping/serial_clock}\] -to \[get_pins {gpio_control_bidir_2[2]/serial_clock}\] -unconstrained"
report_checks -from [get_pins {housekeeping/serial_clock}] -to [get_pins {gpio_control_bidir_2[2]/serial_clock}] -unconstrained
puts "report_checks -from \[get_pins {housekeeping/serial_clock}\] -to \[get_pins {gpio_control_bidir_2\[2\]/serial_clock_out}\] -unconstrained"
report_checks -from [get_pins {housekeeping/serial_clock}] -to [get_pins {gpio_control_bidir_2[2]/serial_clock_out}] -unconstrained

puts "report_checks -from \[get_pins {housekeeping/serial_clock}\] -to \[get_pins {gpio_control_bidir_2\[2\]/serial_clock}\]"
report_checks -from [get_pins {housekeeping/serial_clock}] -to [get_pins {gpio_control_bidir_2[2]/serial_clock}]
puts "report_checks -from \[get_pins {housekeeping/serial_clock}\] -to \[get_pins {gpio_control_bidir_2\[2\]/serial_clock_out}\]"
report_checks -from [get_pins {housekeeping/serial_clock}] -to [get_pins {gpio_control_bidir_2[2]/serial_clock_out}]

report_annotated_check -list_not_annotated

puts "get_property -object_type pin \[get_pins {gpio_control_bidir_2\[2\]/serial_clock}\] actual_fall_transition_max"
puts "[get_property -object_type pin [get_pins {gpio_control_bidir_2[2]/serial_clock}] actual_fall_transition_max]"
puts "\[get_property -object_type pin \[get_pins {gpio_control_bidir_2\[2\]/serial_clock}\] actual_rise_transition_max\]"
puts "[get_property -object_type pin [get_pins {gpio_control_bidir_2[2]/serial_clock}] actual_rise_transition_max]"

#puts "report_clock_properties \[all_clocks\]"
#report_clock_properties [all_clocks]
#puts "report_clock_skew -clock hk_serial_clk"
#report_clock_skew -clock hk_serial_clk
#report_check_types -max_slew -violators
#puts "max slew violation count [sta::max_slew_violation_count]"



#report_worst_slack -max 
#report_worst_slack -min 
