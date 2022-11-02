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

if { $::env(SPEF_OVERWRITE) ne "" } {
    puts "overwriting spef from "
    puts "$spef to"
    puts "$::env(SPEF_OVERWRITE)"
    eval set spef $::env(SPEF_OVERWRITE)
}

set missing_spefs 0
run_puts "read_spef $spef"
foreach key [array names spef_mapping] {
    set spef_file $spef_mapping($key)
    if { [file exists $spef_file] } {
        run_puts "read_spef -path $key $spef_mapping($key)"
    } else {
        set missing_spefs 1
        puts "$spef_file not found"
        if { $::env(ALLOW_MISSING_SPEF) } {
            puts "WARNNING ALLOW_MISSING_SPEF set to 1. continuing"
        } else {
            exit 1
        }
    }
}

#read_spef /home/kareem_farid/re-timing/caravel-mpw-2b/spef/old-orcx/caravel_$::env(RCX_CORNER)_$::env(LIB_CORNER).spef

set sdc $::env(CARAVEL_ROOT)/signoff/caravel/caravel.sdc
run_puts "read_sdc -echo $sdc"

set logs_path "$::env(CARAVEL_ROOT)/signoff/caravel/openlane-signoff/$::env(LIB_CORNER)/$::env(RCX_CORNER)/"
file mkdir $logs_path

run_puts_logs "report_checks \
    -path_delay min \
    -format full_clock_expanded \
    -fields {slew cap input_pins nets fanout} \
    -no_line_splits \
    -path_group hk_serial_clk \
    -group_count 10000 \
    -endpoint_count 10 \
    -slack_max 10 \
    -digits 4 \
    "\
    "$logs_path/hk_serial_clk-min.log"


run_puts_logs "report_checks \
    -path_delay max \
    -format full_clock_expanded \
    -fields {slew cap input_pins nets fanout} \
    -no_line_splits \
    -path_group hk_serial_clk \
    -group_count 10000 \
    -endpoint_count 10 \
    -slack_max 10 \
    -digits 4 \
    "\
    "$logs_path/hk_serial_clk-max.log"

run_puts_logs "report_checks \
    -path_delay max \
    -format full_clock_expanded \
    -fields {slew cap input_pins nets fanout} \
    -no_line_splits \
    -path_group hkspi_clk \
    -group_count 10000 \
    -endpoint_count 10 \
    -slack_max 10 \
    -digits 4 \
    "\
    "$logs_path/hkspi_clk-max.log"

run_puts_logs "report_checks \
    -path_delay min \
    -format full_clock_expanded \
    -fields {slew cap input_pins nets fanout} \
    -no_line_splits \
    -path_group hkspi_clk \
    -group_count 10000 \
    -endpoint_count 10 \
    -slack_max 10 \
    -digits 4 \
    "\
    "$logs_path/hkspi_clk-min.log"

run_puts_logs "report_checks \
    -path_delay min \
    -format full_clock_expanded \
    -fields {slew cap input_pins nets fanout} \
    -no_line_splits \
    -path_group clk \
    -group_count 10000 \
    -endpoint_count 10 \
    -slack_max 10 \
    -digits 4 \
    "\
    "$logs_path/clk-min.rpt"
        
run_puts_logs "report_checks \
    -path_delay max \
    -format full_clock_expanded \
    -fields {slew cap input_pins nets fanout} \
    -no_line_splits \
    -path_group clk \
    -group_count 10000 \
    -endpoint_count 10 \
    -slack_max 10 \
    -digits 4 \
    "\
    "$logs_path/clk-max.rpt"

run_puts_logs "report_checks \
    -path_delay min \
    -through [get_cells soc] \
    -format full_clock_expanded \
    -fields {slew cap input_pins nets fanout} \
    -no_line_splits \
    -group_count 10000 \
    -endpoint_count 10 \
    -slack_max 100 \
    -digits 4 \
    "\
    "$logs_path/soc-min.rpt"

run_puts_logs "report_checks \
    -path_delay max \
    -through [get_cells soc] \
    -format full_clock_expanded \
    -fields {slew cap input_pins nets fanout} \
    -no_line_splits \
    -group_count 10000 \
    -endpoint_count 10 \
    -slack_max 100 \
    -digits 4 \
    "\
    "$logs_path/soc-max.rpt"

run_puts_logs "report_checks \
    -path_delay min \
    -through [get_cells mprj] \
    -format full_clock_expanded \
    -fields {slew cap input_pins nets fanout} \
    -no_line_splits \
    -group_count 10000 \
    -endpoint_count 5 \
    -slack_max 100 \
    -digits 4 \
    "\
    "$logs_path/mprj-min.rpt"

run_puts_logs "report_checks \
    -path_delay max \
    -through [get_cells mprj] \
    -format full_clock_expanded \
    -fields {slew cap input_pins nets fanout} \
    -no_line_splits \
    -group_count 10000 \
    -endpoint_count 5 \
    -slack_max 100 \
    -digits 4 \
    "\
    "$logs_path/mprj-max.rpt"

report_parasitic_annotation -report_unannotated > $logs_path/unannotated.log
if { $missing_spefs } {
    puts "there are missing spefs. check the log for ALLOW_MISSING_SPEF"
}
puts "check $logs_path"
