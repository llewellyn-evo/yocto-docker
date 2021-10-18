include machine/append-sw-common/qemu-target.mk

LAYERS += git@gitlab.evologics.de:bsp/meta-evo-private.git

LOCAL_CONF_OPT += 'IMAGE_ROOTFS_EXTRA_SPACE = "50000"'

LOCAL_CONF_OPT += 'IMAGE_INSTALL_append = " dune-poggy-comm-$${EVOSN} dune-poggy-comm-$${EVOSN}-etc dune-poggy-comm-$${EVOSN}-default"'

LOCAL_CONF_OPT += 'hostname_pn-base-files = "poggy-comm-$${EVOSN}"'

LOCAL_CONF_OPT += 'IMAGE_CONFIGS = "can"'