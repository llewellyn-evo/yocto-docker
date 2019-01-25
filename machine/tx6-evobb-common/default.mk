# Image name to build by default
IMAGE_NAME        = core-image-minimal

# Options to append into local.conf
LOCAL_CONF_OPT    = 'MACHINE            = "$(MACHINE)"'         \
                    'PACKAGE_CLASSES    = "package_ipk"'        \
                    'TCLIBC             = "glibc"'              \
                    'CORE_IMAGE_EXTRA_INSTALL += " opkg dropbear screen tcl expect rsync socat dune canutils iproute2 ltrace file pciutils usbutils ethtool util-linux monit "' \
                    'PREFERRED_VERSION_linux-karo = "4.4.y"'   \

# Build dir
BUILD_DIR         = build

# If layer branch not set with "branch=" option, YOCTO_RELEASE will be used.
# If layer has no such branch, 'master' branch will be used.
YOCTO_RELEASE     = rocko

# Layers to download and add to the configuration.
# Layers must me in right order, layers used by other layers must become first.
# Syntax: url[;option1=value;option2=value]
# Possible options:
# 	* branch=<branch-to-clone>
# 	* subdirs=<subdirectory with meta-layer>[,<subdirectory with meta-layer>]
LAYERS           += https://github.com/linux4sam/meta-atmel      \
                    https://github.com/ramok/meta-acme           \
                    git://git.openembedded.org/meta-openembedded;subdirs=meta-oe \
                    https://git.yoctoproject.org/git/meta-freescale \
                    https://github.com/evologics/meta-freescale-3rdparty \
                    https://github.com/evologics/meta-evo
