set std_cell_library        "gf180mcu_fd_sc_mcu7t5v0"
set io_library              "gf180mcu_fd_io"



set tech_lef $::env(PDK_REF_PATH)/$std_cell_library/techlef/${std_cell_library}__$::env(RCX_CORNER).tlef
set cells_lef $::env(PDK_REF_PATH)/$std_cell_library/lef/$std_cell_library.lef
set io_lef $::env(PDK_REF_PATH)/$io_library/lef/$io_library.lef
set sram_lef $::env(PDK_REF_PATH)/gf180mcu_fd_ip_sram/lef/gf180mcu_fd_ip_sram__sram512x8m8wm1.lef

set pdk(lefs) [list \
    $tech_lef \
    $cells_lef \
    $io_lef \
    $sram_lef
]

set pdk(rcx_rules_file) $::env(PDK_TECH_PATH)/openlane/rules.openrcx.$::env(PDK).$::env(RCX_CORNER)

source $::env(TIMING_ROOT)/env/$::env(PDK)/$::env(LIB_CORNER).tcl
