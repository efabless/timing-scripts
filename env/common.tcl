set std_cell_library        "sky130_fd_sc_hd"
set special_voltage_library "sky130_fd_sc_hvl"
set io_library              "sky130_fd_io"
set primitives_library      "sky130_fd_pr"
set ef_io_library           "sky130_ef_io"

set signal_layer            "met2"
set clock_layer             "met5"

set extra_lefs "
    [glob $::env(CARAVEL_ROOT)/lef/*.lef]
    [glob $::env(MCW_ROOT)/lef/*.lef]
    [glob $::env(CUP_ROOT)/lef/*.lef]"

set tech_lef $::env(PDK_REF_PATH)/$std_cell_library/techlef/${std_cell_library}__$::env(RCX_CORNER).tlef
set cells_lef $::env(PDK_REF_PATH)/$std_cell_library/lef/$std_cell_library.lef
set io_lef $::env(PDK_REF_PATH)/$io_library/lef/$io_library.lef
set ef_io_lef $::env(PDK_REF_PATH)/$io_library/lef/$ef_io_library.lef

set lefs [list \
    $tech_lef \
    $cells_lef \
    $io_lef \
    $ef_io_lef
]
# search order:
# cup -> mcw -> caravel
set def $::env(CUP_ROOT)/def/$::env(BLOCK).def
set spef $::env(CUP_ROOT)/spef/$::env(BLOCK)_$::env(RCX_CORNER)_$::env(LIB_CORNER).spef
set sdc $::env(CUP_ROOT)/sdc/$::env(BLOCK).sdc
set sdf $::env(CUP_ROOT)/sdf/$::env(BLOCK)_$::env(RCX_CORNER)_$::env(LIB_CORNER).sdf
if { ![file exists $def] } {
    set def $::env(MCW_ROOT)/def/$::env(BLOCK).def
    set spef $::env(MCW_ROOT)/spef/$::env(BLOCK)_$::env(RCX_CORNER)_$::env(LIB_CORNER).spef
    set sdc $::env(MCW_ROOT)/sdc/$::env(BLOCK).sdc
    set sdf $::env(MCW_ROOT)/sdf/$::env(BLOCK)_$::env(RCX_CORNER)_$::env(LIB_CORNER).sdf
}
if { ![file exists $def] } {
    set def $::env(CARAVEL_ROOT)/def/$::env(BLOCK).def
    set spef $::env(CARAVEL_ROOT)/spef/$::env(BLOCK)_$::env(RCX_CORNER)_$::env(LIB_CORNER).spef
    set sdc $::env(CARAVEL_ROOT)/sdc/$::env(BLOCK).sdc
    set sdf $::env(CARAVEL_ROOT)/sdf/$::env(BLOCK)_$::env(RCX_CORNER)_$::env(LIB_CORNER).sdf
}

set block $::env(BLOCK)
set rcx_rules_file $::env(PDK_TECH_PATH)/openlane/rules.openrcx.sky130A.$::env(RCX_CORNER).spef_extractor
set merged_lef $::env(CARAVEL_ROOT)/tmp/merged_lef-$::env(RCX_CORNER).lef

set sram_lef $::env(PDK_REF_PATH)/sky130_sram_macros/lef/sky130_sram_2kbyte_1rw1r_32x512_8.lef

# order matter
set verilogs "
    [glob $::env(MCW_ROOT)/verilog/gl/*]
    [glob $::env(CARAVEL_ROOT)/verilog/gl/*]
    [glob $::env(CUP_ROOT)/verilog/gl/*]
"

set verilog_exceptions [list \
    "$::env(CARAVEL_ROOT)/verilog/gl/__user_analog_project_wrapper.v" \
    "$::env(CARAVEL_ROOT)/verilog/gl/__user_project_wrapper.v" \
]

foreach verilog_exception $verilog_exceptions {
    puts $verilog_exception
    set verilogs [regsub "$verilog_exception" "$verilogs" " "]
}

source $::env(TIMING_ROOT)/env/caravel_spef_mapping.tcl
