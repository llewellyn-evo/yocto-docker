# Docker/Yocto Build System Setup
#     by komar@evologics.de 2018-2019 Evologics GmbH
# This project helps make build system for embedded platform by using docker and yocto.

MACHINE           = sama5d2-roadrunner-evomini2
MACHINE_CONFIG    = default

# Folders with source and build files
SOURCES_DIR       = sources
BUILD_DIR         = build

# If layer branch not set with "branch=" option, YOCTO_RELEASE will be used.
# If layer has no such branch, 'master' branch will be used.
YOCTO_RELEASE     = rocko

# Docker settings
DOCKER_IMAGE      = crops/poky
DOCKER_REPO       = debian-9
DOCKER_WORK_DIR   = /work
DOCKER_BIND       = -v $$(pwd):$(DOCKER_WORK_DIR)

# If the file "home/.use_home" exists, bind "home" folder to the container.
ifneq (,$(wildcard home/.use_home))
        DOCKER_BIND += -v $$(pwd)/home/:/home/pokyuser/
endif

# Cmdline to run docker.
DOCKER_RUN        = docker run -it --rm $(DOCKER_BIND)                 \
                    --name="$(MACHINE)"                                \
                    $(DOCKER_IMAGE):$(DOCKER_REPO)                     \
                    --workdir=$(DOCKER_WORK_DIR)/$(BUILD_DIR)

# Include saved config
-include .config.mk

# Include machine config with a possibility to override everything above
include machine/$(MACHINE)/$(MACHINE_CONFIG).mk

comma := ,
# Iterate over lines in LAYERS and fill necessary variables
$(foreach line, $(addprefix url=, $(LAYERS)),                               \
        $(eval line_sep = $(subst ;,  ,$(line)))                            \
        $(eval name := $(lastword $(subst /,  ,$(firstword $(line_sep)))))  \
        $(foreach property, $(line_sep),                                    \
            $(eval LAYER_$(name)_$(property))                               \
        )                                                                   \
                                                                            \
        $(eval dir := $(addprefix $(SOURCES_DIR)/, $(name)))                \
        $(eval subdirs_sep = $(subst $(comma),  ,$(LAYER_$(name)_subdirs))) \
                                                                            \
        $(eval LAYER_$(name)_branch ?= $(YOCTO_RELEASE))                    \
                                                                            \
        $(if $(value LAYER_$(name)_subdirs),                                \
            $(foreach subdir, $(subdirs_sep),                               \
                $(eval LAYERS_DIR += $(addsuffix /$(subdir), $(dir)))       \
                $(eval LAYER_$(subdir)_url := $(LAYER_$(name)_url))         \
                $(eval LAYER_$(subdir)_branch := $(LAYER_$(name)_branch))   \
            )                                                               \
        ,                                                                   \
            $(eval LAYERS_DIR += $(dir))                                    \
        )                                                                   \
 )

.PHONY: distclean help

help:
	@echo 'List targets:'
	@echo ' list-machine    - Show available machines'
	@echo ' list-config     - Show available configs for a given machine'
	@echo 'Cleaning targets:'
	@echo ' distclean	- Remove all generated files and directories'
	@echo ' clean-bbconfigs - Remove bblayers.conf and local.conf files'
	@echo ' clean-images    - Remove resulting target images and packages'
	@echo ''
	@echo 'Other generic targets:'
	@echo ' all		- Download docker image, yocto and meta layers and build image $(IMAGE_NAME) for machine $(MACHINE)'
	@echo ' devshell	- Invoke devepoper shell'
	@echo ''
	@echo 'Also docker can be run directly:'
	@echo '$(DOCKER_RUN)'
	@echo ''
	@echo 'And then build:'
	@echo 'bitbake core-image-minimal meta-toolchain'
	@echo ''
	@echo 'TIPS:'
	@echo 'Build binaries and images for RoadRunner on BertaD2 baseboard in separate build directory'
	@echo '$$ make MACHINE=sama5d2-roadrunner-bertad2-qspi BUILD_DIR=build-bertad2-qspi IMAGE_NAME=acme-minimal-image all'
	@echo 'Result binaryes and images you can find at $(BUILD_DIR)/tmp/deploy/'

list-machine:
	@ls -1 machine/ | grep -v common | sed '/$(MACHINE)[-.]/! s/\b$(MACHINE)\b/ * &/g'

list-config:
	@echo " * $(MACHINE):"
	@ls -1 machine/$(MACHINE)/ | grep .mk | sed 's/.mk\b//g' | sed '/$(MACHINE_CONFIG)[-.]/! s/\b$(MACHINE_CONFIG)\b/ * &/g'

all: build-poky-container sources layers $(BUILD_DIR) configure
	$(DOCKER_RUN) --cmd "bitbake $(IMAGE_NAME)"
	@echo 'Result binaryes and images you can find at $(BUILD_DIR)/tmp/deploy/'

devshell: build-poky-container sources layers $(BUILD_DIR) configure
	$(DOCKER_RUN)

build-poky-container: poky-container/build-and-test.sh

poky-container/build-and-test.sh:
	git clone -b $(YOCTO_RELEASE) https://github.com/evologics/poky-container
	cd poky-container && \
		BASE_DISTRO=$(DOCKER_REPO) REPO=$(DOCKER_IMAGE) ./build-and-test.sh

sources: $(SOURCES_DIR)

$(SOURCES_DIR):
	git clone -b $(YOCTO_RELEASE) git://git.yoctoproject.org/poky.git $(SOURCES_DIR)

layers: $(LAYERS_DIR)

$(LAYERS_DIR):
	cd $(SOURCES_DIR) && \
		(git clone -b $(LAYER_$(@F)_branch) $(LAYER_$(@F)_url) || git clone $(LAYER_$(@F)_url))

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

configure: $(BUILD_DIR)/conf/local.conf

$(BUILD_DIR)/conf/local.conf:
	$(DOCKER_RUN) --cmd "cd $(DOCKER_WORK_DIR)/$(SOURCES_DIR) && source oe-init-build-env $(DOCKER_WORK_DIR)/$(BUILD_DIR)" 
	for LAYER in $(LAYERS_DIR); do \
		$(DOCKER_RUN) --cmd "bitbake-layers add-layer $(DOCKER_WORK_DIR)/$$LAYER"; \
	done
	for OPT in $(LOCAL_CONF_OPT); do \
		echo $$OPT;					 \
	done >> $(BUILD_DIR)/conf/local.conf

	echo "MACHINE = $(MACHINE)" > .config.mk
	echo "MACHINE_CONFIG = $(MACHINE_CONFIG)" >> .config.mk

clean-bbconfigs:
	rm $(BUILD_DIR)/conf/local.conf $(BUILD_DIR)/conf/bblayers.conf

clean-images:
	rm -rf $(BUILD_DIR)/tmp/deploy

cleanall:
	rm -rf $(BUILD_DIR)/tmp $(BUILD_DIR)/sstate-cache

distclean:
	rm -rf $(BUILD_DIR) $(SOURCES_DIR) poky-container .config.mk

