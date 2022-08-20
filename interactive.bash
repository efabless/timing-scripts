#!/bin/env bash
set -u

LIB_CORNER=$2
RCX_CORNER=$3
log=$2-$3-$1

export COMMON="./env/common.tcl"
#export LIB_CORNER="t"
export T_CORNER_LIST="./env/${LIB_CORNER}.tcl"
#export RCX_CORNER="nom"
export CARAVEL_ROOT=/home/kareem_farid/re-timing/mpw-2b/calibre-mpw-2-mpw-4
export MCW_ROOT=/home/kareem_farid/re-timing/mpw-2b/calibre-mpw-2-mpw-4
export CUP_ROOT=/home/kareem_farid/re-timing/mpw-2b/cup-dummy
export TIMING_ROOT="/home/kareem_farid/re-timing/timing-scripts"
export OPENLANE_IMAGE_NAME="efabless/openlane:4476a58407d670d251aa0be6a55e5391bb181c4e-amd64"
export PDK_ROOT="/home/kareem_farid/re-timing/pdk"
export BLOCK="caravel"
export PDK_VARIENT="sky130A"

docker run \
  -it \
  -e LIB_CORNER=${LIB_CORNER} \
  -e RCX_CORNER=${RCX_CORNER} \
  -e MCW_ROOT=${MCW_ROOT} \
  -e CUP_ROOT=${CUP_ROOT} \
  -e T_CORNER_LIST=${T_CORNER_LIST} \
  -e CARAVEL_ROOT=${CARAVEL_ROOT} \
  -e TIMING_ROOT=${TIMING_ROOT} \
  -e BLOCK=${BLOCK} \
  -e PDK_REF_PATH=${PDK_ROOT}/${PDK_VARIENT}/libs.ref/ \
  -e PDK_TECH_PATH=${PDK_ROOT}/${PDK_VARIENT}/libs.tech/ \
  -v ${HOME}:${HOME} \
  -w $(pwd) \
  -u $(id -u ${USER}):$(id -g ${USER}) \
  ${OPENLANE_IMAGE_NAME} bash -c "(echo '
  source ./env/common.tcl
  source ./env/${LIB_CORNER}.tcl
  read_libs \$libs
  read_verilogs \$verilogs
  link_design caravel
  puts \"read_spef /home/kareem_farid/re-timing/mpw-2b/caravel/spef/caravel-${RCX_CORNER}-${LIB_CORNER}.spef\"
  read_spef /home/kareem_farid/re-timing/mpw-2b/caravel/spef/caravel-${RCX_CORNER}-${LIB_CORNER}.spef
  read_sdc -echo ./caravel.sdc
  report_checks -unconstrained -format full_clock_expanded -fields {slew cap input nets fanout} -group_count 50
  exit
  ' && cat) | tee $log-commands | sta" 2>&1 | tee $log

#  ${OPENLANE_IMAGE_NAME} bash -c "sta" 2>&1 | tee $log
