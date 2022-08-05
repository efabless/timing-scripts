OPENLANE_TAG ?=  2022.02.23_02.50.41
OPENLANE_IMAGE_NAME ?=  efabless/openlane:$(OPENLANE_TAG)
export PDK_VARIENT = sky130A


./tmp ./logs:
	mkdir -p $@

define docker_run_base
	docker run \
		--rm \
		-e BLOCK=$1 \
		-e LIB_CORNER=$(LIB_CORNER) \
		-e RCX_CORNER=$(RCX_CORNER) \
		-e MCW_ROOT=$(MCW_ROOT) \
		-e CUP_ROOT=$(CUP_ROOT) \
		-e CARAVEL_ROOT=$(CARAVEL_ROOT) \
		-e TIMING_ROOT=$(TIMING_ROOT) \
		-e PDK_REF_PATH=$(PDK_ROOT)/$(PDK_VARIENT)/libs.ref/ \
		-e PDK_TECH_PATH=$(PDK_ROOT)/$(PDK_VARIENT)/libs.tech/ \
		-v $(PDK_ROOT):$(PDK_ROOT) \
		-v $(CUP_ROOT):$(CUP_ROOT) \
		-v $(MCW_ROOT):$(MCW_ROOT) \
		-v $(CARAVEL_ROOT):$(CARAVEL_ROOT) \
		-u $(shell id -u $(USER)):$(shell id -g $(USER)) \
		$(OPENLANE_IMAGE_NAME)
endef

define docker_run_sdf
	$(call docker_run_base,$1) \
		bash -c "set -eo pipefail && sta -exit $(TIMING_ROOT)/scripts/openroad/sdf.tcl \
			|& tee $(TIMING_ROOT)/logs/sdf/$*-$(RCX_CORNER)-$(LIB_CORNER).log"
	@echo "logged to $(TIMING_ROOT)/logs/sdf/$*-$(RCX_CORNER)-$(LIB_CORNER).log"
endef

define docker_run_rcx
	$(call docker_run_base,$1) \
		bash -c "set -eo pipefail && openroad -exit $(TIMING_ROOT)/scripts/openroad/rcx.tcl \
			|& tee $(TIMING_ROOT)/logs/rcx/$*-$(RCX_CORNER)-$(LIB_CORNER).log"
	@echo "logged to $(TIMING_ROOT)/logs/rcx/$*-$(RCX_CORNER)-$(LIB_CORNER).log"
endef

blocks  = $(shell cd $(CARAVEL_ROOT)/openlane && find * -maxdepth 0 -type d)
blocks := $(subst user_project_wrapper,,$(blocks))
blocks += $(shell cd $(MCW_ROOT)/openlane && find * -maxdepth 0 -type d)
blocks += $(shell cd $(CUP_ROOT)/openlane && find * -maxdepth 0 -type d)

# we don't have user_id_programming.def)
# mgmt_protect_hvl use hvl library which we don't handle yet
blocks := $(subst mgmt_protect_hvl,,$(blocks))
blocks := $(subst chip_io_alt,,$(blocks))
blocks := $(subst user_id_programming,,$(blocks))

rcx-blocks     = $(blocks:%=rcx-%)
rcx-blocks-nom = $(blocks:%=rcx-%-nom)
rcx-blocks-max = $(blocks:%=rcx-%-max)
rcx-blocks-min = $(blocks:%=rcx-%-min)
rcx-blocks-tt = $(blocks:%=rcx-%-tt)
rcx-blocks-ff = $(blocks:%=rcx-%-ff)
rcx-blocks-ss = $(blocks:%=rcx-%-ss)

sdf-blocks = $(blocks:%=sdf-%)
sdf-blocks-tt = $(blocks:%=sdf-%-tt)
sdf-blocks-ff = $(blocks:%=sdf-%-ff)
sdf-blocks-ss = $(blocks:%=sdf-%-ss)
sdf-blocks-nom = $(blocks:%=sdf-%-nom)
sdf-blocks-min = $(blocks:%=sdf-%-min)
sdf-blocks-max = $(blocks:%=sdf-%-max)

$(sdf-blocks): sdf-%: 
	$(MAKE) -f timing.mk sdf-$*-nom
	$(MAKE) -f timing.mk sdf-$*-min
	$(MAKE) -f timing.mk sdf-$*-max

$(sdf-blocks-nom): export RCX_CORNER = nom
$(sdf-blocks-min): export RCX_CORNER = min
$(sdf-blocks-max): export RCX_CORNER = max
$(sdf-blocks-nom): sdf-%-nom: sdf-%-tt sdf-%-ff sdf-%-ss
$(sdf-blocks-min): sdf-%-min: sdf-%-tt sdf-%-ff sdf-%-ss
$(sdf-blocks-max): sdf-%-max: sdf-%-tt sdf-%-ff sdf-%-ss

$(sdf-blocks-tt): export LIB_CORNER = tt
$(sdf-blocks-ss): export LIB_CORNER = ss
$(sdf-blocks-ff): export LIB_CORNER = ff
$(sdf-blocks-tt): sdf-%-tt:
	$(call docker_run_sdf,$*)
$(sdf-blocks-ss): sdf-%-ss:
	$(call docker_run_sdf,$*)
$(sdf-blocks-ff): sdf-%-ff:
	$(call docker_run_sdf,$*)

$(rcx-blocks): rcx-%: $(rcx-requirements) 
	$(MAKE) -f timing.mk rcx-$*-nom
	$(MAKE) -f timing.mk rcx-$*-min
	$(MAKE) -f timing.mk rcx-$*-max

$(rcx-blocks-nom): export RCX_CORNER = nom
$(rcx-blocks-min): export RCX_CORNER = min
$(rcx-blocks-max): export RCX_CORNER = max
$(rcx-blocks-nom): rcx-%-nom: rcx-%-tt rcx-%-ff rcx-%-ss
$(rcx-blocks-min): rcx-%-min: rcx-%-tt rcx-%-ff rcx-%-ss
$(rcx-blocks-max): rcx-%-max: rcx-%-tt rcx-%-ff rcx-%-ss

$(rcx-blocks-tt): export LIB_CORNER = tt
$(rcx-blocks-ss): export LIB_CORNER = ss
$(rcx-blocks-ff): export LIB_CORNER = ff
$(rcx-blocks-tt): rcx-%-tt:
	$(call docker_run_rcx,$*)
$(rcx-blocks-ss): rcx-%-ss:
	$(call docker_run_rcx,$*)
$(rcx-blocks-ff): rcx-%-ff:
	$(call docker_run_rcx,$*)


define docker_run_caravel_timing
	$(call docker_run_base,caravel) \
		bash -c "set -eo pipefail && sta -no_splash -exit $(TIMING_ROOT)/scripts/openroad/timing_top.tcl |& tee \
			$(TIMING_ROOT)/logs/caravel-timing-$$(basename $(CORNER_ENV_FILE))-$(RCX_CORNER).log"
	@echo "logged to $(TIMING_ROOT)/logs/caravel-timing-$$(basename $(CORNER_ENV_FILE))-$(RCX_CORNER).log"
endef


caravel-timing-typ-targets  = caravel-timing-typ-nom
caravel-timing-typ-targets += caravel-timing-typ-min
caravel-timing-typ-targets += caravel-timing-typ-max

caravel-timing-slow-targets  = caravel-timing-slow-nom
caravel-timing-slow-targets += caravel-timing-slow-min
caravel-timing-slow-targets += caravel-timing-slow-max

caravel-timing-fast-targets  = caravel-timing-fast-nom
caravel-timing-fast-targets += caravel-timing-fast-min
caravel-timing-fast-targets += caravel-timing-fast-max

caravel-timing-targets  = $(caravel-timing-slow-targets)
caravel-timing-targets += $(caravel-timing-fast-targets)
caravel-timing-targets += $(caravel-timing-typ-targets)

.PHONY: caravel-timing-typ
$(caravel-timing-typ-targets): export CORNER_ENV_FILE = $(TIMING_ROOT)/env/tt.tcl
caravel-timing-typ: caravel-timing-typ-nom caravel-timing-typ-min caravel-timing-typ-max

.PHONY: caravel-timing-typ-nom
.PHONY: caravel-timing-typ-min
.PHONY: caravel-timing-typ-max
caravel-timing-typ-nom: export RCX_CORNER = nom
caravel-timing-typ-min: export RCX_CORNER = min
caravel-timing-typ-max: export RCX_CORNER = max

.PHONY: caravel-timing-slow
$(caravel-timing-slow-targets): export CORNER_ENV_FILE = $(TIMING_ROOT)/env/ss.tcl
caravel-timing-slow: caravel-timing-slow-nom caravel-timing-slow-min caravel-timing-slow-max

.PHONY: caravel-timing-slow-nom
.PHONY: caravel-timing-slow-min
.PHONY: caravel-timing-slow-max
caravel-timing-slow-nom: export RCX_CORNER = nom
caravel-timing-slow-min: export RCX_CORNER = min
caravel-timing-slow-max: export RCX_CORNER = max

.PHONY: caravel-timing-fast
$(caravel-timing-fast-targets): export CORNER_ENV_FILE = $(TIMING_ROOT)/env/ff.tcl
caravel-timing-fast: caravel-timing-fast-nom caravel-timing-fast-min caravel-timing-fast-max

.PHONY: caravel-timing-fast-nom
.PHONY: caravel-timing-fast-min
.PHONY: caravel-timing-fast-max
caravel-timing-fast-nom: export RCX_CORNER = nom
caravel-timing-fast-min: export RCX_CORNER = min
caravel-timing-fast-max: export RCX_CORNER = max

$(caravel-timing-targets):
	$(call docker_run_caravel_timing)


# some useful dev double checking
#
rcx-requirements  = $(CARAVEL_ROOT)/def/%.def
rcx-requirements += $(CARAVEL_ROOT)/lef/%.lef
rcx-requirements += $(CARAVEL_ROOT)/sdc/%.sdc
rcx-requirements += $(CARAVEL_ROOT)/verilog/gl/%.v

exceptions  = $(MCW_ROOT)/lef/caravel.lef
exceptions += $(MCW_ROOT)/lef/caravan.lef
# lets ignore these for now
exceptions += $(MCW_ROOT)/sdc/user_analog_project_wrapper.sdc
exceptions += $(MCW_ROOT)/sdc/user_project_wrapper.sdc
exceptions += $(MCW_ROOT)/verilog/gl/user_analog_project_wrapper.v
exceptions += $(MCW_ROOT)/verilog/gl/user_project_wrapper.v

.PHONY: list-rcx
.PHONY: list-sdf
.PHONY: rcx-all
list-rcx:
	@echo $(rcx-blocks)
list-sdf:
	@echo $(sdf-blocks)
rcx-all: $(rcx-blocks)

$(exceptions):
	$(warning we don't need lefs for $@ but take note anyway)

$(CARAVEL_ROOT)/def/%.def: $(MCW_ROOT)/def/%.def ;
$(MCW_ROOT)/def/%.def: $(CUP_ROOT)/def/%.def ;
$(CUP_ROOT)/def/%.def:
	$(error error if you are here it probably means that $@.def is missing from mcw and caravel)

$(CARAVEL_ROOT)/lef/%.lef: $(MCW_ROOT)/lef/%.lef ;
$(MCW_ROOT)/lef/%.lef: $(CUP_ROOT)/lef/%.lef ;
$(CUP_ROOT)/lef/%.lef:
	$(error error if you are here it probably means that $@.lef is missing from mcw and caravel)

$(CARAVEL_ROOT)/sdc/%.sdc: $(MCW_ROOT)/sdc/%.sdc ;
$(MCW_ROOT)/sdc/%.sdc: $(CUP_ROOT)/sdc/%.sdc ;
$(CUP_ROOT)/sdc/%.sdc:
	$(error error if you are here it probably means that $@.sdc is missing from mcw and caravel)

$(CARAVEL_ROOT)/verilog/gl/%.v: $(MCW_ROOT)/verilog/gl/%.v ;
$(MCW_ROOT)/verilog/gl/%.v: $(CUP_ROOT)/verilog/gl/%.v ;
$(CUP_ROOT)/verilog/gl/%.v:
	$(error error if you are here it probably means that gl/$@.v is missing from mcw and caravel)

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

$(call check_defined, \
	MCW_ROOT \
	CUP_ROOT \
	PDK_ROOT \
	CARAVEL_ROOT \
)
