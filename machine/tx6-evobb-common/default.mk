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
CORE_IMAGE_EXTRA_INSTALL    = opkg dropbear rng-tools \
                              screen tmux netcat-openbsd tcl expect rsync socat dune \
                              tar can-utils i2c-tools daemonize \
                              iproute2 ltrace file pciutils usbutils \
                              rsync procps \
                              ethtool util-linux monit \
                              kernel-devicetree \
                              fuse-exfat bash e2fsprogs exfat-utils
#CORE_IMAGE_EXTRA_INSTALL  += strace openssh-client keychain
#CORE_IMAGE_EXTRA_INSTALL  += chrony gpsd-tiny pps-tools kernel-module-pps-gpio

PREFERRED_VERSION_linux-karo = 4.4.y
PRSERV_HOST = localhost:0

DISTRO_FEATURES_remove = bluetooth

# Actually add recorded variables to LOCAL_CONF_OPT
NEWVARS := $(sort $(.VARIABLES))
$(call add_to_local_conf_opt)

# Options to append into local.conf
#LOCAL_CONF_OPT    = 'MACHINE            = "$(MACHINE)"'                                  \
#                    'PACKAGE_CLASSES    = "$(PACKAGE_CLASSES)"'                          \
#                    'TCLIBC             = "$(TCLIBC)"'                                   \
#                    'CORE_IMAGE_EXTRA_INSTALL    += "$(CORE_IMAGE_EXTRA_INSTALL)"'       \
#                    'PREFERRED_VERSION_linux-karo = "$(PREFERRED_VERSION_linux-karo)"'   \

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
                    https://github.com/evologics/meta-evo

MACHINE_BITBAKE_TARGETS = u-boot
