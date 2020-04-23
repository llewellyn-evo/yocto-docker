# Image name to build by default
IMAGE_NAME        = core-image-minimal

# MACHINE is a must in local.conf
LOCAL_CONF_OPT    = 'MACHINE = "$(MACHINE)"'

# Start recording variables which will go to the local.conf file
# If you want do redefine the variable VAR previously set, first use:
#undefine VAR
# Otherwise it will not be recorded and will not show up in local.conf
OLDVARS := $(sort $(.VARIABLES))

# Define what we need
PACKAGE_CLASSES             = package_ipk
TCLIBC                      = glibc

# Must have for the platform
CORE_IMAGE_EXTRA_INSTALL    = rng-tools iproute2
# Very useful software
CORE_IMAGE_EXTRA_INSTALL   += opkg dropbear bash tar monit procps util-linux \
                              e2fsprogs e2fsprogs-resize2fs
# Useful software
CORE_IMAGE_EXTRA_INSTALL   += netcat-openbsd screen tmux socat rsync file daemonize
# Hardware tools
CORE_IMAGE_EXTRA_INSTALL   += can-utils i2c-tools pps-tools pciutils usbutils ethtool
# Development
CORE_IMAGE_EXTRA_INSTALL   += ltrace strace kernel-devicetree tcl expect
# FAT/exFAT support
CORE_IMAGE_EXTRA_INSTALL   += fuse-exfat exfat-utils
# Init for read-only rootfs
CORE_IMAGE_EXTRA_INSTALL   += evo-envinit

#CORE_IMAGE_EXTRA_INSTALL  += openssh-client keychain
#CORE_IMAGE_EXTRA_INSTALL  += chrony gpsd-tiny kernel-module-pps-gpio

PREFERRED_PROVIDER_virtual/kernel = linux-toradex
PRSERV_HOST = localhost:0

DISTRO_FEATURES_remove = bluetooth
EXTRA_IMAGE_FEATURES_append = read-only-rootfs

# Actually add recorded variables to LOCAL_CONF_OPT
NEWVARS := $(sort $(.VARIABLES))
$(call add_to_local_conf_opt)

# Build dir
BUILD_DIR         = build

# If layer branch not set with "branch=" option, YOCTO_RELEASE will be used.
# If layer has no such branch, 'master' branch will be used.
YOCTO_RELEASE     = thud

# Layers to download and add to the configuration.
# Layers must me in right order, layers used by other layers must become first.
# Syntax: url[;option1=value;option2=value]
# Possible options:
# 	* branch=<branch-to-clone>
# 	* subdirs=<subdirectory with meta-layer>[,<subdirectory with meta-layer>]
LAYERS           += https://github.com/linux4sam/meta-atmel      \
                    https://github.com/ramok/meta-acme           \
                    git://git.openembedded.org/meta-openembedded;subdirs=meta-oe,meta-python,meta-networking,meta-filesystems \
                    https://git.yoctoproject.org/git/meta-freescale \
                    https://github.com/evologics/meta-freescale-3rdparty \
                    https://github.com/sbabic/meta-swupdate \
                    git://git.toradex.com/meta-toradex-bsp-common.git \
                    git://git.toradex.com/meta-toradex-nxp.git \
                    https://github.com/evologics/meta-evo

MACHINE_BITBAKE_TARGETS = u-boot
