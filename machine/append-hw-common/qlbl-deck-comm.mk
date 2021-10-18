include machine/append-sw-common/qemu-target.mk

LAYERS += git@gitlab.evologics.de:bsp/meta-evo-private.git

LOCAL_CONF_OPT += 'INHERIT += " userconfig"'

LOCAL_CONF_OPT   += 'IMAGE_INSTALL_append = " sinaps"'

LOCAL_CONF_OPT += 'hostname_pn-base-files = "qlbl-deck-comm-$${EVOSN}"'