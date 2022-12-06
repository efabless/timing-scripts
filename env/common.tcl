source $::env(TIMING_ROOT)/env/$::env(PDK)/config.tcl

proc print_list { inlist } {
    foreach item $inlist {
        # recurse - go into the sub list
        if { [llength $item] > 1 } {
            print_list $item 
        } else {
            puts $item
        }
    }
}

set required_vars "pdk(libs) pdk(lefs)"
foreach var $required_vars {
    if { ! [info exists $var] } {
        puts "Missing pdk config $var"
    } else {
        puts "$var defined as:"
        print_list [subst $$var]
    }
}

set extra_lefs [list]
foreach path $::env(SEARCH_PATHS) {
    set extra_lefs [concat $extra_lefs [glob $path/lef/*.lef]]
}

proc run_puts {arg} {
    puts "exec> $arg"
    eval "{*}$arg"
}


set separator "--------------------------------------------------------------------------------------------"
proc run_puts_logs {arg log} {
    upvar separator separator
    set output [open "$log" w+]    
    puts $output "$separator"
    puts $output "COMMAND"
    puts $output "$separator"
    puts $output ""
    puts $output "exec> $arg"
    puts $output "design: $::env(BLOCK)"
    set timestr [exec date]
    puts $output "time: $timestr\n"
    puts $output "$separator"
    puts $output "REPORT"
    puts $output "$separator"
    puts $output ""
    close $output
    puts "exec> $arg >> $log"
    eval "{*}$arg >> $log"
}

