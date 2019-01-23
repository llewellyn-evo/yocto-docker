# Image name to build by default
IMAGE_NAME        = core-image-minimal

# Options to append into local.conf
LOCAL_CONF_OPT    = 'MACHINE            = "$(MACHINE)"'    \
                    'PACKAGE_CLASSES    = "package_ipk"'   \
                    'DISTRO             = "poky-evo"' 	   \
                    'TCLIBC             = "musl"'

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
                    https://github.com/evologics/meta-evo        \
                    git://git.openembedded.org/meta-openembedded;subdirs=meta-oe,meta-webserver,meta-networking
