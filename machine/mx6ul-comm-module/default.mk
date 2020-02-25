# Image name to build by default
IMAGE_NAME        = commod-minimal-image

# MACHINE is a must in local.conf
LOCAL_CONF_OPT    = 'MACHINE = "$(MACHINE)"'

LOCAL_CONF_OPT    += 'DISTRO  = "yogurt"'

# - "Makes an image suitable for development (e.g. allows root logins without
#    passwords and enables post-installation logging)"
LOCAL_CONF_OPT    += 'EXTRA_IMAGE_FEATURES += "debug-tweaks"'

# Turn on debugging options of the kernel
#LOCAL_CONF_OPT    += 'DEBUG_BUILD_pn-linux-mainline = "1"'

# Turn on debugging options of the barebox
#LOCAL_CONF_OPT    += 'DEBUG_BUILD_pn-barebox = "1"'

# Select configuration UI for linux and barebox r \ecipe. The openembedd
# default is 'menuconfig', 'nconfig' has more features.
# busybox only supports menuconfig
LOCAL_CONF_OPT    += 'KCONFIG_CONFIG_COMMAND = "nconfig"'
LOCAL_CONF_OPT    += 'KCONFIG_CONFIG_COMMAND_pn-busybox = "menuconfig"'

LOCAL_CONF_OPT    += 'PACKAGE_CLASSES = "package_ipk"'


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
LAYERS           += https://github.com/llewellyn-evo/meta-commod.git     \
                    https://github.com/joaohf/meta-erlang;branch=master \
                    git://git.openembedded.org/meta-openembedded;subdirs=meta-oe,meta-python,meta-networking,meta-filesystems,meta-initramfs,meta-multimedia,meta-perl,meta-webserver\
                    https://git.phytec.de/meta-phytec \
                    https://git.phytec.de/meta-yogurt \
                    https://github.com/rauc/meta-rauc.git \
                    https://github.com/OSSystems/meta-gstreamer1.0.git \
                    https://github.com/meta-qt5/meta-qt5.git
