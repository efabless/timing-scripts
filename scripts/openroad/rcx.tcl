source $::env(TIMING_ROOT)/env/common.tcl

foreach liberty $pdk(libs) {
  run_puts "read_liberty $liberty"
}
foreach lef $pdk(lefs) {
  run_puts "read_lef $lef"
}

foreach lef_file $extra_lefs {		
  run_puts "read_lef $lef_file"
}

run_puts "read_def $def"
# don't think we need to read sdc

run_puts "define_process_corner -ext_model_index 0 X"
run_puts "extract_parasitics \
    -ext_model_file $pdk(rcx_rules_file) \
    -lef_res"

run_puts "write_spef $spef"
run_puts "read_spef $spef"

puts "spef: $spef"
puts "def: $def"
puts "rcx: $pdk(rcx_rules_file)"
puts "rcx-corner: $::env(RCX_CORNER)"
puts "lib-corner: $::env(LIB_CORNER).tcl"
puts "tech_lef: $tech_lef"
