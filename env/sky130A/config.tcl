set std_cell_library        "sky130_fd_sc_hd"
set special_voltage_library "sky130_fd_sc_hvl"
set io_library              "sky130_fd_io"
set primitives_library      "sky130_fd_pr"
set ef_io_library           "sky130_ef_io"
set ef_cell_library         "sky130_ef_sc_hd"

set signal_layer            "met2"
set clock_layer             "met5"


set tech_lef $::env(PDK_REF_PATH)/$std_cell_library/techlef/${std_cell_library}__$::env(RCX_CORNER).tlef
set cells_lef $::env(PDK_REF_PATH)/$std_cell_library/lef/$std_cell_library.lef
set io_lef $::env(PDK_REF_PATH)/$io_library/lef/$io_library.lef
set ef_io_lef $::env(PDK_REF_PATH)/$io_library/lef/$ef_io_library.lef
set ef_cells_lef $::env(PDK_REF_PATH)/$std_cell_library/lef/$ef_cell_library.lef
set sram_lef $::env(PDK_REF_PATH)/sky130_sram_macros/lef/sky130_sram_2kbyte_1rw1r_32x512_8.lef

set pdk(lefs) [list \
    $tech_lef \
    $cells_lef \
    $io_lef \
    $ef_cells_lef \
    $ef_io_lef \
    $sram_lef
]

set pdk(rcx_rules_file) $::env(PDK_TECH_PATH)/openlane/rules.openrcx.$::env(PDK).$::env(RCX_CORNER).calibre

source $::env(TIMING_ROOT)/env/$::env(PDK)/$::env(LIB_CORNER).tcl
