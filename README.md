# Timing scripts

A set of scripts for rcx and sta for caravel top level 

## Dependencies
- Docker

## Prerequisites

A set of exports are needed:
```bash
export CARAVEL_ROOT=/home/kareem_farid/caravel/
export MCW_ROOT=/home/kareem_farid/caravel/deps/caravel_mgmt_soc_litex/
export CUP_ROOT=/home/kareem_farid/caravel/deps/caravel_user_project/
export TIMING_ROOT=/home/kareem_farid/caravel/deps/caravel-timing/
export PDK_ROOT=/home/kareem_farid/caravel/deps/pdk/
export OPENLANE_IMAGE_NAME=efabless/openlane:4476a58407d670d251aa0be6a55e5391bb181c4e-amd64
```

## Running

The functionality is available through `timing.mk`

```
make -f timing.mk sdf-digital_pll -j3
make -f timing.mk rcx-digital_pll -j3
make -f timing.mk list-rcx
make -f timing.mk list-sdf
```

## Limitations

- Makefile
- Makefile
- Assumes a fixed folder structure for the exported directories
- Probably a lot of corner cases that weren't considered
- Need to manually create `${TIMING_ROOT}/logs/rcx`, `${TIMING_ROOT}/logs/sdf` and `${TIMING_ROOT}/logs/top`
