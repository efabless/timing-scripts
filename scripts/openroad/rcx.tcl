source $::env(TIMING_ROOT)/env/common.tcl
source $::env(TIMING_ROOT)/env/$::env(LIB_CORNER).tcl

set libs [split [regexp -all -inline {\S+} $libs]]
set extra_lefs [split [regexp -all -inline {\S+} $extra_lefs]]

foreach liberty $libs {
    read_liberty $liberty
}

foreach lef $lefs {
    if {[catch {read_lef $lef} errmsg]} {
        puts stderr $errmsg
        exit 1
    }
}

if {[catch {read_lef $sram_lef} errmsg]} {
    puts stderr $errmsg
    exit 1
}

foreach lef_file $extra_lefs {		
    if {[catch {read_lef $lef_file} errmsg]} {
        puts stderr $errmsg
        exit 1
    }	
}

if {[catch {read_def -order_wires $def} errmsg]} {
    puts stderr $errmsg
    exit 1
}
# don't think we need to read sdc
#read_sdc $sdc
set_propagated_clock [all_clocks]

set_wire_rc -signal -layer $signal_layer
set_wire_rc -clock -layer $clock_layer
define_process_corner -ext_model_index 0 X
extract_parasitics \
    -ext_model_file $rcx_rules_file \
    -corner_cnt 1 \
    -lef_res

puts "write_spef $spef"
write_spef $spef
puts "read_spef $spef"
read_spef $spef
puts "write_sdf $sdf -divider . -include_typ"
write_sdf $sdf -divider . -include_typ

puts "spef: $spef"
puts "def: $def"
puts "sdf: $sdf"
puts "rcx: $rcx_rules_file"
puts "rcx-corner: $::env(RCX_CORNER)"
puts "lib-corner: $::env(TIMING_ROOT)/env/$::env(LIB_CORNER).tcl"
