source $::env(TIMING_ROOT)/env/common.tcl
source $::env(TIMING_ROOT)/env/$::env(LIB_CORNER).tcl

set libs [split [regexp -all -inline {\S+} $libs]]

foreach liberty $libs {
    read_liberty $liberty
}

set verilog $::env(CUP_ROOT)/verilog/gl/$::env(BLOCK).v
if { ![file exists $verilog] } {
    set verilog $::env(MCW_ROOT)/verilog/gl/$::env(BLOCK).v
}
if { ![file exists $verilog] } {
    set verilog $::env(CARAVEL_ROOT)/verilog/gl/$::env(BLOCK).v
}

read_verilog $verilog

link_design $block

puts "read_spef $spef"
read_spef $spef
read_sdc $sdc
write_sdf $sdf -divider . -include_typ

puts "block: $block"
puts "spef: $spef"
puts "verilog: $verilog"
puts "sdf: $sdf"
puts "sdc: $sdc"
puts "rcx-corner: $::env(RCX_CORNER)"
puts "lib-corner: $::env(TIMING_ROOT)/env/$::env(LIB_CORNER).tcl"
