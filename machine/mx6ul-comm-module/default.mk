# Image name to build by default
IMAGE_NAME        = core-image-minimal

# MACHINE is a must in local.conf
LOCAL_CONF_OPT    = 'MACHINE = "$(MACHINE)"'

LOCAL_CONF_OPT    += 'DISTRO  = "yogurt"'

# Select configuration UI for linux and barebox r \ecipe. The openembedd
# default is 'menuconfig', 'nconfig' has more features.
# busybox only supports menuconfig
LOCAL_CONF_OPT    += 'KCONFIG_CONFIG_COMMAND = "nconfig"'
LOCAL_CONF_OPT    += 'KCONFIG_CONFIG_COMMAND_pn-busybox = "menuconfig"'

# Must have for the platform
LOCAL_CONF_OPT   += 'IMAGE_INSTALL_append = " rng-tools iproute2 coreutils grep bridge-utils iputils"'
# Very useful software
LOCAL_CONF_OPT   += 'IMAGE_INSTALL_append = " opkg dropbear bash tar monit procps util-linux"'
# Useful software
LOCAL_CONF_OPT   += 'IMAGE_INSTALL_append = " netcat-openbsd screen tmux socat rsync file daemonize gzip"'
# Hardware tools
LOCAL_CONF_OPT   += 'IMAGE_INSTALL_append = " can-utils i2c-tools pps-tools usbutils ethtool"'
# Development
LOCAL_CONF_OPT   += 'IMAGE_INSTALL_append = " ltrace strace kernel-devicetree tcl expect tcpdump"'
# FAT/exFAT support
LOCAL_CONF_OPT   += 'IMAGE_INSTALL_append = " fuse-exfat e2fsprogs exfat-utils e2fsprogs-resize2fs parted"'
# Init for read-only rootfs
LOCAL_CONF_OPT   += 'IMAGE_INSTALL_append = " evo-envinit"'
# Communication Module Specific
LOCAL_CONF_OPT   += 'IMAGE_INSTALL_append = " gpsd-tiny chrony"'
# Read only rootfs
LOCAL_CONF_OPT 	  += 'EXTRA_IMAGE_FEATURES_append = " read-only-rootfs"'

LOCAL_CONF_OPT    += 'PACKAGE_CLASSES = "package_ipk"'

LOCAL_CONF_OPT += 'BBMASK            += ".*swupdate*"'
LOCAL_CONF_OPT += 'BBMASK            += ".*karo.*"'
LOCAL_CONF_OPT += 'BBMASK            += ".*toradex.*"'
LOCAL_CONF_OPT += 'BBMASK            += ".*at91.*"'
LOCAL_CONF_OPT += 'BBMASK            += ".*librsync.*"'

# Start recording variables which will go to te local.conf file
# If you want do redefine the variable VAR previously set, first use:
#undefine VAR
# Otherwise it will not be recorded and will not show up in local.conf
OLDVARS := $(sort $(.VARIABLES))


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
LAYERS           += https://github.com/EvoLogics/meta-evo.git     \
                    https://github.com/joaohf/meta-erlang;branch=master \
                    git://git.openembedded.org/meta-openembedded;subdirs=meta-oe,meta-python,meta-networking,meta-filesystems,meta-initramfs,meta-multimedia,meta-perl,meta-webserver,\
                    https://git.phytec.de/meta-phytec \
                    https://git.phytec.de/meta-yogurt \
                    https://github.com/rauc/meta-rauc.git \
                    https://github.com/OSSystems/meta-gstreamer1.0.git \
                    https://github.com/meta-qt5/meta-qt5.git
