# Image name to build by default
IMAGE_NAME        = evologics-base-image

# Options to append into local.conf
LOCAL_CONF_OPT  = 'MACHINE            = "$(MACHINE)"'
LOCAL_CONF_OPT += 'PACKAGE_CLASSES    = "package_ipk"'
LOCAL_CONF_OPT += 'DISTRO             = "poky-evo"'
LOCAL_CONF_OPT += 'TCLIBC             = "musl"'
LOCAL_CONF_OPT += 'BBMASK            += ".*karo.*"'
LOCAL_CONF_OPT += 'BBMASK            += ".*toradex.*"'


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
                    https://github.com/evologics/meta-evo        \
                    https://github.com/joaohf/meta-erlang;branch=master \
                    git://git.openembedded.org/meta-openembedded;subdirs=meta-oe,meta-webserver,meta-python,meta-networking \
                    https://github.com/sbabic/meta-swupdate

MACHINE_BITBAKE_TARGETS = meta-toolchain swupdate-images-evo
