# Image name to build by default
IMAGE_NAME        = core-image-minimal

# MACHINE is a must in local.conf
LOCAL_CONF_OPT    = 'MACHINE = "$(MACHINE)"'

LOCAL_CONF_OPT    += 'DISTRO  = "yogurt"'

# Start recording variables which will go to te local.conf file
# If you want do redefine the variable VAR previously set, first use:
#undefine VAR
# Otherwise it will not be recorded and will not show up in local.conf
OLDVARS := $(sort $(.VARIABLES))

# Select configuration UI for linux and barebox recipe. The openembedd
# default is 'menuconfig', 'nconfig' has more features.
# busybox only supports menuconfig
LOCAL_CONF_OPT    += 'KCONFIG_CONFIG_COMMAND = "nconfig"'
LOCAL_CONF_OPT    += 'KCONFIG_CONFIG_COMMAND_pn-busybox = "menuconfig"'

# Must have for the platform
LOCAL_CONF_OPT   += 'IMAGE_INSTALL_append = " rng-tools iproute2 coreutils grep bridge-utils iputils iperf3 net-tools rauc rauc-hawkbit "'
# Very useful software
LOCAL_CONF_OPT   += 'IMAGE_INSTALL_append = " opkg dropbear bash tar procps util-linux ckermit rauc-update-usb tzdata"'
# Package groups
LOCAL_CONF_OPT   += 'IMAGE_INSTALL_append = " packagegroup-machine-base packagegroup-core-boot packagegroup-update packagegroup-rt"'
# Useful software
LOCAL_CONF_OPT   += 'IMAGE_INSTALL_append = " netcat-openbsd screen tmux socat rsync file daemonize gzip lrzsz bc"'
# Hardware tools
LOCAL_CONF_OPT   += 'IMAGE_INSTALL_append = " can-utils i2c-tools pps-tools usbutils ethtool libgpiod"'
# Development
LOCAL_CONF_OPT   += 'IMAGE_INSTALL_append = " ltrace strace kernel-devicetree tcl expect tcpdump"'
# FAT/exFAT support
LOCAL_CONF_OPT   += 'IMAGE_INSTALL_append = " fuse-exfat e2fsprogs exfat-utils e2fsprogs-resize2fs parted"'
# Init for read-only rootfs
LOCAL_CONF_OPT   += 'IMAGE_INSTALL_append = " nio-envinit"'
# Communication Module Specific
#LOCAL_CONF_OPT   += 'IMAGE_INSTALL_append = " gpsd-tiny chrony dt-utils dt-utils-barebox-state soft-hwclock"'

LOCAL_CONF_OPT   += 'EXTRA_IMAGE_FEATURES_append = " package-management "'

LOCAL_CONF_OPT   += 'IMAGE_ROOTFS_SIZE ?= "8192"'

LOCAL_CONF_OPT   += 'PACKAGE_CLASSES = "package_ipk "'

LOCAL_CONF_OPT   += 'TCLIBC = "glibc"'
################ begin build/conf/local.conf options ###################
$(call local_conf_options_begin)

$(call local_conf_options_end)
################ end build/conf/local.conf options #####################

# If layer branch not set with "branch=" option, YOCTO_RELEASE will be used.
# If layer has no such branch, 'master' branch will be used.
YOCTO_RELEASE     = thud

# Layers to download and add to the configuration.
# Layers must me in right order, layers used by other layers must become first.
# Syntax: url[;option1=value;option2=value]
# Possible options:
# 	* branch=<branch-to-clone>
# 	* subdirs=<subdirectory with meta-layer>[,<subdirectory with meta-layer>]

LAYERS	+= git://git.openembedded.org/meta-openembedded;subdirs=meta-filesystems,meta-initramfs,meta-networking,meta-perl,meta-webserver,meta-gnome,meta-multimedia,meta-oe,meta-python,meta-xfce

LAYERS 	+= https://git.phytec.de/meta-phytec

LAYERS	+= https://git.phytec.de/meta-yogurt

LAYERS	+= https://github.com/rauc/meta-rauc.git

LAYERS	+= https://github.com/OSSystems/meta-gstreamer1.0.git

LAYERS	+= https://github.com/meta-qt5/meta-qt5.git

LAYERS	+= https://github.com/llewellyn-evo/meta-nio.git

#MACHINE_BITBAKE_TARGETS = meta-toolchain
