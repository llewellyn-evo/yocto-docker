include machine/append-sw-common/qemu-target.mk

LAYERS += git@gitlab.evologics.de:bsp/meta-evo-private.git

LOCAL_CONF_OPT += 'INHERIT += " userconfig"'

LOCAL_CONF_OPT += 'IMAGE_ROOTFS_EXTRA_SPACE = "50000"'

LOCAL_CONF_OPT += 'IMAGE_INSTALL_append = " dune-snrs-$${EVOSN} dune-snrs-$${EVOSN}-etc dune-snrs-$${EVOSN}-default"'

LOCAL_CONF_OPT += 'hostname_pn-base-files = "snrs-$${EVOSN}"'