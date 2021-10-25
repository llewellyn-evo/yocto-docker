# Yocto/Docker Build System Setup
#     by komar@evologics.de 2018-2021 Evologics GmbH
#     by viktor.voronin@evologics.de Evologics GmbH
#     by llewellyn.fernandes@evologics.de Evologics GmbH
# This project helps make build system for embedded platform by using docker and yocto.
#
# TODO: add Makefile to build-* directory, to call ../Makefile. which detected
# if make runned inside docker, call same commands with bitbake, but without docker

# Uncomment this if you want use local builded docker image
#USE_LOCAL_DOCKER_IMAGE=1

# Comment this if you don't want create symlinks in project root directory to usefull directories
CREATE_USEFULL_SYMLINKS = 1

YOCTO_RELEASE     = thud

DOCKER_REGISTRY   = docker.evologics.de
DOCKER_IMAGE      = evologics/yocto:$(YOCTO_RELEASE)

SSTATE_CACHE_DIR  = share/$(YOCTO_RELEASE)/$(MACHINE)/sstate-cache
################### begin build enviroment variable #########################
# Change this if you have shared 'downloads' directory for yocto
LOCAL_CONF_OPT_DL_DIR = $$$${TOPDIR}/../share/downloads

# Change this if you have shared 'sstate-cache' directory for yocto
LOCAL_CONF_OPT_SSTATE_DIR = $$$${TOPDIR}/../$(SSTATE_CACHE_DIR)

# Change this if you want point tmp dir to RAM disk
LOCAL_CONF_OPT_TMPDIR = $$$${TOPDIR}/tmp

LOCAL_CONF_OPT_BB_NUMBER_THREADS  = 8
LOCAL_CONF_OPT_PARALLEL_MAKE      = -j 8

PROJ_TOP_DIR := $(abspath $(dir $(firstword $(MAKEFILE_LIST))))
# Folders with source and build files
SOURCES_DIR       = sources
BUILD_DIR        ?= build-$(MACHINE)

# If layer branch not set with "branch=" option, YOCTO_RELEASE will be used.
# If layer has no such branch, 'master' branch will be used.
GIT_CLONE = git clone
# Usefull for CI/CD to fetch less data
#GIT_CLONE = git clone --single-branch

ifneq ($(wildcard /usr/bin/time),)
	TIME = /usr/bin/time -f "real %e user %U sys %S"
endif

################### end build enviroment variable ###########################

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

# Docker settings
ifneq ($(USE_LOCAL_DOCKER_IMAGE),)
	DOCKER_IMAGE := $(DOCKER_IMAGE)
else
	DOCKER_IMAGE := $(DOCKER_REGISTRY)/$(DOCKER_IMAGE)
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

################### begin helpers #########################
# Filter out duplicated words in list
uniq   = $(strip $(if $1,$(firstword $1) $(call uniq,$(filter-out $(firstword $1),$1))))

# Reverse list
reverse = $(if $(1),$(call reverse,$(wordlist 2,$(words $(1)),$(1)))) $(firstword $(1))

# Just comma to use in macroses
comma := ,

# Start recording variables which will go to the local.conf file
# If you want do redefine the variable VAR previously set, first use:
#undefine VAR
# Otherwise it will not be recorded and will not show up in local.conf
define local_conf_options_begin
    $(eval __VARIABLES_OLD := $(sort $(.VARIABLES)))
endef

define local_conf_options_set
    $(if $(findstring pend, $(1)), \
	    $(eval LOCAL_CONF_OPT += '$(1) = " $(2) "'), \
	    $(eval LOCAL_CONF_OPT += '$(1) = "$(2)"') \
	)
endef

# Actually add recorded variables to LOCAL_CONF_OPT
define local_conf_options_end
	$(if $(__VARIABLES_OLD), \
		$(foreach v, $(sort $(.VARIABLES)), \
			$(if $(filter-out __VARIABLES_OLD $(__VARIABLES_OLD),$(v)), \
				$(call local_conf_options_set,$(v),$($v)) \
			) \
		)
		$(eval undefine __VARIABLES_OLD)
	,)
endef
################### end helpers ###########################

# Include saved configs
-include .config.mk
-include .build-host-config.mk
# Use default MACHINE_CONFIG if it`s not defined
MACHINE_CONFIG ?= default

# Do not attempt to include something if running for bash completion
# __BASH_MAKE_COMPLETION__will be set to 1 starting from bash-completion v2.2
ifneq ($(__BASH_MAKE_COMPLETION__),1)
  # Help and targets starting with 'list-*' and 'image-*' do not need MACHINE set
  ifneq ($(filter-out help list-% image-%,$(MAKECMDGOALS)),)
    ifeq ($(MACHINE),)
      ifneq ($(shell test -t 0 && echo tty),)
        ROOT_DIR:=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))
        $(shell $(ROOT_DIR)/lazyconf.sh > $$(tty))
        -include .config.mk
      else
        $(info Available machines are:)
        $(foreach m_name, $(filter-out %common, $(notdir $(wildcard machine/*))), $(info $(m_name)))
        $(error Variable MACHINE must be set!)
      endif
    endif

    # Include machine config with a possibility to override everything above
    include machine/$(MACHINE)/$(MACHINE_CONFIG).mk
  endif
endif

# Trick to remove duplicates from LAYERS
$(eval LAYERS = $(sort $(LAYERS)))

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
        $(if $(value LAYER_$(name)_patches),                                \
            $(eval LAYER_$(name)_patches :=                                 \
                $(addprefix $(PROJ_TOP_DIR)/patches/$(name)/,               \
                    $(subst $(comma),  ,$(LAYER_$(name)_patches)))),        \
        )                                                                   \
 )

# Put LOCAL_CONF_OPT_* to LOCAL_CONF_OPT
$(foreach v, $(filter LOCAL_CONF_OPT_%,$(.VARIABLES)),\
    $(call local_conf_options_set,$(subst LOCAL_CONF_OPT_,,$(v)),$($v)) \
)

.PHONY: help
help:
	@echo Variables:
	@echo 'USE_LOCAL_DOCKER_IMAGE=1  - Use local builded docker image. Disabled by default'
	@echo 'CREATE_USEFULL_SYMLINKS=1 - Create symbolic links to usefull directories. Enabled by default'
	@echo
	@echo LOCAL_CONF_OPT_DL_DIR=\''$(LOCAL_CONF_OPT_DL_DIR)'\'
	@echo LOCAL_CONF_OPT_SSTATE_DIR=\''$(LOCAL_CONF_OPT_SSTATE_DIR)'\'
	@echo LOCAL_CONF_OPT_TMPDIR=\''$(LOCAL_CONF_OPT_TMPDIR)'\'
	@echo LOCAL_CONF_OPT_BB_NUMBER_THREADS=\''$(LOCAL_CONF_OPT_BB_NUMBER_THREADS)'\'
	@echo LOCAL_CONF_OPT_PARALLEL_MAKE=\''$(LOCAL_CONF_OPT_PARALLEL_MAKE)'\'
	@echo
	@echo YOCTO_RELEASE=$(YOCTO_RELEASE)
	@echo DOCKER_REGISTRY=$(DOCKER_REGISTRY)
	@echo DOCKER_IMAGE=$(DOCKER_IMAGE)
	@echo
	@echo 'List targets:'
	@echo ' list-machine    - Show available machines'
	@echo ' list-config     - Show available configs for a given machine'
	@echo ''
	@echo 'Cleaning targets:'
	@echo ' distclean       - Remove all generated files and directories'
	@echo ' cleanall        - Remove all generated files and directories in build directory'
	@echo ' clean-bbconfigs - Remove bblayers.conf and local.conf files'
	@echo ' clean-deploy    - Remove resulting target images and packages'
	@echo ''
	@echo 'Add/remove layers:'
	@echo ' add-layer       - Add one or multiple layers'
	@echo ' remove-layer    - Remove one or multiple layers. Necessary parameter: LAYERS="<layer1> <layer2>"'
	@echo '                   WARNING: by default will be removed all layers. Dirty repo will be not removed'
	@echo ''
	@echo 'Working with repository:'
	@echo ' package-index   - Rebuild package index of repository. This is needed after package adding/removing'
	@echo ' ipk-server      - Start webserver for repository sharing. Package index will be rebuilded also'
	@echo ''
	@echo 'Working with docker image:'
	@echo ' image-build     - Build docker image'
	@echo ' image-clean     - Remove docker image'
	@echo ' image-check     - Checking exising docker image, and if not - build or pull it'
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
	@echo 'docker$$ bitbake virtual/kernel evologics-base-image swupdate-images-evo meta-toolchain '\
		'packagegroup-erlang-embedded evologics-base-image:do_populate_sdk evologics-base-image:do_populate_sdk_ext'
	@echo 'docker$$ bitbake evologics-base-image:do_populate_sdk'
	@echo 'docker$$ bitbake evologics-base-image:do_populate_sdk_ext'
	@echo ''
	@echo 'Update package index of local repository'
	@echo 'docker$$ bitbake package-index'
	@echo ''
	@echo 'Modify the source for an existing recipe'
	@echo 'docker$$ devtool modify virtual/kernel'
	@echo ''
	@echo 'Configure kernel'
	@echo 'docker$$ bitbake virtual/kernel -fc menuconfig'
	@echo 'docker$$ bitbake virtual/kernel -fc diffconfig'
	@echo ''
	@echo 'Create new recipe'
	@echo 'docker$$ devtool add liblxc https://linuxcontainers.org/downloads/lxc/lxc-4.0.9.tar.gz'
	@echo ''
	@echo 'Deploy to target for testing'
	@echo 'docker$$ devtool deploy-target dtach toor@10.14.179.1'
	@echo ''
	@echo 'Apply changes from external source tree to recipe'
	@echo 'docker$$ devtool update-recipe --force-patch-refresh --a /work/sources/meta-evo linux-at91'
	@echo ''
	@echo 'Remove a recipe from workspace'
	@echo 'docker$$ devtool reset linux-at91'
	@echo ''
	@echo 'Finish working on a recipe in workspace (update-recipe + reset)'
	@echo 'docker$$ devtool finish linux-at91 /work/sources/meta-evo'

.build-host-config.mk:
	@test -t 1 && echo Creating config .build-host-config.mk
	@echo 'LOCAL_CONF_OPT_DL_DIR            ?= $(LOCAL_CONF_OPT_DL_DIR)'             > .build-host-config.mk
	@echo 'LOCAL_CONF_OPT_SSTATE_DIR        ?= $(LOCAL_CONF_OPT_SSTATE_DIR)'        >> .build-host-config.mk
	@echo 'LOCAL_CONF_OPT_TMPDIR            ?= $(LOCAL_CONF_OPT_TMPDIR)'            >> .build-host-config.mk
	@echo 'LOCAL_CONF_OPT_BB_NUMBER_THREADS ?= $(LOCAL_CONF_OPT_BB_NUMBER_THREADS)' >> .build-host-config.mk
	@echo 'LOCAL_CONF_OPT_PARALLEL_MAKE     ?= $(LOCAL_CONF_OPT_PARALLEL_MAKE)'     >> .build-host-config.mk

.PHONY: list-machine list-config configure ci-deploy
list-machine:
	@ls -1 machine/ | grep -v common | sed '/$(MACHINE)[-.]/! s/\b$(MACHINE)\b/ * &/g'

list-config:
	@echo " * $(MACHINE):"
	@ls -1 machine/$(MACHINE)/ | grep .mk | sed 's/.mk\b//g' | sed '/$(MACHINE_CONFIG)[-.]/! s/\b$(MACHINE_CONFIG)\b/ * &/g'

all: image-check $(PROJ_TOP_DIR)/$(SOURCES_DIR) $(LAYERS_DIR) $(BUILD_DIR) configure $(TARGET_ALL_DEPEND)
	@$(TIME) $(DOCKER_RUN) "bitbake $(IMAGE_NAME) $(MACHINE_BITBAKE_TARGETS)"
	@echo 'Result binaries and images you can find at $(BUILD_DIR)/tmp/deploy/'

devshell: image-check $(PROJ_TOP_DIR)/$(SOURCES_DIR) $(LAYERS_DIR) $(BUILD_DIR) configure
	@$(DOCKER_RUN) $(CMD)

$(PROJ_TOP_DIR)/$(SOURCES_DIR):
	@$(GIT_CLONE) -b $(YOCTO_RELEASE) git://git.yoctoproject.org/poky.git $(PROJ_TOP_DIR)/$(SOURCES_DIR)
	@if [ -n "$(LAYER_poky_patches)" ]; then \
		cd $(PROJ_TOP_DIR)/$(SOURCES_DIR); \
		git am $(PROJ_TOP_DIR)/patches/$(LAYER_poky_patches); \
	fi

$(call uniq,$(LAYERS_DIR)):
	@cd $(PROJ_TOP_DIR)/$(SOURCES_DIR) && \
		($(GIT_CLONE) -b $(LAYER_$(@F)_branch) $(LAYER_$(@F)_url) || $(GIT_CLONE) $(LAYER_$(@F)_url))
	@if [ -n "$(LAYER_$(@F)_srcrev)" ]; then      \
		cd $(PROJ_TOP_DIR)/$(SOURCES_DIR)/$(@F); \
		git checkout $(LAYER_$(@F)_srcrev);      \
	fi
	@if [ -n "$(LAYER_$(@F)_patches)" ]; then     \
		cd $(PROJ_TOP_DIR)/$(SOURCES_DIR)/$(@F); \
		git am $(LAYER_$(@F)_patches); \
	fi

$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)
	@ln -sfT $(BUILD_DIR) build

ifneq ($(CREATE_USEFULL_SYMLINKS),)
    SYMLINK_TO_DIR_images = build/tmp/deploy/images/$(MACHINE)
    SYMLINK_TO_DIR_ipk    = build/tmp/deploy/ipk
    SYMLINK_TO_DIR_sdk    = build/tmp/deploy/sdk
    SYMLINK_TO_DIR_kernel-source = build/tmp/work-shared/$(MACHINE)/kernel-source
    SYMLINK_TO_DIR_kernel-build-artifacts = build/tmp/work-shared/$(MACHINE)/kernel-build-artifacts

    $(foreach v, $(filter SYMLINK_TO_DIR_%,$(.VARIABLES)),\
        $(eval USEFULL_SYMLINKS += $(patsubst SYMLINK_TO_DIR_%,%,$(v))) \
    )

$(USEFULL_SYMLINKS):
	@ln -fsT $(SYMLINK_TO_DIR_$(@F)) $(@F)

endif

configure: $(BUILD_DIR)/conf/local.conf

LOCAL_CONF_MARK = \#=== This block automatically generated. Do not change nothing there ===
# Build directory is created by oe-init-build-env script,
# which is called every run from container entrypoint script
$(BUILD_DIR)/conf/local.conf: $(PROJ_TOP_DIR)/$(SOURCES_DIR) $(LAYERS_DIR) $(BUILD_DIR) $(USEFULL_SYMLINKS)
	@echo Update $(BUILD_DIR)/conf/local.conf
	@$(DOCKER_RUN) "bitbake-layers add-layer $(addprefix $(DOCKER_WORK_DIR)/,$(LAYERS_DIR))"
	@sed -i '/$(LOCAL_CONF_MARK)/,/$(LOCAL_CONF_MARK)/d' $(BUILD_DIR)/conf/local.conf
	@echo '$(LOCAL_CONF_MARK)'                        >> $(BUILD_DIR)/conf/local.conf
	@printf "%s\n" $(LOCAL_CONF_OPT)                  >> $(BUILD_DIR)/conf/local.conf
	@echo '$(LOCAL_CONF_MARK)'                        >> $(BUILD_DIR)/conf/local.conf

	@echo Update .config.mk
	@echo "MACHINE ?= $(MACHINE)" > .config.mk
	@echo "MACHINE_CONFIG ?= $(MACHINE_CONFIG)" >> .config.mk

.PHONY: add-layer remove-layer clean-bbconfigs clean-deploy cleanall package-index ipk-server
add-layer: configure $(LAYERS_DIR)
	@for LAYER in $(LAYERS_DIR); do \
	$(DOCKER_RUN) "bitbake-layers add-layer $(DOCKER_WORK_DIR)/$$LAYER"; \
	done

remove-layer: configure
	@echo "REMOVING: $(LAYERS_DIR)"
	@for LAYER in $(LAYERS_DIR); do \
		cd $(PROJ_TOP_DIR)/$$LAYER; \
		DIR="$(git rev-parse --show-toplevel)";\
		[ -d "$$DIR" ] && cd $$DIR; \
		if ! git diff --quiet; then \
			echo "Layer $$LAYER are dirty. Will not remove"; \
			exit 1; \
		fi; \
	done
	@echo -n "Press Ctrl-C to cancel"
	@for i in $$(seq 1 5); do echo -n "." && sleep 1; done
	@echo
	@for LAYER in $(call reverse,$(LAYERS_DIR)); do \
	    echo Removing $(DOCKER_WORK_DIR)/$$LAYER; \
	    $(DOCKER_RUN) "bitbake-layers remove-layer $(DOCKER_WORK_DIR)/$$LAYER && \
			rm -rf $(PROJ_TOP_DIR)/$$LAYER"; \
	done

clean-bbconfigs:
	rm -f $(BUILD_DIR)/conf/local.conf $(BUILD_DIR)/conf/bblayers.conf deploy-images $(USEFULL_SYMLINKS)

clean-deploy:
	rm -rf $(BUILD_DIR)/tmp/deploy

cleanall:
	rm -rf $(BUILD_DIR)/tmp $(PROJ_TOP_DIR)/share/$(YOCTO_RELEASE)/$(MACHINE)/sstate-cache

distclean:
	rm -rf $(BUILD_DIR) $(PROJ_TOP_DIR)/$(SOURCES_DIR) .config.mk $(USEFULL_SYMLINKS)

package-index:
	@$(DOCKER_RUN) bitbake package-index

ipk-server: package-index
	$(eval IP := $(shell ip a | sed -n '/dynamic/s/.*inet \([^/]*\).*/\1/p;T;q'))
	$(eval PORT := 8080)
	@echo 'Assuming address $(IP):$(PORT)'
	@echo ''
	@echo 'Add following lines to /etc/opkg/opkg.conf'
	@echo ''

	@# NOTE: path/*/. is trick to match only directory
	$(eval ipk-archs :=    $(patsubst %/.,%,$(wildcard $(BUILD_DIR)/tmp/deploy/ipk/*/.)))
	@# filter out directory with -dummy- in name
	$(eval dummy-filter := $(patsubst %/.,%,$(wildcard $(BUILD_DIR)/tmp/deploy/ipk/*-dummy-*/.)))
	$(eval ipk-archs :=    $(filter-out $(dummy-filter),$(ipk-archs)))

	@$(foreach arch, $(ipk-archs),                                      \
	    $(eval arch_strip := $(lastword $(subst /,  ,$(arch))))         \
	    echo 'src/gz $(arch_strip) http://$(IP):$(PORT)/ipk/$(arch_strip)'; \
	)
	@echo ''
	@cd $(BUILD_DIR)/tmp/deploy/; \
		python3 -m http.server $(PORT) || \
		python2 -m SimpleHTTPServer $(PORT)

image-build:
	@cd docker && docker build -t $(DOCKER_IMAGE) .
.PHONY: image-build

# help: check dockerd is running
docker-check:
	@docker ps > /dev/null
.PHONY: docker-check

# help: clean docker image and remove packed toolchains
image-clean: docker-check
	@docker container ls | awk '"$(DOCKER_IMAGE)$(suffix $@)" == $$1 && "$(YOCTO_RELEASE)" == $$2{print $$1":"$$2}' | \
		xargs --no-run-if-empty docker container rm
	@docker inspect --type=image $(DOCKER_IMAGE) > /dev/null 2>&1 && \
		docker image rm $(DOCKER_IMAGE)$(suffix $@) || exit 0
.PHONY: image-clean

image-check: docker-check
ifneq ($(USE_LOCAL_DOCKER_IMAGE),)
	@if ! docker inspect $(DOCKER_IMAGE) > /dev/null 2>&1; then \
		echo WARNING: docker image $(DOCKER_IMAGE) do not exist. Build one>&2; \
		$(MAKE) image-build; \
	fi
else
	@if ! docker inspect $(DOCKER_IMAGE) > /dev/null 2>&1; then \
		echo WARNING: docker image $(DOCKER_IMAGE) do not exist. Pull one>&2; \
		$(MAKE) image-pull; \
	fi
.PHONY: image-check

# help: pull docker image from registry
image-pull: docker-check registry-login
	@docker pull $(DOCKER_IMAGE)
.PHONY: image-pull

# help: push docker image to registry
image-push: docker-check registry-login
	@docker push $(DOCKER_IMAGE)
endif
.PHONY: image-push

# Naive implementation
# Does not check for different image formats
ci-deploy:
	$(eval CI_DEP_DIR := $(CI_PATH:%/=%)/$(MACHINE)/$(MACHINE_CONFIG))
	mkdir -p $(CI_DEP_DIR)
	cp -L deploy-images/$(IMAGE_NAME)-$(MACHINE).tar.bz2 $(CI_DEP_DIR) \
		|| exit 1
	cp -L deploy-images/$(MACHINE).dtb $(CI_DEP_DIR) \
		|| exit 1
	cp -L deploy-images/modules-$(MACHINE).tgz $(CI_DEP_DIR) \
		|| exit 1
	cp -L deploy-images/u-boot-$(MACHINE).bin $(CI_DEP_DIR) \
		|| exit 1
	cp -L deploy-images/uImage-$(MACHINE).bin $(CI_DEP_DIR) \
		|| cp -L deploy-images/zImage-$(MACHINE).bin $(CI_DEP_DIR) \
		|| exit 1

registry-login:
	@docker login $(DOCKER_REGISTRY)
.PHONY: registry-login
