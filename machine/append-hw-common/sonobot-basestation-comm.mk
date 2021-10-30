include machine/append-sw-common/qemu-target.mk
LAYERS += git@gitlab.evologics.de:bsp/meta-evo-private.git

LOCAL_CONF_OPT += 'hostname_pn-base-files = "sonobot-$${EVOSN}-base"'

LOCAL_CONF_OPT += 'IMAGE_INSTALL_append = " dune-basestation-$${EVOSN} dune-basestation-$${EVOSN}-etc dune-basestation-$${EVOSN}-default "'