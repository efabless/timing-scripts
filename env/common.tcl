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

set extra_lefs [concat \
[glob $::env(CARAVEL_ROOT)/lef/*.lef] \
[glob $::env(MCW_ROOT)/lef/*.lef] \
[glob $::env(CUP_ROOT)/lef/*.lef] \
]

# search order:
# cup -> mcw -> caravel

set def $::env(CUP_ROOT)/def/$::env(BLOCK).def
set spef $::env(CUP_ROOT)/signoff/$::env(BLOCK)/openlane-signoff/spef/$::env(BLOCK).$::env(RCX_CORNER).spef
set sdc $::env(CUP_ROOT)/sdc/$::env(BLOCK).sdc
set sdf $::env(CUP_ROOT)/signoff/$::env(BLOCK)/openlane-signoff/sdf/$::env(RCX_CORNER)/$::env(BLOCK).$::env(LIB_CORNER)$::env(LIB_CORNER).$::env(RCX_CORNER).sdf
if { ![file exists $def] } {
    set def $::env(MCW_ROOT)/def/$::env(BLOCK).def
    set spef $::env(MCW_ROOT)/signoff/$::env(BLOCK)/openlane-signoff/spef/$::env(BLOCK).$::env(RCX_CORNER).spef
    set sdc $::env(MCW_ROOT)/sdc/$::env(BLOCK).sdc
    set sdf $::env(MCW_ROOT)/signoff/$::env(BLOCK)/openlane-signoff/sdf/$::env(RCX_CORNER)/$::env(BLOCK).$::env(LIB_CORNER)$::env(LIB_CORNER).$::env(RCX_CORNER).sdf
}
if { ![file exists $def] } {
    set def $::env(CARAVEL_ROOT)/def/$::env(BLOCK).def
    set spef $::env(CARAVEL_ROOT)/signoff/$::env(BLOCK)/openlane-signoff/spef/$::env(BLOCK).$::env(RCX_CORNER).spef
    set sdc $::env(CARAVEL_ROOT)/sdc/$::env(BLOCK).sdc
    set sdf $::env(CARAVEL_ROOT)/signoff/$::env(BLOCK)/openlane-signoff/sdf/$::env(RCX_CORNER)/$::env(BLOCK).$::env(LIB_CORNER)$::env(LIB_CORNER).$::env(RCX_CORNER).sdf
}

file mkdir [file dirname $spef]
file mkdir [file dirname $sdf]
set block $::env(BLOCK)


# order matter
set caravel_root "[file normalize $::env(CARAVEL_ROOT)]"
set mcw_root "[file normalize $::env(MCW_ROOT)]"
set cup_root "[file normalize $::env(CUP_ROOT)]"
set verilogs [concat \
[glob $mcw_root/verilog/gl/*] \
[glob $caravel_root/verilog/gl/*] \
[glob $cup_root/verilog/gl/*] \
]

set verilog_exceptions [list \
    "$caravel_root/verilog/gl/__user_analog_project_wrapper.v" \
    "$caravel_root/verilog/gl/caravel-signoff.v" \
    "$caravel_root/verilog/gl/caravan-signoff.v" \
    "$caravel_root/verilog/gl/__user_project_wrapper.v" \
    ]

foreach verilog_exception $verilog_exceptions {
    puts "verilog exception: $verilog_exception"
    set match_idx [lsearch $verilogs $verilog_exception]
    if {$match_idx} {
        puts "removing $verilog_exception from verilogs list"
        set verilogs [lreplace $verilogs $match_idx $match_idx]
    }
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

