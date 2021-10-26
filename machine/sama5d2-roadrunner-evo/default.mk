# Image name to build by default
IMAGE_NAME        = evologics-base-image

# Options to append into local.conf
# NOTE: MACHINE cannot be added in local_conf_options_* section
#       MACHINE already exist in Makefile variables
LOCAL_CONF_OPT  = 'MACHINE            = "$(MACHINE)"'

################ begin build/conf/local.conf options ###################
$(call local_conf_options_begin)

PACKAGE_CLASSES = package_ipk
DISTRO          = poky-evo
TCLIBC          = musl

BBMASK         += .*karo.*
BBMASK         += .*toradex.*
BBMASK         += .*linux-fslc.*
BBMASK         += .*barebox.*
BBMASK         += .*-phy[0-9].*
BBMASK         += .*-phy[0-9].*
BBMASK         += .*systemd-machine-units.bb.*
BBMASK         += .*meta-virtualization/recipes-core/busybox/busybox.*

FORTRAN_forcevariable = ,fortran
RUNTIMETARGET_append_pn-gcc-runtime = libquadmath

$(call local_conf_options_end)
################ end build/conf/local.conf options #####################

# If layer branch not set with "branch=" option, YOCTO_RELEASE will be used.
# If layer has no such branch, 'master' branch will be used.
YOCTO_RELEASE     = thud

# Layers to download and add to the configuration.
# Layers must me in right order, layers used by other layers must become first.
# Syntax: url[;option1=value;option2=value]
# Possible options:
# 	* branch=<branch-to-clone> (by default $(YOCTO_RELEASE))
# 	* subdirs=<subdirectory with meta-layer>[,<subdirectory with meta-layer>]
# 	* srcrev=<tag or hash to checkout>
# 	* patches=<patch in $(TOPDIR)/patches/<meta-layer-name>/>>[,<patch in $(TOPDIR)/patches/<meta-layer-name>/>>]

#LAYERS += https://github.com/linux4sam/meta-atmel;branch=thud;srcrev=4955f98f75a763856d9085ca8962d3c32b5f42ef
LAYERS += https://github.com/linux4sam/meta-atmel
LAYERS += https://github.com/ramok/meta-acme
LAYERS += https://github.com/evologics/meta-evo

# erlang 21.1.0 in zeus branch
#LAYERS += https://github.com/joaohf/meta-erlang;branch=master;srcrev=9c0a7df62de2c93a4eda561b4849610c4d98f511
LAYERS += https://github.com/joaohf/meta-erlang;branch=zeus;patches=0001-Enable-PARALLEL_MAKE.patch

LAYERS += git://git.openembedded.org/meta-openembedded;subdirs=meta-oe,meta-webserver,meta-python,meta-networking,meta-filesystems
LAYERS += git://git.yoctoproject.org/meta-virtualization.git
LAYERS += https://github.com/sbabic/meta-swupdate

# poky layer do not handle like meta-layers patches, need to add path to patches
# for example LAYER_poky_patches = $(TOPDIR)/patches/1.patch  $(TOPDIR)/patches/2.patch
LAYER_poky_patches = 0001-image_types.bbclass-add-support-for-multiply-ubifs-v.patch

MACHINE_BITBAKE_TARGETS = meta-toolchain swupdate-images-evo packagegroup-erlang-embedded \
						  evologics-base-image:do_populate_sdk evologics-base-image:do_populate_sdk_ext
#						  && bitbake evologics-base-image -c do_populate_sdk && bitbake evologics-base-image -c do_populate_sdk_ext

TARGET_ALL_DEPEND = private/evo-updater.pem private/evo-updater.pub.pem private/evo-updater.pass
$(TARGET_ALL_DEPEND):
	@echo "You should copy file \"$(TARGET_ALL_DEPEND)\" to project root directory" >&2
	@exit 1
