# Docker/Yocto Build System Setup 
# 	by komar@evologics.de 2018 Evologics GmbH
# This project helps make build system for embedded platform by using docker and yocto.

MACHINE 		= sama5d2-roadrunner-evomini2
IMAGE_NAME		= core-image-minimal
LOCAL_CONF_OPT	= 'MACHINE			= "$(MACHINE)"'	\
				  'PACKAGE_CLASSES	= "package_ipk"'\
				   'TCLIBC			= "musl"'

BUILD_DIR 	  	= build
YOCTO_RELEASE 	= rocko
LAYERS		   += https://github.com/evologics/meta-evo		\
				  https://github.com/ramok/meta-acme		\
				  https://github.com/linux4sam/meta-atmel

DOCKER_IMAGE 	= crops/poky
DOCKER_REPO 	= debian-9 

DOCKER_RUN		= docker run -it --rm -v $$(pwd):$(DOCKER_WORK_DIR) \
					--name="$(MACHINE)"								\
					$(DOCKER_IMAGE):$(DOCKER_REPO) 					\
					--workdir=$(DOCKER_WORK_DIR)/$(BUILD_DIR) 

DOCKER_WORK_DIR = /work
SOURCES_DIR 	= sources/

# get layer name from url
LAYERS_DIR := $(addprefix $(SOURCES_DIR)/,$(foreach name, $(LAYERS), $(lastword $(subst /,  ,$(name)))))

# make variables LAYER_URL_layer-name equal to url
$(foreach name, $(LAYERS), $(eval LAYER_URL_$(lastword $(subst /,  ,$(name))) := $(name)))

.PHONY: distclean help

help:
	@echo 'Cleaning targets:'
	@echo '	distclean	- Remove all generated files and directories'
	@echo ''
	@echo 'Other generic targets:'
	@echo '	all		- Download docker image, yocto and meta layers and build image $(IMAGE_NAME) for machine $(MACHINE)'
	@echo '	devshell	- Invoke devepoper shell'
	@echo ''
	@echo 'Also docker can be run directly:'
	@echo '$(DOCKER_RUN)'
	@echo ''
	@echo 'And then build:'
	@echo 'bitbake core-image-minimal meta-toolchain'
	@echo ''
	@echo 'Result binaryes and images you can find at $(BUILD_DIR)/tmp/deploy/'

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
	cd $(SOURCES_DIR) && git clone -b $(YOCTO_RELEASE) $(LAYER_URL_$(@F)) || exit 0

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

clean-images:
	rm -rf $(BUILD_DIR)/tmp/deploy

cleanall:
	rm -rf $(BUILD_DIR)/tmp $(BUILD_DIR)/sstate-cache

distclean:
	rm -rf $(BUILD_DIR) $(SOURCES_DIR) poky-container

