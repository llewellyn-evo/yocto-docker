# Docker/Yocto Build System Setup
#     by komar@evologics.de 2018-2019 Evologics GmbH
# This project helps make build system for embedded platform by using docker and yocto.
#
# TODO: add Makefile to build-* directory, to call ../Makefile. which detected
# if make runned inside docker, call same commands with bitbake, but without docker

# Folders with source and build files
SOURCES_DIR       = sources
BUILD_DIR        ?= build-$(MACHINE)

# If layer branch not set with "branch=" option, YOCTO_RELEASE will be used.
# If layer has no such branch, 'master' branch will be used.
YOCTO_RELEASE     = thud

# Docker settings
DOCKER_IMAGE      = evologics/yocto
DOCKER_WORK_DIR   = /work
DOCKER_BIND       = -v $$(pwd):$(DOCKER_WORK_DIR) \
                    -v /etc/localtime:/etc/localtime:ro \
                    -e HOST_UID=$(shell id -u) \
                    -e HOST_GID=$(shell id -g) \
                    -e USER=$(USER) \
                    -h $(DOCKER_HOST_NAME) \
					$(DOCKER_SSH_AUTH_SOCK) \
                    --add-host=$(DOCKER_HOST_NAME):127.0.0.1 \
                    --network=host

ifneq ($(SSH_AUTH_SOCK),)
	DOCKER_SSH_AUTH_SOCK = -v $(dir $(SSH_AUTH_SOCK)):$(dir $(SSH_AUTH_SOCK)) -e SSH_AUTH_SOCK=$(SSH_AUTH_SOCK)
endif

# Cmdline to run docker.
DOCKER_RUN        = docker run -it --rm $(DOCKER_BIND)        \
                    --workdir=$(DOCKER_WORK_DIR)/$(BUILD_DIR) \
                    $(DOCKER_IMAGE)

# If the file "home/.use_home" exists, bind "home" folder to the container.
ifneq (,$(wildcard home/.use_home))
    DOCKER_BIND += -v $$(pwd)/home/:/home/$(USER)/
else
    DOCKER_BIND += -v $(HOME)/.ssh:/home/$(USER)/.ssh        \
        -v $(HOME)/.git:/home/$(USER)/.git \
        -v $(HOME)/.bash_history:/home/$(USER)/.bash_history \
        -v $(HOME)/.screenrc:/home/$(USER)/.screenrc         \
        -v $(HOME)/.tmux.conf:/home/$(USER)/.tmux.conf
endif

DOCKER_HOST_NAME=build-$(subst :,-,$(subst /,-,$(MACHINE)))

# Include saved config
-include .config.mk
# Use default MACHINE_CONFIG if it`s not defined
MACHINE_CONFIG ?= default

define add_to_local_conf_opt
  $(foreach V, $(NEWVARS), \
    $(if $(filter-out OLDVARS $(OLDVARS), $V), \
	  $(if $(findstring pend, $V), \
      $(eval LOCAL_CONF_OPT += '$V = " $($V) "'), \
      $(eval LOCAL_CONF_OPT += '$V = "$($V)"') \
	  )) \
   )
endef

# Do not attempt to include something if running for bash completion
# __BASH_MAKE_COMPLETION__will be set to 1 starting from bash-completion v2.2
ifneq ($(__BASH_MAKE_COMPLETION__),1)
  # Help and targets starting with 'list-*' and 'image-*' do not need MACHINE set
  ifneq ($(filter-out help list-% image-%,$(MAKECMDGOALS)),)
    ifeq ($(MACHINE),)
      $(info Available machines are:)
      $(foreach m_name, $(filter-out %common, $(notdir $(wildcard machine/*))), $(info $(m_name)))
      $(error Variable MACHINE must be set!)
    endif

    # Include machine config with a possibility to override everything above
    include machine/$(MACHINE)/$(MACHINE_CONFIG).mk
  endif
endif

comma := ,
# Iterate over lines in LAYERS and fill necessary variables
$(foreach line, $(addprefix url=, $(LAYERS)),                               \
        $(eval line_sep = $(subst ;,  ,$(line)))                            \
        $(eval name := $(lastword $(subst /,  ,$(firstword $(line_sep)))))  \
        $(eval name := $(name:%.git=%))                                     \
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

.PHONY: help
help:
	@echo 'List targets:'
	@echo ' list-machine    - Show available machines'
	@echo ' list-config     - Show available configs for a given machine'
	@echo ''
	@echo 'Cleaning targets:'
	@echo ' distclean       - Remove all generated files and directories'
	@echo ' clean-bbconfigs - Remove bblayers.conf and local.conf files'
	@echo ' clean-deploy    - Remove resulting target images and packages'
	@echo ''
	@echo 'Add/remove layers:'
	@echo ' add-layer       - Add one or multiple layers'
	@echo ' remove-layer    - Remove one or multiple layers. Necessary parameter: LAYERS="<layer1> <layer2>"'
	@echo ''
	@echo 'Working with repository:'
	@echo ' package-index   - Rebuild package index of repository. This is needed after package adding/removing'
	@echo ' ipk-server      - Start webserver for repository sharing. Package index will be rebuilded also'
	@echo ''
	@echo 'Working with docker image:'
	@echo ' image-build     - Build docker image'
	@echo ' image-clean     - Remove docker image'
	@echo ' image-check     - Checking exising docker image, and if not - build it'
	@echo ''
	@echo 'Generic targets:'
	@echo ' all       - Download docker image, yocto and meta layers and build image $(IMAGE_NAME) for machine $(MACHINE)'
	@echo ' devshell  - Invoke developer shell. Can run command in CMD variable'
	@echo ''
	@echo 'Also docker can be run directly:'
	@echo '$$ $(DOCKER_RUN)'
	@echo ''
	@echo 'And then build:'
	@echo 'docker$$ bitbake core-image-minimal meta-toolchain meta-extsdk-toolchain'
	@echo ''
	@echo '=== Usefull tips ===='
	@echo 'Build binaries and images for RoadRunner on BertaD2 baseboard in separate build directory'
	@echo '$$ make MACHINE=sama5d2-roadrunner-bertad2-qspi BUILD_DIR=build-bertad2-qspi IMAGE_NAME=acme-minimal-image all'
	@echo 'Result binaryes and images you can find at $(BUILD_DIR)/tmp/deploy/'
	@echo ''
	@echo 'Rebuild kernel'
	@echo '$$ make devshell CMD="bitbake virtual/kernel"'
	@echo ''
	@echo 'Build binaries, images, SDK and updater for RoadRunner on EvoTiny by bitbake in interactive docker shell'
	@echo '$$ make MACHINE=sama5d2-roadrunner-evo devshell'
	@echo 'docker$$ bitbake virtual/kernel evologics-base-image swupdate-images-evo meta-toolchain packagegroup-erlang-embedded'
	@echo 'docker$$ bitbake evologics-base-image -c do_populate_sdk'
	@echo 'docker$$ bitbake evologics-base-image -c do_populate_sdk_ext'
	@echo ''
	@echo 'Modify the source for an existing recipe'
	@echo 'docker$$ devtool modify virtual/kernel'
	@echo ''
	@echo 'Apply changes from external source tree to recipe'
	@echo 'docker$$ devtool update-recipe --force-patch-refresh --a /work/sources/meta-evo linux-at91'

.PHONY: list-machine list-config layers configure
list-machine:
	@ls -1 machine/ | grep -v common | sed '/$(MACHINE)[-.]/! s/\b$(MACHINE)\b/ * &/g'

list-config:
	@echo " * $(MACHINE):"
	@ls -1 machine/$(MACHINE)/ | grep .mk | sed 's/.mk\b//g' | sed '/$(MACHINE_CONFIG)[-.]/! s/\b$(MACHINE_CONFIG)\b/ * &/g'

all: image-check $(SOURCES_DIR) layers $(BUILD_DIR) configure
	@$(DOCKER_RUN) "bitbake $(IMAGE_NAME) $(MACHINE_BITBAKE_TARGETS)"
	@echo 'Result binaries and images you can find at $(BUILD_DIR)/tmp/deploy/'

devshell: image-check $(SOURCES_DIR) layers $(BUILD_DIR) configure
	@$(DOCKER_RUN) $(CMD)

$(SOURCES_DIR):
	git clone -b $(YOCTO_RELEASE) git://git.yoctoproject.org/poky.git $(SOURCES_DIR)

layers: $(LAYERS_DIR)

$(LAYERS_DIR):
	cd $(SOURCES_DIR) && \
		(git clone -b $(LAYER_$(@F)_branch) $(LAYER_$(@F)_url) || git clone $(LAYER_$(@F)_url))

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

configure: $(BUILD_DIR)/conf/local.conf

# Build directory is created by oe-init-build-env script,
# which is called every run from container entrypoint script
$(BUILD_DIR)/conf/local.conf:
	@echo Creating new build directory: $(BUILD_DIR)
	@$(DOCKER_RUN) "bitbake-layers add-layer $(addprefix $(DOCKER_WORK_DIR)/,$(LAYERS_DIR))"
	@printf "%s\n" $(LOCAL_CONF_OPT) >> $(BUILD_DIR)/conf/local.conf

	@echo Creating config .config.mk
	@echo "MACHINE ?= $(MACHINE)" > .config.mk
	@echo "MACHINE_CONFIG ?= $(MACHINE_CONFIG)" >> .config.mk

	@ln -sf build/tmp/deploy/images/$(MACHINE) deploy-images
	@ln -sf build/tmp/deploy/ipk deploy-ipk

.PHONY: add-layer remove-layer clean-bbconfigs clean-deploy cleanall package-index ipk-server
add-layer: configure layers
	@for LAYER in $(LAYERS_DIR); do \
	$(DOCKER_RUN) "bitbake-layers add-layer $(DOCKER_WORK_DIR)/$$LAYER"; \
	done

remove-layer: configure
	@echo "REMOVING: $(LAYERS_DIR)"
	@echo -n "Press Ctrl-C to cancel"
	@for i in $$(seq 1 5); do echo -n "." && sleep 1; done
	@echo
	@for LAYER in $(LAYERS_DIR); do \
	$(DOCKER_RUN) "bitbake-layers remove-layer $(DOCKER_WORK_DIR)/$$LAYER && rm -rf $(DOCKER_WORK_DIR)/$$LAYER"; \
	done

clean-bbconfigs:
	rm -f $(BUILD_DIR)/conf/local.conf $(BUILD_DIR)/conf/bblayers.conf deploy-images

clean-deploy:
	rm -rf $(BUILD_DIR)/tmp/deploy

cleanall:
	rm -rf $(BUILD_DIR)/tmp $(BUILD_DIR)/sstate-cache

distclean:
	rm -rf $(BUILD_DIR) $(SOURCES_DIR) poky-container .config.mk

package-index:
	@$(DOCKER_RUN) bitbake package-index

ipk-server: package-index
	$(eval IP := $(firstword $(shell ip a | grep dynamic | grep -Po 'inet \K[\d.]+')))
	$(eval PORT := 8080)
	@echo 'Assuming address $(IP):$(PORT)'
	@echo ''
	@echo 'Add following lines to /etc/opkg/opkg.conf'
	@echo ''
	$(eval ipk-archs := $(wildcard $(BUILD_DIR)/tmp/deploy/ipk/*))
	@$(foreach arch, $(ipk-archs),                                      \
	    $(eval arch_strip := $(lastword $(subst /,  ,$(arch))))         \
	    echo 'src/gz $(arch_strip) http://$(IP):$(PORT)/$(arch_strip)'; \
	)
	@echo ''
	@cd $(BUILD_DIR)/tmp/deploy/ipk/ && python -m SimpleHTTPServer $(PORT)

.PHONY: image-build image-clean image-deploy image-check
image-build:
	@cd docker && docker build -t $(DOCKER_IMAGE) .

image-clean:
	@docker container ls | awk '"$(DOCKER_IMAGE)" == $$2{print $$1}' | xargs --no-run-if-empty docker container rm
	@docker image ls | grep -qw '$(DOCKER_IMAGE)' && docker image rm $(DOCKER_IMAGE) || exit 0

image-check:
	@if ! docker inspect $(DOCKER_IMAGE) > /dev/null 2>&1; then \
		echo WARNING: docker image $(DOCKER_IMAGE) do not exist. Build one>&2; \
		$(MAKE) image-build; \
	fi

image-deploy:
	@docker push $(DOCKER_IMAGE)

