include machine/append-sw-common/sinaps.mk

LAYERS += git@gitlab.evologics.de:bsp/meta-evo-private.git

LOCAL_CONF_OPT += 'INHERIT += " userconfig"'

LOCAL_CONF_OPT += 'IMAGE_INSTALL_append = " htop soft-hwclock"'

LOCAL_CONF_OPT += 'IMAGE_INSTALL_append = " dune-usbl-buoy-$${EVOSN} dune-usbl-buoy-$${EVOSN}-etc dune-usbl-buoy-$${EVOSN}-default"'

LOCAL_CONF_OPT += 'hostname_pn-base-files = "usbl-buoy-comm-$${EVOSN}"'
