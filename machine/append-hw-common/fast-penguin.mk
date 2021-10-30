include machine/append-sw-common/qemu-target.mk

LAYERS += git@gitlab.evologics.de:bsp/meta-evo-private.git

LOCAL_CONF_OPT += 'IMAGE_INSTALL_append = " dune-fast-penguin-$${EVOSN} dune-fast-penguin-$${EVOSN}-etc dune-fast-penguin-$${EVOSN}-default"'

LOCAL_CONF_OPT += 'hostname_pn-base-files = "fast-penguin-$${EVOSN}"'
